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
 * Fertilizante o enmienda agricola.
 *
 * Cubre los productos mas usados en el Magdalena:
 * nitrogenados (Urea, Sulfato de Amonio), fosfatados (DAP, SFT),
 * potasicos (KCl), compuestos (15-15-15, 10-30-10) y organicos.
 */
@Entity('fertilizantes')
@Index(['nombre'], { unique: true, where: '"deletedAt" IS NULL' })
export class Fertilizante {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'varchar', length: 100 })
  nombre!: string;

  /**
   * Tipo agronomico.
   * Valores: nitrogenado | fosfatado | potasico | compuesto | organico | enmienda
   */
  @Column({ type: 'varchar', length: 30 })
  tipo!: string;

  /**
   * Composicion NPK como string normalizado.
   * Ej: '15-15-15' o '46-0-0' (Urea pura).
   */
  @Column({ type: 'varchar', length: 20, nullable: true })
  composicionNpk!: string | null;

  /**
   * Estado fisico de aplicacion.
   * Valores: solido_granulado | solido_polvo | liquido | foliar
   */
  @Column({ type: 'varchar', length: 30 })
  presentacion!: string;

  /**
   * Dosis recomendada en kilogramos por hectarea.
   * Valor referencial; el agronomo ajusta segun analisis de suelo.
   */
  @Column({ type: 'numeric', precision: 7, scale: 2, nullable: true })
  dosisRecomendadaKgHa!: number | null;

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
