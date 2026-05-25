import { MigrationInterface, QueryRunner } from 'typeorm';

export class AddHistorialClima1779650000000 implements MigrationInterface {
  name = 'AddHistorialClima1779650000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS "historial_clima" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "loteId" uuid NOT NULL,
        "fecha" date NOT NULL,
        "temperatura" numeric(6,2) NOT NULL,
        "probabilidadLluvia" numeric(5,2) NOT NULL,
        "precipitacionMm" numeric(8,2) NOT NULL,
        "humedadSuelo" numeric(6,3) NULL,
        "humedadRelativa" numeric(6,2) NULL,
        "viento" numeric(6,2) NOT NULL,
        "fuente" varchar(50) NOT NULL DEFAULT 'open-meteo',
        "registradoEn" timestamp with time zone NOT NULL,
        "createdAt" timestamp with time zone NOT NULL DEFAULT now(),
        CONSTRAINT "PK_historial_clima" PRIMARY KEY ("id")
      )
    `);

    const fk = await queryRunner.query(`
      SELECT 1 FROM information_schema.table_constraints
      WHERE table_name = 'historial_clima'
      AND constraint_name = 'FK_historial_clima_lote'
    `);

    if (fk.length === 0) {
      await queryRunner.query(`
        ALTER TABLE "historial_clima"
        ADD CONSTRAINT "FK_historial_clima_lote"
        FOREIGN KEY ("loteId") REFERENCES "lotes"("id")
        ON DELETE CASCADE ON UPDATE NO ACTION
      `);
    }

    await queryRunner.query(`
      CREATE UNIQUE INDEX IF NOT EXISTS "IDX_historial_clima_lote_fecha"
      ON "historial_clima" ("loteId", "fecha")
    `);

    await queryRunner.query(`
      CREATE INDEX IF NOT EXISTS "IDX_historial_clima_loteId"
      ON "historial_clima" ("loteId")
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP INDEX IF EXISTS "IDX_historial_clima_loteId"`);
    await queryRunner.query(`DROP INDEX IF EXISTS "IDX_historial_clima_lote_fecha"`);
    await queryRunner.query(
      `ALTER TABLE "historial_clima" DROP CONSTRAINT IF EXISTS "FK_historial_clima_lote"`,
    );
    await queryRunner.query(`DROP TABLE IF EXISTS "historial_clima"`);
  }
}
