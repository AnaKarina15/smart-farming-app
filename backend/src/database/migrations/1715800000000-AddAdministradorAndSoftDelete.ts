import { MigrationInterface, QueryRunner } from 'typeorm';

/**
 * Migracion: Agrega el rol ADMINISTRADOR y soporte para soft-delete.
 *
 * Cambios:
 * 1. Agrega 'administrador' al enum users_role_enum.
 * 2. Agrega columnas createdBy, passwordChangedAt, mustChangePassword, deletedAt.
 * 3. Crea tabla audit_logs para auditoria.
 * 4. Recrea indices unicos para que solo apliquen a usuarios no eliminados.
 */
export class AddAdministradorAndSoftDelete1715800000000 implements MigrationInterface {
  name = 'AddAdministradorAndSoftDelete1715800000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    // ──────────────────────────────────────────────────────
    // 1. Agregar 'administrador' al enum
    // ──────────────────────────────────────────────────────
    await queryRunner.query(`
      ALTER TYPE "users_role_enum" ADD VALUE IF NOT EXISTS 'administrador'
    `);

    // ──────────────────────────────────────────────────────
    // 2. Nuevas columnas en users
    // ──────────────────────────────────────────────────────
    await queryRunner.query(`
      ALTER TABLE "users"
      ADD COLUMN IF NOT EXISTS "createdBy" uuid,
      ADD COLUMN IF NOT EXISTS "passwordChangedAt" TIMESTAMP WITH TIME ZONE,
      ADD COLUMN IF NOT EXISTS "mustChangePassword" boolean NOT NULL DEFAULT false,
      ADD COLUMN IF NOT EXISTS "deletedAt" TIMESTAMP WITH TIME ZONE
    `);

    // ──────────────────────────────────────────────────────
    // 3. Recrear indices unicos para que solo apliquen
    //    a usuarios no eliminados (soft-delete aware)
    // ──────────────────────────────────────────────────────
    await queryRunner.query(`DROP INDEX IF EXISTS "IDX_users_email"`);
    await queryRunner.query(`DROP INDEX IF EXISTS "IDX_users_telefono"`);
    await queryRunner.query(`
      CREATE UNIQUE INDEX "IDX_users_email_active"
      ON "users" ("email")
      WHERE "deletedAt" IS NULL
    `);
    await queryRunner.query(`
      CREATE UNIQUE INDEX "IDX_users_telefono_active"
      ON "users" ("telefono")
      WHERE telefono IS NOT NULL AND "deletedAt" IS NULL
    `);

    // ──────────────────────────────────────────────────────
    // 4. Tabla audit_logs para trazabilidad
    // ──────────────────────────────────────────────────────
    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS "audit_logs" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "actorId" uuid,
        "action" varchar(100) NOT NULL,
        "targetType" varchar(50),
        "targetId" uuid,
        "details" jsonb,
        "ipAddress" varchar(45),
        "userAgent" varchar(255),
        "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        CONSTRAINT "PK_audit_logs" PRIMARY KEY ("id"),
        CONSTRAINT "FK_audit_logs_actor"
          FOREIGN KEY ("actorId") REFERENCES "users"("id") ON DELETE SET NULL
      )
    `);

    await queryRunner.query(`
      CREATE INDEX "IDX_audit_logs_actor" ON "audit_logs" ("actorId")
    `);
    await queryRunner.query(`
      CREATE INDEX "IDX_audit_logs_action" ON "audit_logs" ("action")
    `);
    await queryRunner.query(`
      CREATE INDEX "IDX_audit_logs_target" ON "audit_logs" ("targetType", "targetId")
    `);
    await queryRunner.query(`
      CREATE INDEX "IDX_audit_logs_createdAt" ON "audit_logs" ("createdAt" DESC)
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    // Tabla de auditoria
    await queryRunner.query(`DROP TABLE IF EXISTS "audit_logs"`);

    // Indices unicos originales
    await queryRunner.query(`DROP INDEX IF EXISTS "IDX_users_email_active"`);
    await queryRunner.query(`DROP INDEX IF EXISTS "IDX_users_telefono_active"`);
    await queryRunner.query(`
      CREATE UNIQUE INDEX "IDX_users_email" ON "users" ("email")
    `);
    await queryRunner.query(`
      CREATE UNIQUE INDEX "IDX_users_telefono" ON "users" ("telefono")
      WHERE telefono IS NOT NULL
    `);

    // Columnas
    await queryRunner.query(`
      ALTER TABLE "users"
      DROP COLUMN IF EXISTS "deletedAt",
      DROP COLUMN IF EXISTS "mustChangePassword",
      DROP COLUMN IF EXISTS "passwordChangedAt",
      DROP COLUMN IF EXISTS "createdBy"
    `);

    // PostgreSQL no soporta quitar valores de un enum,
    // queda 'administrador' en el enum (sin impacto).
  }
}
