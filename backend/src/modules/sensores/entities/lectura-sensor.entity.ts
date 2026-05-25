import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from 'typeorm';

import { Lote } from '../../lotes/entities/lote.entity';
import { User } from '../../users/entities/user.entity';
import { Sensor } from './sensor.entity';

export enum OrigenLecturaSensor {
  SENSOR_BLE = 'sensor_ble',
  SENSOR_WIFI = 'sensor_wifi',
  MANUAL = 'manual',
  SIMULADO = 'simulado',
}

@Entity('lecturas_sensor')
@Index(['sensorId', 'medidoEn'])
@Index(['loteId', 'medidoEn'])
@Index(['userId'])
@Index(['userId', 'sensorId', 'clientLocalId'], {
  unique: true,
  where: '"clientLocalId" IS NOT NULL',
})
export class LecturaSensor {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'uuid' })
  sensorId!: string;

  @ManyToOne(() => Sensor, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'sensorId' })
  sensor!: Sensor;

  @Column({ type: 'uuid' })
  loteId!: string;

  @ManyToOne(() => Lote, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'loteId' })
  lote!: Lote;

  @Column({ type: 'numeric', precision: 10, scale: 3 })
  valor!: number;

  @Column({ type: 'varchar', length: 30 })
  unidad!: string;

  @Column({ type: 'int', nullable: true })
  calidadSenal!: number | null;

  @Column({ type: 'enum', enum: OrigenLecturaSensor })
  origen!: OrigenLecturaSensor;

  @Column({ type: 'timestamp with time zone' })
  medidoEn!: Date;

  @Column({ type: 'uuid' })
  userId!: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user!: User;

  /**
   * Identificador estable del registro offline en el dispositivo.
   * Permite que POST /sensores/lecturas/batch sea idempotente ante reintentos.
   */
  @Column({ type: 'varchar', length: 150, nullable: true })
  clientLocalId!: string | null;

  @CreateDateColumn({ type: 'timestamp with time zone' })
  createdAt!: Date;
}
