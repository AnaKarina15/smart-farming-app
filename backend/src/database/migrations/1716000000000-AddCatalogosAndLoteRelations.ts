import { MigrationInterface, QueryRunner } from 'typeorm';

/**
 * Migracion: Sprint 2 - Catalogos del dominio agricola del Magdalena.
 *
 * Cambios:
 * 1. Crea tabla `municipios` (con codigoDane unico).
 * 2. Crea tabla `cultivos`.
 * 3. Crea tabla `plagas`.
 * 4. Crea tabla `fertilizantes`.
 * 5. Crea tabla `tipos_suelo`.
 * 6. Agrega columna `cultivoActualId` (FK a cultivos) en la tabla `lotes`.
 *    Conserva el campo legado `cultivoActual` (string) por compatibilidad
 *    con datos existentes; se eliminara despues de una limpieza programada.
 * 7. Agrega columna opcional `municipioId` (FK a municipios) en `lotes`.
 */
export class AddCatalogosAndLoteRelations1716000000000 implements MigrationInterface {
  name = 'AddCatalogosAndLoteRelations1716000000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    // ────────────────────────────────────────────────────
    // 1. Tabla municipios
    // ────────────────────────────────────────────────────
    await queryRunner.query(`
      CREATE TABLE "municipios" (
        "id" uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
        "codigoDane" varchar(5) NOT NULL,
        "nombre" varchar(100) NOT NULL,
        "subregion" varchar(50),
        "latitud" numeric(10,7),
        "longitud" numeric(10,7),
        "activo" boolean NOT NULL DEFAULT true,
        "deletedAt" timestamp with time zone,
        "createdAt" timestamp with time zone NOT NULL DEFAULT now(),
        "updatedAt" timestamp with time zone NOT NULL DEFAULT now()
      )
    `);
    await queryRunner.query(
      `CREATE UNIQUE INDEX "IDX_municipios_codigoDane_active" ON "municipios" ("codigoDane") WHERE "deletedAt" IS NULL`,
    );
    await queryRunner.query(
      `CREATE UNIQUE INDEX "IDX_municipios_nombre_active" ON "municipios" ("nombre") WHERE "deletedAt" IS NULL`,
    );

    // ────────────────────────────────────────────────────
    // 2. Tabla cultivos
    // ────────────────────────────────────────────────────
    await queryRunner.query(`
      CREATE TABLE "cultivos" (
        "id" uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
        "nombre" varchar(100) NOT NULL,
        "nombreCientifico" varchar(150),
        "categoria" varchar(30) NOT NULL,
        "cicloVegetativo" varchar(20) NOT NULL,
        "diasCosecha" int,
        "densidadSiembraPorHa" int,
        "descripcion" text,
        "activo" boolean NOT NULL DEFAULT true,
        "deletedAt" timestamp with time zone,
        "createdAt" timestamp with time zone NOT NULL DEFAULT now(),
        "updatedAt" timestamp with time zone NOT NULL DEFAULT now()
      )
    `);
    await queryRunner.query(
      `CREATE UNIQUE INDEX "IDX_cultivos_nombre_active" ON "cultivos" ("nombre") WHERE "deletedAt" IS NULL`,
    );
    await queryRunner.query(
      `CREATE UNIQUE INDEX "IDX_cultivos_nombreCientifico_active" ON "cultivos" ("nombreCientifico") WHERE "deletedAt" IS NULL`,
    );

    // ────────────────────────────────────────────────────
    // 3. Tabla plagas
    // ────────────────────────────────────────────────────
    await queryRunner.query(`
      CREATE TABLE "plagas" (
        "id" uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
        "nombre" varchar(100) NOT NULL,
        "nombreCientifico" varchar(150),
        "tipo" varchar(30) NOT NULL,
        "severidadTipica" varchar(20) NOT NULL,
        "sintomas" text,
        "cultivosAfectados" text,
        "activo" boolean NOT NULL DEFAULT true,
        "deletedAt" timestamp with time zone,
        "createdAt" timestamp with time zone NOT NULL DEFAULT now(),
        "updatedAt" timestamp with time zone NOT NULL DEFAULT now()
      )
    `);
    await queryRunner.query(
      `CREATE UNIQUE INDEX "IDX_plagas_nombre_active" ON "plagas" ("nombre") WHERE "deletedAt" IS NULL`,
    );
    await queryRunner.query(
      `CREATE UNIQUE INDEX "IDX_plagas_nombreCientifico_active" ON "plagas" ("nombreCientifico") WHERE "deletedAt" IS NULL`,
    );

    // ────────────────────────────────────────────────────
    // 4. Tabla fertilizantes
    // ────────────────────────────────────────────────────
    await queryRunner.query(`
      CREATE TABLE "fertilizantes" (
        "id" uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
        "nombre" varchar(100) NOT NULL,
        "tipo" varchar(30) NOT NULL,
        "composicionNpk" varchar(20),
        "presentacion" varchar(30) NOT NULL,
        "dosisRecomendadaKgHa" numeric(7,2),
        "descripcion" text,
        "activo" boolean NOT NULL DEFAULT true,
        "deletedAt" timestamp with time zone,
        "createdAt" timestamp with time zone NOT NULL DEFAULT now(),
        "updatedAt" timestamp with time zone NOT NULL DEFAULT now()
      )
    `);
    await queryRunner.query(
      `CREATE UNIQUE INDEX "IDX_fertilizantes_nombre_active" ON "fertilizantes" ("nombre") WHERE "deletedAt" IS NULL`,
    );

    // ────────────────────────────────────────────────────
    // 5. Tabla tipos_suelo
    // ────────────────────────────────────────────────────
    await queryRunner.query(`
      CREATE TABLE "tipos_suelo" (
        "id" uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
        "nombre" varchar(50) NOT NULL,
        "clase" varchar(30) NOT NULL,
        "drenaje" varchar(20) NOT NULL,
        "retencionHumedadPct" numeric(4,1),
        "phTipico" numeric(3,1),
        "cultivosRecomendados" text,
        "descripcion" text,
        "activo" boolean NOT NULL DEFAULT true,
        "deletedAt" timestamp with time zone,
        "createdAt" timestamp with time zone NOT NULL DEFAULT now(),
        "updatedAt" timestamp with time zone NOT NULL DEFAULT now()
      )
    `);
    await queryRunner.query(
      `CREATE UNIQUE INDEX "IDX_tipos_suelo_nombre_active" ON "tipos_suelo" ("nombre") WHERE "deletedAt" IS NULL`,
    );

    // ────────────────────────────────────────────────────
    // 6. Modificar tabla lotes:
    //    - Agregar cultivoActualId (FK opcional)
    //    - Agregar municipioId (FK opcional)
    //    - Mantener cultivoActual (string) por compatibilidad
    // ────────────────────────────────────────────────────
    await queryRunner.query(`
      ALTER TABLE "lotes"
        ADD COLUMN IF NOT EXISTS "cultivoActualId" uuid,
        ADD COLUMN IF NOT EXISTS "municipioId" uuid
    `);

    await queryRunner.query(`
      ALTER TABLE "lotes"
        ADD CONSTRAINT "FK_lotes_cultivoActual"
        FOREIGN KEY ("cultivoActualId")
        REFERENCES "cultivos"("id")
        ON DELETE SET NULL
        ON UPDATE CASCADE
    `);

    await queryRunner.query(`
      ALTER TABLE "lotes"
        ADD CONSTRAINT "FK_lotes_municipio"
        FOREIGN KEY ("municipioId")
        REFERENCES "municipios"("id")
        ON DELETE SET NULL
        ON UPDATE CASCADE
    `);

    await queryRunner.query(
      `CREATE INDEX "IDX_lotes_cultivoActualId" ON "lotes" ("cultivoActualId")`,
    );
    await queryRunner.query(`CREATE INDEX "IDX_lotes_municipioId" ON "lotes" ("municipioId")`);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    // Revertir cambios en lotes
    await queryRunner.query(`DROP INDEX IF EXISTS "IDX_lotes_municipioId"`);
    await queryRunner.query(`DROP INDEX IF EXISTS "IDX_lotes_cultivoActualId"`);
    await queryRunner.query(`ALTER TABLE "lotes" DROP CONSTRAINT IF EXISTS "FK_lotes_municipio"`);
    await queryRunner.query(
      `ALTER TABLE "lotes" DROP CONSTRAINT IF EXISTS "FK_lotes_cultivoActual"`,
    );
    await queryRunner.query(`ALTER TABLE "lotes" DROP COLUMN IF EXISTS "municipioId"`);
    await queryRunner.query(`ALTER TABLE "lotes" DROP COLUMN IF EXISTS "cultivoActualId"`);

    // Drop tablas en orden inverso
    await queryRunner.query(`DROP TABLE IF EXISTS "tipos_suelo"`);
    await queryRunner.query(`DROP TABLE IF EXISTS "fertilizantes"`);
    await queryRunner.query(`DROP TABLE IF EXISTS "plagas"`);
    await queryRunner.query(`DROP TABLE IF EXISTS "cultivos"`);
    await queryRunner.query(`DROP TABLE IF EXISTS "municipios"`);
  }
}
