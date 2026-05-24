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

import { Cultivo } from '../../catalogos/entities/cultivo.entity';
import { Municipio } from '../../catalogos/entities/municipio.entity';
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

  /**
   * @deprecated Sera removido. Conservado por compatibilidad con datos legacy.
   * Usar cultivoActualId (FK a Cultivo) para nuevos registros.
   */
  @Column({ type: 'varchar', length: 100, nullable: true })
  cultivoActual!: string | null;

  /**
   * FK al catalogo de cultivos. Reemplaza progresivamente al string cultivoActual.
   */
  @Column({ type: 'uuid', nullable: true })
  cultivoActualId!: string | null;

  @ManyToOne(() => Cultivo, { nullable: true, onDelete: 'SET NULL' })
  @JoinColumn({ name: 'cultivoActualId' })
  cultivo!: Cultivo | null;

  /**
   * FK opcional al municipio donde se ubica el lote.
   * Permite generar reportes regionales.
   */
  @Column({ type: 'uuid', nullable: true })
  municipioId!: string | null;

  @ManyToOne(() => Municipio, { nullable: true, onDelete: 'SET NULL' })
  @JoinColumn({ name: 'municipioId' })
  municipio!: Municipio | null;

  /**
   * FK opcional al tipo de suelo del lote.
   * Permite caracterizar el suelo al crear el lote.
   */
  @Column({ type: 'uuid', nullable: true })
  tipoSueloId!: string | null;

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
