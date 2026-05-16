import {
  Column,
  CreateDateColumn,
  DeleteDateColumn,
  Entity,
  Index,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';

/**
 * Municipio del departamento del Magdalena, Colombia.
 *
 * Catalogo de los 30 municipios oficiales segun el DANE.
 * Se usa para georreferenciar lotes y generar reportes regionales.
 *
 * Fuente: DANE - Codigos de Division Politico-Administrativa de Colombia.
 */
@Entity('municipios')
@Index(['codigoDane'], { unique: true, where: '"deletedAt" IS NULL' })
@Index(['nombre'], { unique: true, where: '"deletedAt" IS NULL' })
export class Municipio {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  /**
   * Codigo oficial DANE (5 digitos). Ej: '47001' para Santa Marta.
   * Permite integraciones futuras con sistemas oficiales del gobierno.
   */
  @Column({ type: 'varchar', length: 5 })
  codigoDane!: string;

  @Column({ type: 'varchar', length: 100 })
  nombre!: string;

  /**
   * Subregion del Magdalena (Norte, Centro, Sur, Rio).
   * Util para agrupar reportes y aplicar reglas climaticas distintas.
   */
  @Column({ type: 'varchar', length: 50, nullable: true })
  subregion!: string | null;

  /**
   * Coordenadas del centro del municipio (cabecera municipal).
   * Permiten consultar el clima y aplicar reglas agronomicas regionales.
   */
  @Column({ type: 'numeric', precision: 10, scale: 7, nullable: true })
  latitud!: number | null;

  @Column({ type: 'numeric', precision: 10, scale: 7, nullable: true })
  longitud!: number | null;

  @Column({ type: 'boolean', default: true })
  activo!: boolean;

  @DeleteDateColumn({ type: 'timestamp with time zone', nullable: true })
  deletedAt!: Date | null;

  @CreateDateColumn({ type: 'timestamp with time zone' })
  createdAt!: Date;

  @UpdateDateColumn({ type: 'timestamp with time zone' })
  updatedAt!: Date;
}
