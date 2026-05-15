import { Module, Global } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { AuditLog } from './audit-log.entity';
import { AuditService } from './audit.service';

/**
 * Modulo global de auditoria.
 *
 * @Global permite que AuditService sea inyectable en cualquier modulo
 * sin tener que importar AuditModule explicitamente.
 */
@Global()
@Module({
  imports: [TypeOrmModule.forFeature([AuditLog])],
  providers: [AuditService],
  exports: [AuditService],
})
export class AuditModule {}
