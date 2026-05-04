import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';

import { User } from '../../users/entities/user.entity';

/**
 * Entidad Lote - representa una parcela del Pequeno Productor.
 *
 * Contexto Fase 1: Productores con extensiones menores a 5 hectareas.
 * Cubre RF02 (Aprobar cronograma sugerido) y RF04 (Registrar estado del terreno).
 *
 * Notas:
 * - Las coordenadas (lat/lng) usan numeric con 7 decimales para precision GPS.
 * - El campo `superficieHectareas` no debe superar 5 (validado en DTO).
 */
@Entity('lotes')
@Index(['propietarioId'])
export class Lote {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'varchar', length: 100 })
  nombre!: string;

  @Column({ type: 'varchar', length: 200, nullable: true })
  descripcion!: string | null;

  @Column({ type: 'numeric', precision: 5, scale: 2 })
  superficieHectareas!: number;

  @Column({ type: 'varchar', length: 100, nullable: true })
  cultivoActual!: string | null;

  @Column({ type: 'numeric', precision: 10, scale: 7, nullable: true })
  latitud!: number | null;

  @Column({ type: 'numeric', precision: 10, scale: 7, nullable: true })
  longitud!: number | null;

  @Column({ type: 'varchar', length: 50, default: 'saludable' })
  estado!: string;

  @Column({ type: 'uuid' })
  propietarioId!: string;

  @ManyToOne(() => User, (user) => user.lotes, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'propietarioId' })
  propietario!: User;

  @CreateDateColumn({ type: 'timestamp with time zone' })
  createdAt!: Date;

  @UpdateDateColumn({ type: 'timestamp with time zone' })
  updatedAt!: Date;
}
