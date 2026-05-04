import { MigrationInterface, QueryRunner } from 'typeorm';

export class InitialSchema1714694400000 implements MigrationInterface {
  name = 'InitialSchema1714694400000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    // Extension para UUID
    await queryRunner.query(`CREATE EXTENSION IF NOT EXISTS "uuid-ossp"`);

    // Enum de roles
    await queryRunner.query(`
      CREATE TYPE "users_role_enum" AS ENUM('pequeno_productor', 'trabajador', 'gestor')
    `);

    // Tabla users
    await queryRunner.query(`
      CREATE TABLE "users" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "nombreCompleto" varchar(150) NOT NULL,
        "email" varchar(150) NOT NULL,
        "telefono" varchar(20),
        "password" varchar(255) NOT NULL,
        "role" "users_role_enum" NOT NULL DEFAULT 'pequeno_productor',
        "activo" boolean NOT NULL DEFAULT true,
        "refreshTokenHash" varchar(255),
        "ultimoAcceso" TIMESTAMP WITH TIME ZONE,
        "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        "updatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        CONSTRAINT "PK_users" PRIMARY KEY ("id"),
        CONSTRAINT "UQ_users_email" UNIQUE ("email")
      )
    `);

    await queryRunner.query(`CREATE UNIQUE INDEX "IDX_users_email" ON "users" ("email")`);
    await queryRunner.query(
      `CREATE UNIQUE INDEX "IDX_users_telefono" ON "users" ("telefono") WHERE telefono IS NOT NULL`,
    );

    // Tabla lotes
    await queryRunner.query(`
      CREATE TABLE "lotes" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "nombre" varchar(100) NOT NULL,
        "descripcion" varchar(200),
        "superficieHectareas" numeric(5,2) NOT NULL,
        "cultivoActual" varchar(100),
        "latitud" numeric(10,7),
        "longitud" numeric(10,7),
        "estado" varchar(50) NOT NULL DEFAULT 'saludable',
        "propietarioId" uuid NOT NULL,
        "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        "updatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        CONSTRAINT "PK_lotes" PRIMARY KEY ("id"),
        CONSTRAINT "FK_lotes_propietario" FOREIGN KEY ("propietarioId")
          REFERENCES "users"("id") ON DELETE CASCADE
      )
    `);

    await queryRunner.query(`CREATE INDEX "IDX_lotes_propietario" ON "lotes" ("propietarioId")`);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP TABLE IF EXISTS "lotes"`);
    await queryRunner.query(`DROP TABLE IF EXISTS "users"`);
    await queryRunner.query(`DROP TYPE IF EXISTS "users_role_enum"`);
  }
}
