import { MigrationInterface, QueryRunner } from 'typeorm';

/**
 * Sprint 4 - Sistema Experto.
 * Amplia la columna unidadRecomendada de la tabla reglas de
 * varchar(30) a varchar(90).
 *
 * Motivo: algunas reglas agronomicas usan descripciones de unidad
 * compuestas (ej. "L aceite + 250 cc imidacloprid/ha") que superan
 * los 30 caracteres originales.
 *
 * Registra oficialmente el cambio que se aplico durante el desarrollo,
 * garantizando que la BD se pueda recrear desde cero de forma consistente.
 */
export class IncreaseUnidadRecomendadaLength1779600000000 implements MigrationInterface {
  name = 'IncreaseUnidadRecomendadaLength1779600000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "reglas" ALTER COLUMN "unidadRecomendada" TYPE character varying(90)`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "reglas" ALTER COLUMN "unidadRecomendada" TYPE character varying(30)`,
    );
  }
}
