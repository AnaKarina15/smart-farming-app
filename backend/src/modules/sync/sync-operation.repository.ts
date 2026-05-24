import { Injectable } from '@nestjs/common';
import { EntityManager } from 'typeorm';

import { SyncOperation } from './entities/sync-operation.entity';

@Injectable()
export class SyncOperationRepository {
  findByUserAndKey(
    manager: EntityManager,
    userId: string,
    idempotencyKey: string,
  ): Promise<SyncOperation | null> {
    return manager.findOne(SyncOperation, {
      where: { userId, idempotencyKey },
    });
  }

  async saveMapping(
    manager: EntityManager,
    existing: SyncOperation | null,
    values: Partial<SyncOperation>,
  ): Promise<void> {
    const operation = existing ?? manager.create(SyncOperation);

    Object.assign(operation, values);

    await manager.save(SyncOperation, operation);
  }
}
