import { MigrationInterface, QueryRunner } from 'typeorm';

/**
 * Fix de esquema - tabla lotes.
 *
 * La entidad Lote declara el campo `tipoSueloId` (FK opcional al catalogo
 * de tipos de suelo), pero la columna nunca se creo en la base de datos
 * mediante una migration. Esto causaba el error:
 *   "column lotes.tipoSueloId does not exist"
 * al crear o listar lotes.
 *
 * Esta migration agrega la columna y su llave foranea hacia tipos_suelo,
 * dejando el esquema sincronizado con la entidad. Idempotente: usa
 * IF NOT EXISTS para poder ejecutarse aunque la columna ya exista en
 * algun entorno.
 */
export class AddTipoSueloToLotes1779610000000 implements MigrationInterface {
  name = 'AddTipoSueloToLotes1779610000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    // 1. Agregar la columna (si no existe)
    await queryRunner.query(`ALTER TABLE "lotes" ADD COLUMN IF NOT EXISTS "tipoSueloId" uuid`);

    // 2. Agregar la llave foranea hacia tipos_suelo (si no existe)
    const fk = await queryRunner.query(
      `SELECT 1 FROM information_schema.table_constraints
       WHERE constraint_name = 'FK_lotes_tipoSuelo' AND table_name = 'lotes'`,
    );
    if (fk.length === 0) {
      await queryRunner.query(
        `ALTER TABLE "lotes"
         ADD CONSTRAINT "FK_lotes_tipoSuelo"
         FOREIGN KEY ("tipoSueloId") REFERENCES "tipos_suelo"("id")
         ON DELETE SET NULL ON UPDATE NO ACTION`,
      );
    }
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "lotes" DROP CONSTRAINT IF EXISTS "FK_lotes_tipoSuelo"`);
    await queryRunner.query(`ALTER TABLE "lotes" DROP COLUMN IF EXISTS "tipoSueloId"`);
  }
}
