import { BadRequestException, ForbiddenException, NotFoundException } from '@nestjs/common';
import { EntityManager, EntityTarget } from 'typeorm';

import { JwtPayload } from '../../../common/decorators/current-user.decorator';
import { Cultivo } from '../../catalogos/entities/cultivo.entity';
import { Lote } from '../../lotes/entities/lote.entity';
import { UserRole } from '../../users/entities/user-role.enum';
import {
  SyncResourceAdapter,
  SyncWriteContext,
  SyncWriteExistingContext,
  SyncableEntity,
} from './sync-resource.adapter';

export abstract class AbstractSyncResourceAdapter<
  T extends SyncableEntity,
> implements SyncResourceAdapter<T> {
  abstract readonly resourceType: string;
  abstract readonly endpointAliases: readonly string[];
  abstract readonly pullKey: string;

  protected constructor(
    readonly entityTarget: EntityTarget<T>,
    protected readonly label: string,
    private readonly queryAlias: string,
  ) {}

  abstract create(context: SyncWriteContext): Promise<string>;

  async update(context: SyncWriteExistingContext): Promise<string> {
    const entity = await this.findExisting(context.manager, context.serverId);

    this.assertOwner(entity, context.user, this.label);
    this.assertClientWins(entity, context.clientUpdatedAt);

    const patch = await this.buildUpdatePatch(context, entity);

    Object.assign(entity, patch, {
      updatedAt: context.clientUpdatedAt,
      deletedAt: null,
    });

    await context.manager.getRepository(this.entityTarget).save(entity);

    return context.serverId;
  }

  async delete(context: SyncWriteExistingContext): Promise<string> {
    const entity = await this.findExisting(context.manager, context.serverId);

    this.assertOwner(entity, context.user, this.label);
    this.assertClientWins(entity, context.clientUpdatedAt);

    Object.assign(entity, {
      updatedAt: context.clientUpdatedAt,
      deletedAt: context.clientUpdatedAt,
    });

    await context.manager.getRepository(this.entityTarget).save(entity);

    return context.serverId;
  }

  async findChangesSince(manager: EntityManager, since: Date, user: JwtPayload): Promise<T[]> {
    const qb = manager
      .getRepository(this.entityTarget)
      .createQueryBuilder(this.queryAlias)
      .withDeleted()
      .where(
        `(${this.queryAlias}."createdAt" > :since OR ${this.queryAlias}."updatedAt" > :since OR ${this.queryAlias}."deletedAt" > :since)`,
        { since },
      )
      .orderBy(`${this.queryAlias}."updatedAt"`, 'ASC');

    if (user.role !== UserRole.ADMINISTRADOR) {
      qb.andWhere(`${this.queryAlias}."userId" = :userId`, { userId: user.sub });
    }

    return qb.getMany();
  }

  protected abstract buildUpdatePatch(
    context: SyncWriteExistingContext,
    entity: T,
  ): Promise<Record<string, unknown>>;

  protected async findExisting(manager: EntityManager, serverId: string): Promise<T> {
    const entity = await manager.getRepository(this.entityTarget).findOne({
      where: { id: serverId } as any,
      withDeleted: true,
    });

    if (!entity) {
      throw new NotFoundException(`${this.label} ${serverId} no encontrado`);
    }

    return entity;
  }

  protected async assertLoteOwnership(
    manager: EntityManager,
    loteId: string,
    user: JwtPayload,
  ): Promise<void> {
    const lote = await manager.findOne(Lote, {
      where: { id: loteId },
    });

    if (!lote) {
      throw new NotFoundException(`Lote ${loteId} no encontrado`);
    }

    if (user.role !== UserRole.ADMINISTRADOR && lote.propietarioId !== user.sub) {
      throw new ForbiddenException('El lote no pertenece al usuario autenticado');
    }
  }

  protected assertOwner(entity: SyncableEntity, user: JwtPayload, label: string): void {
    if (user.role !== UserRole.ADMINISTRADOR && entity.userId !== user.sub) {
      throw new ForbiddenException(`${label} no pertenece al usuario autenticado`);
    }
  }

  protected assertClientWins(entity: SyncableEntity, clientUpdatedAt: Date): void {
    const updatedAt = this.asDate(entity.updatedAt);
    const deletedAt = this.asDate(entity.deletedAt);
    const serverVersion =
      updatedAt && deletedAt && deletedAt > updatedAt ? deletedAt : (updatedAt ?? deletedAt);

    if (serverVersion && serverVersion > clientUpdatedAt) {
      throw new BadRequestException(
        `Conflicto last-write-wins: servidor tiene una version mas reciente (${serverVersion.toISOString()})`,
      );
    }
  }

  protected async assertExists(
    manager: EntityManager,
    entity: EntityTarget<object>,
    id: string,
    label: string,
  ): Promise<void> {
    const found = await manager.findOne(entity, {
      where: { id } as any,
    });

    if (!found) {
      throw new NotFoundException(`${label} ${id} no encontrado`);
    }
  }

  protected async updateLoteCultivoActual(
    manager: EntityManager,
    loteId: string,
    cultivoId: string | null,
    cultivoOtro: string | null,
  ): Promise<void> {
    const lote = await manager.findOne(Lote, {
      where: { id: loteId },
    });

    if (!lote) return;

    if (cultivoId) {
      const cultivo = await manager.findOne(Cultivo, {
        where: { id: cultivoId },
      });

      lote.cultivoActualId = cultivoId;
      lote.cultivoActual = cultivo?.nombre ?? null;
    } else {
      lote.cultivoActualId = null;
      lote.cultivoActual = cultivoOtro;
    }

    await manager.save(Lote, lote);
  }

  protected requiredString(payload: Record<string, unknown>, field: string): string {
    const value = payload[field];

    if (typeof value !== 'string' || value.trim() === '') {
      throw new BadRequestException(`${field} es obligatorio`);
    }

    return value;
  }

  protected optionalString(payload: Record<string, unknown>, field: string): string | null {
    const value = payload[field];

    if (value === undefined || value === null || value === '') {
      return null;
    }

    if (typeof value !== 'string') {
      throw new BadRequestException(`${field} debe ser string`);
    }

    return value;
  }

  protected optionalNumber(payload: Record<string, unknown>, field: string): number | null {
    const value = payload[field];

    if (value === undefined || value === null || value === '') {
      return null;
    }

    const parsed = typeof value === 'number' ? value : Number(value);

    if (Number.isNaN(parsed)) {
      throw new BadRequestException(`${field} debe ser numerico`);
    }

    if (parsed < 0) {
      throw new BadRequestException(`${field} no puede ser negativo`);
    }

    return parsed;
  }

  protected requiredDate(payload: Record<string, unknown>, field: string): Date {
    const date = this.optionalDate(payload, field);

    if (!date) {
      throw new BadRequestException(`${field} es obligatorio y debe ser fecha ISO8601`);
    }

    return date;
  }

  protected optionalDate(payload: Record<string, unknown>, field: string): Date | null {
    const value = payload[field];

    if (value === undefined || value === null || value === '') {
      return null;
    }

    if (typeof value !== 'string' && !(value instanceof Date)) {
      throw new BadRequestException(`${field} debe ser fecha ISO8601`);
    }

    const date = value instanceof Date ? value : new Date(value);

    if (Number.isNaN(date.getTime())) {
      throw new BadRequestException(`${field} debe ser fecha ISO8601 valida`);
    }

    return date;
  }

  protected pick(
    payload: Record<string, unknown>,
    fields: string[],
    dateFields: string[] = [],
  ): Record<string, unknown> {
    const patch: Record<string, unknown> = {};

    for (const field of fields) {
      if (payload[field] !== undefined) {
        patch[field] = payload[field] === '' ? null : payload[field];
      }
    }

    for (const field of dateFields) {
      if (payload[field] !== undefined) {
        patch[field] = this.requiredDate(payload, field);
      }
    }

    return patch;
  }

  protected assertIn(value: string, allowed: readonly string[], field: string): void {
    if (!allowed.includes(value)) {
      throw new BadRequestException(`${field} no es valido`);
    }
  }

  private asDate(value: unknown): Date | null {
    if (!value) {
      return null;
    }

    const date = value instanceof Date ? value : new Date(String(value));

    return Number.isNaN(date.getTime()) ? null : date;
  }
}
