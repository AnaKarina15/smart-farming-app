import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from 'typeorm';

import { User } from '../users/entities/user.entity';

/**
 * Entidad AuditLog - registro de acciones realizadas en el sistema.
 *
 * Cubre el requisito de trazabilidad y auditoria de seguridad (RNF03).
 * Permite responder: "Quien hizo que, cuando, sobre que recurso".
 *
 * Ejemplos de acciones:
 * - 'user.register'   - Usuario se auto-registro
 * - 'user.create'     - Admin creo un usuario
 * - 'user.delete'     - Admin elimino un usuario (soft-delete)
 * - 'user.reset_pwd'  - Admin reseteo password
 * - 'user.role_change'- Admin cambio rol
 * - 'auth.login'      - Login exitoso
 * - 'auth.logout'     - Logout
 * - 'lote.create'     - Lote creado
 */
@Entity('audit_logs')
@Index(['actorId'])
@Index(['action'])
@Index(['targetType', 'targetId'])
@Index(['createdAt'])
export class AuditLog {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  /**
   * Usuario que realizo la accion. Null si fue accion del sistema
   * o si el usuario fue eliminado.
   */
  @Column({ type: 'uuid', nullable: true })
  actorId!: string | null;

  @ManyToOne(() => User, { onDelete: 'SET NULL' })
  @JoinColumn({ name: 'actorId' })
  actor!: User | null;

  /**
   * Identificador de la accion. Usa convencion: 'recurso.accion'.
   * Ej: 'user.delete', 'lote.create', 'auth.login'.
   */
  @Column({ type: 'varchar', length: 100 })
  action!: string;

  /**
   * Tipo de recurso afectado: 'user', 'lote', etc.
   */
  @Column({ type: 'varchar', length: 50, nullable: true })
  targetType!: string | null;

  /**
   * UUID del recurso afectado.
   */
  @Column({ type: 'uuid', nullable: true })
  targetId!: string | null;

  /**
   * Detalles adicionales en formato JSON.
   * Ej: { oldRole: 'pequeno_productor', newRole: 'gestor' }
   */
  @Column({ type: 'jsonb', nullable: true })
  details!: Record<string, unknown> | null;

  @Column({ type: 'varchar', length: 45, nullable: true })
  ipAddress!: string | null;

  @Column({ type: 'varchar', length: 255, nullable: true })
  userAgent!: string | null;

  @CreateDateColumn({ type: 'timestamp with time zone' })
  createdAt!: Date;
}
