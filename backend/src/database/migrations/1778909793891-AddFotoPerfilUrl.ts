import { MigrationInterface, QueryRunner } from 'typeorm';

export class AddFotoPerfilUrl1778909793891 implements MigrationInterface {
  name = 'AddFotoPerfilUrl1778909793891';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "lotes" DROP CONSTRAINT "FK_lotes_propietario"`);
    await queryRunner.query(`ALTER TABLE "audit_logs" DROP CONSTRAINT "FK_audit_logs_actor"`);
    await queryRunner.query(`DROP INDEX "public"."IDX_lotes_propietario"`);
    await queryRunner.query(`DROP INDEX "public"."IDX_users_email_active"`);
    await queryRunner.query(`DROP INDEX "public"."IDX_users_telefono_active"`);
    await queryRunner.query(`DROP INDEX "public"."IDX_audit_logs_actor"`);
    await queryRunner.query(`DROP INDEX "public"."IDX_audit_logs_action"`);
    await queryRunner.query(`DROP INDEX "public"."IDX_audit_logs_target"`);
    await queryRunner.query(`DROP INDEX "public"."IDX_audit_logs_createdAt"`);
    await queryRunner.query(`ALTER TABLE "users" ADD "fotoPerfilUrl" character varying(255)`);
    await queryRunner.query(`ALTER TABLE "users" DROP CONSTRAINT "UQ_users_email"`);
    await queryRunner.query(
      `CREATE INDEX "IDX_0afd78a3c2cfd6b0f6c01125f6" ON "lotes" ("propietarioId") `,
    );
    await queryRunner.query(
      `CREATE UNIQUE INDEX "IDX_fc8d97361c52561e9425a8a7da" ON "users" ("telefono") WHERE telefono IS NOT NULL AND "deletedAt" IS NULL`,
    );
    await queryRunner.query(
      `CREATE UNIQUE INDEX "IDX_262d8d714a42e664d987714a75" ON "users" ("email") WHERE "deletedAt" IS NULL`,
    );
    await queryRunner.query(
      `CREATE INDEX "IDX_c69efb19bf127c97e6740ad530" ON "audit_logs" ("createdAt") `,
    );
    await queryRunner.query(
      `CREATE INDEX "IDX_61614f246ac701597f688946b9" ON "audit_logs" ("targetType", "targetId") `,
    );
    await queryRunner.query(
      `CREATE INDEX "IDX_cee5459245f652b75eb2759b4c" ON "audit_logs" ("action") `,
    );
    await queryRunner.query(
      `CREATE INDEX "IDX_2dc33f7f3c22e2e7badafca1d1" ON "audit_logs" ("actorId") `,
    );
    await queryRunner.query(
      `ALTER TABLE "lotes" ADD CONSTRAINT "FK_0afd78a3c2cfd6b0f6c01125f67" FOREIGN KEY ("propietarioId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION`,
    );
    await queryRunner.query(
      `ALTER TABLE "audit_logs" ADD CONSTRAINT "FK_2dc33f7f3c22e2e7badafca1d12" FOREIGN KEY ("actorId") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE NO ACTION`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "audit_logs" DROP CONSTRAINT "FK_2dc33f7f3c22e2e7badafca1d12"`,
    );
    await queryRunner.query(`ALTER TABLE "lotes" DROP CONSTRAINT "FK_0afd78a3c2cfd6b0f6c01125f67"`);
    await queryRunner.query(`DROP INDEX "public"."IDX_2dc33f7f3c22e2e7badafca1d1"`);
    await queryRunner.query(`DROP INDEX "public"."IDX_cee5459245f652b75eb2759b4c"`);
    await queryRunner.query(`DROP INDEX "public"."IDX_61614f246ac701597f688946b9"`);
    await queryRunner.query(`DROP INDEX "public"."IDX_c69efb19bf127c97e6740ad530"`);
    await queryRunner.query(`DROP INDEX "public"."IDX_262d8d714a42e664d987714a75"`);
    await queryRunner.query(`DROP INDEX "public"."IDX_fc8d97361c52561e9425a8a7da"`);
    await queryRunner.query(`DROP INDEX "public"."IDX_0afd78a3c2cfd6b0f6c01125f6"`);
    await queryRunner.query(`ALTER TABLE "users" ADD CONSTRAINT "UQ_users_email" UNIQUE ("email")`);
    await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "fotoPerfilUrl"`);
    await queryRunner.query(
      `CREATE INDEX "IDX_audit_logs_createdAt" ON "audit_logs" ("createdAt") `,
    );
    await queryRunner.query(
      `CREATE INDEX "IDX_audit_logs_target" ON "audit_logs" ("targetType", "targetId") `,
    );
    await queryRunner.query(`CREATE INDEX "IDX_audit_logs_action" ON "audit_logs" ("action") `);
    await queryRunner.query(`CREATE INDEX "IDX_audit_logs_actor" ON "audit_logs" ("actorId") `);
    await queryRunner.query(
      `CREATE UNIQUE INDEX "IDX_users_telefono_active" ON "users" ("telefono") WHERE ((telefono IS NOT NULL) AND ("deletedAt" IS NULL))`,
    );
    await queryRunner.query(
      `CREATE UNIQUE INDEX "IDX_users_email_active" ON "users" ("email") WHERE ("deletedAt" IS NULL)`,
    );
    await queryRunner.query(`CREATE INDEX "IDX_lotes_propietario" ON "lotes" ("propietarioId") `);
    await queryRunner.query(
      `ALTER TABLE "audit_logs" ADD CONSTRAINT "FK_audit_logs_actor" FOREIGN KEY ("actorId") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE NO ACTION`,
    );
    await queryRunner.query(
      `ALTER TABLE "lotes" ADD CONSTRAINT "FK_lotes_propietario" FOREIGN KEY ("propietarioId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION`,
    );
  }
}
