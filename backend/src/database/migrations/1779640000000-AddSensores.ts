import { MigrationInterface, QueryRunner } from 'typeorm';

export class AddSensores1779640000000 implements MigrationInterface {
  name = 'AddSensores1779640000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      DO $$ BEGIN
        CREATE TYPE "tipo_sensor_enum" AS ENUM ('humedad_suelo', 'temperatura', 'ph_suelo', 'luz', 'otro');
      EXCEPTION WHEN duplicate_object THEN null;
      END $$;
    `);

    await queryRunner.query(`
      DO $$ BEGIN
        CREATE TYPE "estado_sensor_enum" AS ENUM ('activo', 'inactivo', 'sin_emparejar');
      EXCEPTION WHEN duplicate_object THEN null;
      END $$;
    `);

    await queryRunner.query(`
      DO $$ BEGIN
        CREATE TYPE "origen_lectura_sensor_enum" AS ENUM ('sensor_ble', 'sensor_wifi', 'manual', 'simulado');
      EXCEPTION WHEN duplicate_object THEN null;
      END $$;
    `);

    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS "sensores" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "nombre" varchar(100) NOT NULL,
        "tipo" "tipo_sensor_enum" NOT NULL,
        "identificadorFisico" varchar(120) NULL,
        "loteId" uuid NOT NULL,
        "userId" uuid NOT NULL,
        "estado" "estado_sensor_enum" NOT NULL DEFAULT 'sin_emparejar',
        "unidadMedida" varchar(30) NOT NULL,
        "ultimaLecturaEn" timestamp with time zone NULL,
        "createdAt" timestamp with time zone NOT NULL DEFAULT now(),
        "updatedAt" timestamp with time zone NOT NULL DEFAULT now(),
        "deletedAt" timestamp with time zone NULL,
        CONSTRAINT "PK_sensores" PRIMARY KEY ("id")
      )
    `);

    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS "lecturas_sensor" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "sensorId" uuid NOT NULL,
        "loteId" uuid NOT NULL,
        "valor" numeric(10,3) NOT NULL,
        "unidad" varchar(30) NOT NULL,
        "calidadSenal" integer NULL,
        "origen" "origen_lectura_sensor_enum" NOT NULL,
        "medidoEn" timestamp with time zone NOT NULL,
        "userId" uuid NOT NULL,
        "clientLocalId" varchar(150) NULL,
        "createdAt" timestamp with time zone NOT NULL DEFAULT now(),
        CONSTRAINT "PK_lecturas_sensor" PRIMARY KEY ("id")
      )
    `);

    await this.addFkIfMissing(
      queryRunner,
      'sensores',
      'FK_sensores_lote',
      `ALTER TABLE "sensores" ADD CONSTRAINT "FK_sensores_lote" FOREIGN KEY ("loteId") REFERENCES "lotes"("id") ON DELETE CASCADE ON UPDATE NO ACTION`,
    );

    await this.addFkIfMissing(
      queryRunner,
      'sensores',
      'FK_sensores_user',
      `ALTER TABLE "sensores" ADD CONSTRAINT "FK_sensores_user" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION`,
    );

    await this.addFkIfMissing(
      queryRunner,
      'lecturas_sensor',
      'FK_lecturas_sensor_sensor',
      `ALTER TABLE "lecturas_sensor" ADD CONSTRAINT "FK_lecturas_sensor_sensor" FOREIGN KEY ("sensorId") REFERENCES "sensores"("id") ON DELETE CASCADE ON UPDATE NO ACTION`,
    );

    await this.addFkIfMissing(
      queryRunner,
      'lecturas_sensor',
      'FK_lecturas_sensor_lote',
      `ALTER TABLE "lecturas_sensor" ADD CONSTRAINT "FK_lecturas_sensor_lote" FOREIGN KEY ("loteId") REFERENCES "lotes"("id") ON DELETE CASCADE ON UPDATE NO ACTION`,
    );

    await this.addFkIfMissing(
      queryRunner,
      'lecturas_sensor',
      'FK_lecturas_sensor_user',
      `ALTER TABLE "lecturas_sensor" ADD CONSTRAINT "FK_lecturas_sensor_user" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION`,
    );

    await queryRunner.query(
      `CREATE INDEX IF NOT EXISTS "IDX_sensores_loteId" ON "sensores" ("loteId")`,
    );
    await queryRunner.query(
      `CREATE INDEX IF NOT EXISTS "IDX_sensores_userId" ON "sensores" ("userId")`,
    );
    await queryRunner.query(
      `CREATE INDEX IF NOT EXISTS "IDX_sensores_tipo" ON "sensores" ("tipo")`,
    );

    await queryRunner.query(`
      CREATE UNIQUE INDEX IF NOT EXISTS "IDX_sensores_identificador_fisico_unique"
      ON "sensores" ("identificadorFisico") WHERE "identificadorFisico" IS NOT NULL
    `);

    await queryRunner.query(
      `CREATE INDEX IF NOT EXISTS "IDX_lecturas_sensor_sensor_medido" ON "lecturas_sensor" ("sensorId", "medidoEn")`,
    );

    await queryRunner.query(
      `CREATE INDEX IF NOT EXISTS "IDX_lecturas_sensor_lote_medido" ON "lecturas_sensor" ("loteId", "medidoEn")`,
    );

    await queryRunner.query(
      `CREATE INDEX IF NOT EXISTS "IDX_lecturas_sensor_userId" ON "lecturas_sensor" ("userId")`,
    );

    await queryRunner.query(`
      CREATE UNIQUE INDEX IF NOT EXISTS "IDX_lecturas_sensor_client_local_unique"
      ON "lecturas_sensor" ("userId", "sensorId", "clientLocalId") WHERE "clientLocalId" IS NOT NULL
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP INDEX IF EXISTS "IDX_lecturas_sensor_client_local_unique"`);
    await queryRunner.query(`DROP INDEX IF EXISTS "IDX_lecturas_sensor_userId"`);
    await queryRunner.query(`DROP INDEX IF EXISTS "IDX_lecturas_sensor_lote_medido"`);
    await queryRunner.query(`DROP INDEX IF EXISTS "IDX_lecturas_sensor_sensor_medido"`);
    await queryRunner.query(`DROP INDEX IF EXISTS "IDX_sensores_identificador_fisico_unique"`);
    await queryRunner.query(`DROP INDEX IF EXISTS "IDX_sensores_tipo"`);
    await queryRunner.query(`DROP INDEX IF EXISTS "IDX_sensores_userId"`);
    await queryRunner.query(`DROP INDEX IF EXISTS "IDX_sensores_loteId"`);

    await queryRunner.query(
      `ALTER TABLE "lecturas_sensor" DROP CONSTRAINT IF EXISTS "FK_lecturas_sensor_user"`,
    );
    await queryRunner.query(
      `ALTER TABLE "lecturas_sensor" DROP CONSTRAINT IF EXISTS "FK_lecturas_sensor_lote"`,
    );
    await queryRunner.query(
      `ALTER TABLE "lecturas_sensor" DROP CONSTRAINT IF EXISTS "FK_lecturas_sensor_sensor"`,
    );
    await queryRunner.query(`ALTER TABLE "sensores" DROP CONSTRAINT IF EXISTS "FK_sensores_user"`);
    await queryRunner.query(`ALTER TABLE "sensores" DROP CONSTRAINT IF EXISTS "FK_sensores_lote"`);

    await queryRunner.query(`DROP TABLE IF EXISTS "lecturas_sensor"`);
    await queryRunner.query(`DROP TABLE IF EXISTS "sensores"`);

    await queryRunner.query(`DROP TYPE IF EXISTS "origen_lectura_sensor_enum"`);
    await queryRunner.query(`DROP TYPE IF EXISTS "estado_sensor_enum"`);
    await queryRunner.query(`DROP TYPE IF EXISTS "tipo_sensor_enum"`);
  }

  private async addFkIfMissing(
    queryRunner: QueryRunner,
    tableName: string,
    constraintName: string,
    sql: string,
  ): Promise<void> {
    const existing = await queryRunner.query(
      `SELECT 1 FROM information_schema.table_constraints WHERE table_name = $1 AND constraint_name = $2`,
      [tableName, constraintName],
    );

    if (existing.length === 0) {
      await queryRunner.query(sql);
    }
  }
}
