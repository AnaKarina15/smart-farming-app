import { MigrationInterface, QueryRunner, Table, TableForeignKey, TableIndex } from 'typeorm';

/**
 * Sprint 4 - Sistema Experto de Recomendaciones Agronomicas.
 *
 * Crea 2 tablas:
 * - reglas                     -> catalogo de reglas IF-THEN (admin gestiona)
 * - recomendaciones_aplicadas  -> audit log cuando el productor aplica una recomendacion
 *
 * Marco etico aplicado:
 * - Cada regla tiene fuenteCientifica OBLIGATORIA (defensible academicamente).
 * - El motor SUGIERE, el productor DECIDE (registrado en recomendaciones_aplicadas).
 * - Reglas desactivables sin redeploy (campo `activa`).
 *
 * Convenciones (igual que Sprint 3):
 * - FKs a catalogos con ON DELETE SET NULL (preservar regla aunque cambien catalogos).
 * - FK a lote/user con ON DELETE CASCADE en audit (datos personales).
 * - Soft-delete con deletedAt en reglas.
 * - Indexes en columnas de filtrado frecuente.
 *
 * Idempotente.
 */
export class AddReglasYRecomendaciones1717000000000 implements MigrationInterface {
  name = 'AddReglasYRecomendaciones1717000000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    // ════════════════════════════════════════════════════════
    // TABLA: reglas
    // ════════════════════════════════════════════════════════
    await queryRunner.createTable(
      new Table({
        name: 'reglas',
        columns: [
          { name: 'id', type: 'uuid', isPrimary: true, default: 'gen_random_uuid()' },

          // ─── Identificacion ───
          { name: 'codigo', type: 'varchar', length: '50', isNullable: false },
          { name: 'nombre', type: 'varchar', length: '200', isNullable: false },
          { name: 'descripcion', type: 'text', isNullable: true },

          // ─── Categoria ───
          { name: 'tipoRecomendacion', type: 'varchar', length: '40', isNullable: false },

          // ─── Condiciones IF (todas opcionales = no filtran si null) ───
          { name: 'cultivoId', type: 'uuid', isNullable: true },
          { name: 'plagaId', type: 'uuid', isNullable: true },
          { name: 'tipoSueloId', type: 'uuid', isNullable: true },
          { name: 'faseAgronomica', type: 'varchar', length: '40', isNullable: true },
          { name: 'severidadMinima', type: 'varchar', length: '20', isNullable: true },
          { name: 'estacion', type: 'varchar', length: '20', isNullable: true },
          { name: 'diasSinRiegoMinimo', type: 'int', isNullable: true },
          { name: 'diasDesdeSiembraMinimo', type: 'int', isNullable: true },
          { name: 'diasDesdeSiembraMaximo', type: 'int', isNullable: true },
          { name: 'humedadMaxima', type: 'numeric', precision: 5, scale: 2, isNullable: true },
          { name: 'humedadMinima', type: 'numeric', precision: 5, scale: 2, isNullable: true },

          // ─── Accion THEN ───
          { name: 'accionSugerida', type: 'text', isNullable: false },
          { name: 'productoSugerido', type: 'varchar', length: '200', isNullable: true },
          { name: 'fertilizanteSugeridoId', type: 'uuid', isNullable: true },
          { name: 'dosisRecomendada', type: 'numeric', precision: 12, scale: 2, isNullable: true },
          { name: 'unidadRecomendada', type: 'varchar', length: '30', isNullable: true },
          { name: 'metodoAplicacion', type: 'varchar', length: '40', isNullable: true },
          { name: 'frecuenciaDias', type: 'int', isNullable: true },

          // ─── Metadatos ───
          { name: 'prioridad', type: 'int', default: 3, isNullable: false },
          { name: 'fuenteCientifica', type: 'text', isNullable: false },
          { name: 'activa', type: 'boolean', default: true, isNullable: false },
          { name: 'notas', type: 'text', isNullable: true },

          // ─── Timestamps ───
          { name: 'createdAt', type: 'timestamp with time zone', default: 'CURRENT_TIMESTAMP' },
          { name: 'updatedAt', type: 'timestamp with time zone', default: 'CURRENT_TIMESTAMP' },
          { name: 'deletedAt', type: 'timestamp with time zone', isNullable: true },
        ],
      }),
      true,
    );

    // ─── Unique index parcial para codigo (solo entre reglas activas) ───
    await queryRunner.query(
      `CREATE UNIQUE INDEX "IDX_reglas_codigo_unique" ON "reglas" ("codigo") WHERE "deletedAt" IS NULL`,
    );

    // ─── FKs de reglas a catalogos (SET NULL preserva la regla) ───
    await queryRunner.createForeignKey(
      'reglas',
      new TableForeignKey({
        columnNames: ['cultivoId'],
        referencedTableName: 'cultivos',
        referencedColumnNames: ['id'],
        onDelete: 'SET NULL',
      }),
    );
    await queryRunner.createForeignKey(
      'reglas',
      new TableForeignKey({
        columnNames: ['plagaId'],
        referencedTableName: 'plagas',
        referencedColumnNames: ['id'],
        onDelete: 'SET NULL',
      }),
    );
    await queryRunner.createForeignKey(
      'reglas',
      new TableForeignKey({
        columnNames: ['tipoSueloId'],
        referencedTableName: 'tipos_suelo',
        referencedColumnNames: ['id'],
        onDelete: 'SET NULL',
      }),
    );
    await queryRunner.createForeignKey(
      'reglas',
      new TableForeignKey({
        columnNames: ['fertilizanteSugeridoId'],
        referencedTableName: 'fertilizantes',
        referencedColumnNames: ['id'],
        onDelete: 'SET NULL',
      }),
    );

    // ─── Indexes para filtrado en el motor ───
    await queryRunner.createIndex(
      'reglas',
      new TableIndex({ name: 'IDX_reglas_tipo', columnNames: ['tipoRecomendacion'] }),
    );
    await queryRunner.createIndex(
      'reglas',
      new TableIndex({ name: 'IDX_reglas_cultivo', columnNames: ['cultivoId'] }),
    );
    await queryRunner.createIndex(
      'reglas',
      new TableIndex({ name: 'IDX_reglas_plaga', columnNames: ['plagaId'] }),
    );
    await queryRunner.createIndex(
      'reglas',
      new TableIndex({ name: 'IDX_reglas_activa', columnNames: ['activa'] }),
    );
    await queryRunner.createIndex(
      'reglas',
      new TableIndex({ name: 'IDX_reglas_prioridad', columnNames: ['prioridad'] }),
    );

    // ════════════════════════════════════════════════════════
    // TABLA: recomendaciones_aplicadas
    // ════════════════════════════════════════════════════════
    await queryRunner.createTable(
      new Table({
        name: 'recomendaciones_aplicadas',
        columns: [
          { name: 'id', type: 'uuid', isPrimary: true, default: 'gen_random_uuid()' },

          // FK a la regla que se aplico
          { name: 'reglaId', type: 'uuid', isNullable: false },

          // FK al lote donde se aplico
          { name: 'loteId', type: 'uuid', isNullable: false },

          // FK al usuario que la aplico (productor o admin)
          { name: 'userId', type: 'uuid', isNullable: false },

          // Decision tomada por el productor:
          // 'aplicada' | 'ignorada' | 'aplicada_diferente'
          { name: 'decision', type: 'varchar', length: '30', isNullable: false },

          // Nota libre del productor (opcional)
          { name: 'notaProductor', type: 'text', isNullable: true },

          // Cuando se mostro la recomendacion
          { name: 'fechaSugerida', type: 'timestamp with time zone', isNullable: false },

          // Cuando el productor decidio
          { name: 'fechaDecision', type: 'timestamp with time zone', isNullable: false },

          // Resultado posterior (opcional, lo llena el productor despues)
          { name: 'resultadoObservado', type: 'text', isNullable: true },

          { name: 'createdAt', type: 'timestamp with time zone', default: 'CURRENT_TIMESTAMP' },
          { name: 'updatedAt', type: 'timestamp with time zone', default: 'CURRENT_TIMESTAMP' },
        ],
      }),
      true,
    );

    await queryRunner.createForeignKey(
      'recomendaciones_aplicadas',
      new TableForeignKey({
        columnNames: ['reglaId'],
        referencedTableName: 'reglas',
        referencedColumnNames: ['id'],
        onDelete: 'CASCADE',
      }),
    );
    await queryRunner.createForeignKey(
      'recomendaciones_aplicadas',
      new TableForeignKey({
        columnNames: ['loteId'],
        referencedTableName: 'lotes',
        referencedColumnNames: ['id'],
        onDelete: 'CASCADE',
      }),
    );
    await queryRunner.createForeignKey(
      'recomendaciones_aplicadas',
      new TableForeignKey({
        columnNames: ['userId'],
        referencedTableName: 'users',
        referencedColumnNames: ['id'],
        onDelete: 'CASCADE',
      }),
    );
    await queryRunner.createIndex(
      'recomendaciones_aplicadas',
      new TableIndex({ name: 'IDX_recom_aplic_reglaId', columnNames: ['reglaId'] }),
    );
    await queryRunner.createIndex(
      'recomendaciones_aplicadas',
      new TableIndex({ name: 'IDX_recom_aplic_loteId', columnNames: ['loteId'] }),
    );
    await queryRunner.createIndex(
      'recomendaciones_aplicadas',
      new TableIndex({ name: 'IDX_recom_aplic_userId', columnNames: ['userId'] }),
    );
    await queryRunner.createIndex(
      'recomendaciones_aplicadas',
      new TableIndex({ name: 'IDX_recom_aplic_decision', columnNames: ['decision'] }),
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.dropTable('recomendaciones_aplicadas', true);
    await queryRunner.query(`DROP INDEX IF EXISTS "IDX_reglas_codigo_unique"`);
    await queryRunner.dropTable('reglas', true);
  }
}