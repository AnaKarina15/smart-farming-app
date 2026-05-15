import {
  Column,
  CreateDateColumn,
  DeleteDateColumn,
  Entity,
  Index,
  OneToMany,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';

import { Lote } from '../../lotes/entities/lote.entity';
import { UserRole } from './user-role.enum';

/**
 * Entidad User - representa todos los actores del sistema.
 *
 * Cubre los stakeholders identificados en la Fase 1:
 * - Pequeno Productor Agricola
 * - Trabajador de Campo / Jornalero
 * - Gestor de Asociacion Agricola
 * - Administrador del Sistema
 *
 * Notas de seguridad (RNF03):
 * - El campo `password` almacena hash Argon2 (no contrasenas en texto plano).
 * - El campo `password` esta excluido por defecto en serializacion (select: false).
 * - Soft-delete habilitado: los usuarios eliminados conservan su historial (deletedAt).
 */
@Entity('users')
@Index(['email'], { unique: true, where: '"deletedAt" IS NULL' })
@Index(['telefono'], { unique: true, where: 'telefono IS NOT NULL AND "deletedAt" IS NULL' })
export class User {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'varchar', length: 150 })
  nombreCompleto!: string;

  @Column({ type: 'varchar', length: 150 })
  email!: string;

  @Column({ type: 'varchar', length: 20, nullable: true })
  telefono!: string | null;

  @Column({ type: 'varchar', length: 255, select: false })
  password!: string;

  @Column({
    type: 'enum',
    enum: UserRole,
    default: UserRole.PEQUENO_PRODUCTOR,
  })
  role!: UserRole;

  @Column({ type: 'boolean', default: true })
  activo!: boolean;

  @Column({ type: 'varchar', length: 255, nullable: true, select: false })
  refreshTokenHash!: string | null;

  @Column({ type: 'timestamp with time zone', nullable: true })
  ultimoAcceso!: Date | null;

  // ──────────────────────────────────────────────────────────
  // CAMPOS ADMIN / RECUPERACION DE CUENTA
  // ──────────────────────────────────────────────────────────

  /**
   * UUID del admin que creo este usuario manualmente.
   * NULL si el usuario se registro por si mismo via /auth/register.
   */
  @Column({ type: 'uuid', nullable: true })
  createdBy!: string | null;

  /**
   * Fecha del ultimo cambio de password.
   * Util para auditoria y politicas de password expiration.
   */
  @Column({ type: 'timestamp with time zone', nullable: true })
  passwordChangedAt!: Date | null;

  /**
   * Si es TRUE, el usuario debe cambiar su password en el proximo login.
   * Se setea automaticamente cuando un admin resetea la password.
   */
  @Column({ type: 'boolean', default: false })
  mustChangePassword!: boolean;

  /**
   * Soft-delete: cuando se "elimina" un usuario, se setea esta fecha
   * en lugar de borrar el registro fisicamente. Mantiene historial e integridad.
   */
  @DeleteDateColumn({ type: 'timestamp with time zone', nullable: true })
  deletedAt!: Date | null;

  // ──────────────────────────────────────────────────────────
  // TIMESTAMPS
  // ──────────────────────────────────────────────────────────

  @CreateDateColumn({ type: 'timestamp with time zone' })
  createdAt!: Date;

  @UpdateDateColumn({ type: 'timestamp with time zone' })
  updatedAt!: Date;

  // Relaciones
  @OneToMany(() => Lote, (lote) => lote.propietario)
  lotes!: Lote[];
}
