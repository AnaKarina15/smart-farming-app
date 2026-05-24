import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource, EntityManager } from 'typeorm';

import { JwtPayload } from '../../common/decorators/current-user.decorator';
import { SyncBatchDto, SyncBatchItemDto, SyncOperationType } from './dto/sync-batch.dto';
import {
  SyncBatchItemResultDto,
  SyncBatchResponseDto,
  SyncItemStatus,
  SyncValidateTokenResponseDto,
} from './dto/sync-response.dto';
import { SyncOperation } from './entities/sync-operation.entity';
import { SyncOperationRepository } from './sync-operation.repository';
import { SyncRegistry } from './sync-registry';

@Injectable()
export class SyncService {
  constructor(
    @InjectDataSource()
    private readonly dataSource: DataSource,
    private readonly registry: SyncRegistry,
    private readonly syncOperationRepo: SyncOperationRepository,
  ) {}

  async processBatch(dto: SyncBatchDto, user: JwtPayload): Promise<SyncBatchResponseDto> {
    const results = await this.dataSource.transaction(async (manager) => {
      const batchResults: SyncBatchItemResultDto[] = [];

      for (const item of dto.items) {
        batchResults.push(await this.processItem(manager, item, user));
      }

      return batchResults;
    });

    return {
      serverTime: new Date().toISOString(),
      results,
      summary: this.buildSummary(results),
    };
  }

  async getChangesSince(timestamp: string, user: JwtPayload) {
    const since = new Date(timestamp);

    if (Number.isNaN(since.getTime())) {
      throw new BadRequestException('timestamp debe ser una fecha ISO8601 valida');
    }

    const changes: Record<string, unknown[]> = {};

    await this.dataSource.transaction(async (manager) => {
      for (const adapter of this.registry.all()) {
        changes[adapter.pullKey] = await adapter.findChangesSince(manager, since, user);
      }
    });

    return {
      serverTime: new Date().toISOString(),
      since: since.toISOString(),
      changes,
    };
  }

  validateToken(user: JwtPayload): SyncValidateTokenResponseDto {
    const nowSeconds = Math.floor(Date.now() / 1000);
    const expiresInSeconds = user.exp ? Math.max(user.exp - nowSeconds, 0) : null;
    const expiresAt = user.exp ? new Date(user.exp * 1000).toISOString() : null;

    return {
      serverTime: new Date().toISOString(),
      user: {
        id: user.sub,
        email: user.email,
        role: user.role,
      },
      token: {
        valid: true,
        expiresAt,
        expiresInSeconds,
      },
    };
  }

  private async processItem(
    manager: EntityManager,
    item: SyncBatchItemDto,
    user: JwtPayload,
  ): Promise<SyncBatchItemResultDto> {
    let resourceType = item.resourceType ?? 'unknown';
    let operation: SyncOperationType = 'create';

    try {
      const adapter = this.registry.resolve(item);
      resourceType = adapter.resourceType;
      operation = this.resolveOperation(item);

      const idempotencyKey = `${resourceType}:${item.localId}`;
      const existing = await this.syncOperationRepo.findByUserAndKey(
        manager,
        user.sub,
        idempotencyKey,
      );

      if (operation === 'create' && existing?.serverId && existing.status !== 'error') {
        return {
          localId: item.localId,
          resourceType,
          serverId: existing.serverId,
          status: 'duplicate',
        };
      }

      const clientUpdatedAt = this.resolveClientUpdatedAt(item);

      const serverId = await this.applyOperation(
        manager,
        adapter,
        item,
        user,
        operation,
        clientUpdatedAt,
        existing,
      );

      const status = this.operationToStatus(operation);

      await this.syncOperationRepo.saveMapping(manager, existing, {
        userId: user.sub,
        localId: item.localId,
        idempotencyKey,
        resourceType,
        serverId,
        operation,
        status,
        error: null,
        clientUpdatedAt,
      });

      return {
        localId: item.localId,
        resourceType,
        serverId,
        status,
      };
    } catch (error) {
      return {
        localId: item.localId,
        resourceType,
        status: 'error',
        error: this.errorMessage(error),
      };
    }
  }

  private async applyOperation(
    manager: EntityManager,
    adapter: ReturnType<SyncRegistry['resolve']>,
    item: SyncBatchItemDto,
    user: JwtPayload,
    operation: SyncOperationType,
    clientUpdatedAt: Date,
    existing: SyncOperation | null,
  ): Promise<string> {
    if (operation === 'create') {
      return adapter.create({ manager, item, user, clientUpdatedAt });
    }

    const serverId =
      item.serverId ?? this.extractServerIdFromEndpoint(item.endpoint) ?? existing?.serverId;

    if (!serverId) {
      throw new BadRequestException(
        'serverId es obligatorio para update/delete si no existe mapeo local previo',
      );
    }

    if (operation === 'delete') {
      return adapter.delete({ manager, item, user, clientUpdatedAt, serverId });
    }

    return adapter.update({ manager, item, user, clientUpdatedAt, serverId });
  }

  private resolveOperation(item: SyncBatchItemDto): SyncOperationType {
    if (item.operation) {
      return item.operation;
    }

    const method = item.method?.toUpperCase();

    if (method === 'POST') return 'create';
    if (method === 'PATCH' || method === 'PUT') return 'update';
    if (method === 'DELETE') return 'delete';

    return 'create';
  }

  private resolveClientUpdatedAt(item: SyncBatchItemDto): Date {
    const value =
      item.clientUpdatedAt ??
      this.readPayloadDate(item.payload, 'updatedAt') ??
      this.readPayloadDate(item.payload, 'createdAt');

    const date = value ? new Date(value) : new Date();

    if (Number.isNaN(date.getTime())) {
      throw new BadRequestException('clientUpdatedAt debe ser una fecha ISO8601 valida');
    }

    return date;
  }

  private readPayloadDate(payload: Record<string, unknown>, field: string): string | null {
    const value = payload[field];

    if (typeof value === 'string') {
      return value;
    }

    return null;
  }

  private extractServerIdFromEndpoint(endpoint?: string): string | null {
    if (!endpoint) return null;

    const cleaned = endpoint.split('?')[0];
    const segments = cleaned.split('/').filter(Boolean);
    const last = segments[segments.length - 1];

    const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

    return last && uuidRegex.test(last) ? last : null;
  }

  private operationToStatus(
    operation: SyncOperationType,
  ): Exclude<SyncItemStatus, 'duplicate' | 'error'> {
    if (operation === 'delete') return 'deleted';
    if (operation === 'update') return 'updated';
    return 'created';
  }

  private buildSummary(results: SyncBatchItemResultDto[]): Record<string, number> {
    return results.reduce(
      (summary, item) => {
        summary.total += 1;
        summary[item.status] = (summary[item.status] ?? 0) + 1;
        return summary;
      },
      { total: 0, created: 0, updated: 0, deleted: 0, duplicate: 0, error: 0 } as Record<
        string,
        number
      >,
    );
  }

  private errorMessage(error: unknown): string {
    if (
      error instanceof BadRequestException ||
      error instanceof NotFoundException ||
      error instanceof ForbiddenException
    ) {
      const response = error.getResponse();

      if (typeof response === 'object' && response && 'message' in response) {
        const message = (response as { message?: string | string[] }).message;
        return Array.isArray(message) ? message.join('; ') : String(message);
      }

      return error.message;
    }

    if (error instanceof Error) {
      return error.message;
    }

    return 'Error desconocido durante sincronizacion';
  }
}
