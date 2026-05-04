import {
  Column,
  CreateDateColumn,
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
 *
 * Notas de seguridad (RNF03):
 * - El campo `password` almacena hash Argon2 (no contrasenas en texto plano).
 * - El campo `password` esta excluido por defecto en serializacion (select: false).
 */
@Entity('users')
@Index(['email'], { unique: true })
@Index(['telefono'], { unique: true, where: 'telefono IS NOT NULL' })
export class User {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'varchar', length: 150 })
  nombreCompleto!: string;

  @Column({ type: 'varchar', length: 150, unique: true })
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

  @CreateDateColumn({ type: 'timestamp with time zone' })
  createdAt!: Date;

  @UpdateDateColumn({ type: 'timestamp with time zone' })
  updatedAt!: Date;

  // Relaciones
  @OneToMany(() => Lote, (lote) => lote.propietario)
  lotes!: Lote[];
}
