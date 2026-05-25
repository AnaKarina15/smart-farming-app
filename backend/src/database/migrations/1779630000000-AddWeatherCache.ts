import { MigrationInterface, QueryRunner } from 'typeorm';

/**
 * Sprint 6 - Integracion climatica.
 *
 * Crea la tabla weather_cache que persiste los datos climaticos
 * consultados a Open-Meteo, permitiendo servir clima aunque la API
 * externa no responda (resiliencia offline-first del lado servidor).
 */
export class AddWeatherCache1779630000000 implements MigrationInterface {
  name = 'AddWeatherCache1779630000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS "weather_cache" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "geoKey" varchar(40) NOT NULL,
        "latitud" numeric(10,7) NOT NULL,
        "longitud" numeric(10,7) NOT NULL,
        "actual" jsonb NOT NULL,
        "pronostico" jsonb NOT NULL,
        "obtenidoEn" timestamp with time zone NOT NULL,
        "createdAt" timestamp with time zone NOT NULL DEFAULT now(),
        "updatedAt" timestamp with time zone NOT NULL DEFAULT now(),
        CONSTRAINT "PK_weather_cache" PRIMARY KEY ("id")
      )
    `);

    await queryRunner.query(
      `CREATE UNIQUE INDEX IF NOT EXISTS "IDX_weather_cache_geoKey"
       ON "weather_cache" ("geoKey")`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP INDEX IF EXISTS "IDX_weather_cache_geoKey"`);
    await queryRunner.query(`DROP TABLE IF EXISTS "weather_cache"`);
  }
}
