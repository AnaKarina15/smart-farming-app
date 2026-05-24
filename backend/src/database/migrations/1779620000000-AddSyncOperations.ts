import { MigrationInterface, QueryRunner } from 'typeorm';

/**
 * Sprint 5 - Soporte servidor para sincronizacion offline-first.
 *
 * Crea una tabla tecnica de idempotencia que mapea operaciones locales
 * reintentables (resourceType + localId + userId) contra el UUID real
 * creado/modificado en servidor.
 */
export class AddSyncOperations1779620000000 implements MigrationInterface {
  name = 'AddSyncOperations1779620000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS "sync_operations" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "userId" uuid NOT NULL,
        "resourceType" varchar(50) NOT NULL,
        "localId" varchar(120) NOT NULL,
        "idempotencyKey" varchar(180) NOT NULL,
        "serverId" uuid NULL,
        "operation" varchar(20) NOT NULL,
        "status" varchar(20) NOT NULL,
        "error" text NULL,
        "clientUpdatedAt" timestamp with time zone NULL,
        "createdAt" timestamp with time zone NOT NULL DEFAULT now(),
        "updatedAt" timestamp with time zone NOT NULL DEFAULT now(),
        CONSTRAINT "PK_sync_operations" PRIMARY KEY ("id")
      )
    `);

    const fk = await queryRunner.query(
      `SELECT 1 FROM information_schema.table_constraints
       WHERE constraint_name = 'FK_sync_operations_user' AND table_name = 'sync_operations'`,
    );

    if (fk.length === 0) {
      await queryRunner.query(
        `ALTER TABLE "sync_operations"
         ADD CONSTRAINT "FK_sync_operations_user"
         FOREIGN KEY ("userId") REFERENCES "users"("id")
         ON DELETE CASCADE ON UPDATE NO ACTION`,
      );
    }

    await queryRunner.query(
      `CREATE INDEX IF NOT EXISTS "IDX_sync_operations_userId" ON "sync_operations" ("userId")`,
    );

    await queryRunner.query(
      `CREATE INDEX IF NOT EXISTS "IDX_sync_operations_resourceType" ON "sync_operations" ("resourceType")`,
    );

    await queryRunner.query(
      `CREATE INDEX IF NOT EXISTS "IDX_sync_operations_serverId" ON "sync_operations" ("serverId")`,
    );

    await queryRunner.query(
      `CREATE UNIQUE INDEX IF NOT EXISTS "IDX_sync_operations_user_idempotency"
       ON "sync_operations" ("userId", "idempotencyKey")`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP INDEX IF EXISTS "IDX_sync_operations_user_idempotency"`);
    await queryRunner.query(`DROP INDEX IF EXISTS "IDX_sync_operations_serverId"`);
    await queryRunner.query(`DROP INDEX IF EXISTS "IDX_sync_operations_resourceType"`);
    await queryRunner.query(`DROP INDEX IF EXISTS "IDX_sync_operations_userId"`);
    await queryRunner.query(
      `ALTER TABLE "sync_operations" DROP CONSTRAINT IF EXISTS "FK_sync_operations_user"`,
    );
    await queryRunner.query(`DROP TABLE IF EXISTS "sync_operations"`);
  }
}
