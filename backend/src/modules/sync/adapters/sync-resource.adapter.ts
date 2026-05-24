import { EntityManager, EntityTarget, ObjectLiteral } from 'typeorm';

import { JwtPayload } from '../../../common/decorators/current-user.decorator';
import { SyncBatchItemDto } from '../dto/sync-batch.dto';

export interface SyncableEntity extends ObjectLiteral {
  id: string;
  userId: string;
  createdAt: Date;
  updatedAt: Date;
  deletedAt?: Date | null;
}

export interface SyncWriteContext {
  manager: EntityManager;
  item: SyncBatchItemDto;
  user: JwtPayload;
  clientUpdatedAt: Date;
}

export interface SyncWriteExistingContext extends SyncWriteContext {
  serverId: string;
}

export interface SyncResourceAdapter<T extends SyncableEntity = SyncableEntity> {
  readonly resourceType: string;
  readonly endpointAliases: readonly string[];
  readonly entityTarget: EntityTarget<T>;
  readonly pullKey: string;

  create(context: SyncWriteContext): Promise<string>;
  update(context: SyncWriteExistingContext): Promise<string>;
  delete(context: SyncWriteExistingContext): Promise<string>;
  findChangesSince(manager: EntityManager, since: Date, user: JwtPayload): Promise<T[]>;
}
