import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';

/**
 * Cache de datos climaticos consultados a Open-Meteo.
 *
 * Como el productor opera en zonas rurales con conectividad intermitente,
 * el clima consultado se persiste por celda geografica redondeada. Si
 * Open-Meteo no responde (sin internet en el servidor o API caida), el
 * servicio devuelve el ultimo dato cacheado en lugar de fallar.
 *
 * La celda geografica se calcula redondeando lat/lon a 2 decimales
 * (~1.1 km), suficiente para datos climaticos y evita una fila por cada
 * coordenada GPS exacta.
 */
@Entity('weather_cache')
@Index(['geoKey'], { unique: true })
export class WeatherCache {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  /**
   * Clave de celda geografica: "lat,lon" redondeado a 2 decimales.
   * Ej: "11.24,-74.20". Identifica de forma estable la zona consultada.
   */
  @Column({ type: 'varchar', length: 40 })
  geoKey!: string;

  @Column({ type: 'numeric', precision: 10, scale: 7 })
  latitud!: number;

  @Column({ type: 'numeric', precision: 10, scale: 7 })
  longitud!: number;

  /**
   * Snapshot del clima actual (temperatura, viento, etc.) tal como
   * lo devuelve la capa de servicio. Se guarda como JSON para no
   * acoplar el esquema a la estructura de Open-Meteo.
   */
  @Column({ type: 'jsonb' })
  actual!: Record<string, unknown>;

  /**
   * Pronostico extendido por dias. Array de objetos diarios.
   */
  @Column({ type: 'jsonb' })
  pronostico!: Record<string, unknown>[];

  /**
   * Momento en que se obtuvo el dato desde Open-Meteo. Sirve para
   * calcular la frescura del cache.
   */
  @Column({ type: 'timestamp with time zone' })
  obtenidoEn!: Date;

  @CreateDateColumn({ type: 'timestamp with time zone' })
  createdAt!: Date;

  @UpdateDateColumn({ type: 'timestamp with time zone' })
  updatedAt!: Date;
}
