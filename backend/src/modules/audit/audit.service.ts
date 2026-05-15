import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { AuditLog } from './audit-log.entity';

export interface LogActionParams {
  actorId: string | null;
  action: string;
  targetType?: string;
  targetId?: string;
  details?: Record<string, unknown>;
  ipAddress?: string;
  userAgent?: string;
}

/**
 * Servicio de auditoria. Registra acciones relevantes del sistema.
 *
 * Uso:
 *   await auditService.log({
 *     actorId: user.id,
 *     action: 'user.delete',
 *     targetType: 'user',
 *     targetId: deletedUserId,
 *     details: { reason: 'Solicitud del usuario' },
 *   });
 */
@Injectable()
export class AuditService {
  constructor(
    @InjectRepository(AuditLog)
    private readonly repo: Repository<AuditLog>,
  ) {}

  async log(params: LogActionParams): Promise<void> {
    const entry = this.repo.create({
      actorId: params.actorId,
      action: params.action,
      targetType: params.targetType ?? null,
      targetId: params.targetId ?? null,
      details: params.details ?? null,
      ipAddress: params.ipAddress ?? null,
      userAgent: params.userAgent ?? null,
    });
    await this.repo.save(entry);
  }

  /**
   * Lista los logs filtrados (solo para admin).
   */
  async findAll(options: {
    actorId?: string;
    action?: string;
    targetType?: string;
    targetId?: string;
    limit?: number;
    offset?: number;
  }): Promise<{ data: AuditLog[]; total: number }> {
    const query = this.repo
      .createQueryBuilder('log')
      .leftJoinAndSelect('log.actor', 'actor')
      .orderBy('log.createdAt', 'DESC');

    if (options.actorId) {
      query.andWhere('log.actorId = :actorId', { actorId: options.actorId });
    }
    if (options.action) {
      query.andWhere('log.action = :action', { action: options.action });
    }
    if (options.targetType) {
      query.andWhere('log.targetType = :targetType', { targetType: options.targetType });
    }
    if (options.targetId) {
      query.andWhere('log.targetId = :targetId', { targetId: options.targetId });
    }

    const limit = options.limit ?? 50;
    const offset = options.offset ?? 0;
    query.take(limit).skip(offset);

    const [data, total] = await query.getManyAndCount();
    return { data, total };
  }
}
