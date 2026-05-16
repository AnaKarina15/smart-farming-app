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
 * Cultivo agricola disponible para los productores del Magdalena.
 *
 * Cubre los principales cultivos de la region:
 * cereales (maiz, arroz), frutales (mango, banano, cacao),
 * hortalizas (yuca, platano) y comerciales (cafe, palma).
 */
@Entity('cultivos')
@Index(['nombreCientifico'], { unique: true, where: '"deletedAt" IS NULL' })
@Index(['nombre'], { unique: true, where: '"deletedAt" IS NULL' })
export class Cultivo {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'varchar', length: 100 })
  nombre!: string;

  /**
   * Nombre cientifico binomial (genero + especie).
   * Ej: 'Zea mays' para Maiz.
   */
  @Column({ type: 'varchar', length: 150, nullable: true })
  nombreCientifico!: string | null;

  /**
   * Categoria agronomica del cultivo.
   * Valores: cereal | frutal | hortaliza | leguminosa | tuberculo | comercial | forraje
   */
  @Column({ type: 'varchar', length: 30 })
  categoria!: string;

  /**
   * Ciclo de cultivo: 'transitorio' (corto, <1 ano) o 'permanente' (>1 ano).
   * Afecta planificacion de siembras y rotacion.
   */
  @Column({ type: 'varchar', length: 20 })
  cicloVegetativo!: string;

  /**
   * Dias aproximados desde siembra hasta cosecha (transitorios).
   * En permanentes representa el tiempo hasta produccion inicial.
   */
  @Column({ type: 'int', nullable: true })
  diasCosecha!: number | null;

  /**
   * Densidad de siembra recomendada (plantas por hectarea).
   * Ej: Maiz ~55,000 plantas/ha.
   */
  @Column({ type: 'int', nullable: true })
  densidadSiembraPorHa!: number | null;

  @Column({ type: 'text', nullable: true })
  descripcion!: string | null;

  @Column({ type: 'boolean', default: true })
  activo!: boolean;

  @DeleteDateColumn({ type: 'timestamp with time zone', nullable: true })
  deletedAt!: Date | null;

  @CreateDateColumn({ type: 'timestamp with time zone' })
  createdAt!: Date;

  @UpdateDateColumn({ type: 'timestamp with time zone' })
  updatedAt!: Date;
}
