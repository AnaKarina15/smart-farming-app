import { MigrationInterface, QueryRunner, Table, TableForeignKey, TableIndex } from 'typeorm';

/**
 * Sprint 3 - Modulos operativos profesionales.
 *
 * Crea las 6 tablas de operaciones agricolas del Pequeno Productor:
 * - siembras       → registro de siembras (con FK a cultivos)
 * - riego          → registro de riegos
 * - fertilizacion  → aplicacion de fertilizantes (con FK a fertilizantes)
 * - hallazgos      → hallazgos fitosanitarios (con FK a plagas)
 * - tratamientos   → tratamientos aplicados (con FK opcional a hallazgos)
 * - observaciones  → notas libres del campo
 *
 * Convenciones de diseno:
 * - Todas las tablas tienen FK a `lotes` con ON DELETE CASCADE.
 * - FKs a catalogos con ON DELETE SET NULL para preservar historico.
 * - userId guarda el dueno del registro (siempre del JWT, nunca del body).
 * - Soft-delete con deletedAt.
 * - Campo `xxxOtro` (escape valve) para cuando el productor escribe algo no listado.
 *
 * Idempotente: usa createTable que internamente verifica existencia.
 */
export class AddOperacionesOperativas1716500000000 implements MigrationInterface {
  name = 'AddOperacionesOperativas1716500000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    // ════════════════════════════════════════════════════════
    // TABLA: siembras
    // ════════════════════════════════════════════════════════
    await queryRunner.createTable(
      new Table({
        name: 'siembras',
        columns: [
          { name: 'id', type: 'uuid', isPrimary: true, default: 'gen_random_uuid()' },
          { name: 'loteId', type: 'uuid', isNullable: false },
          { name: 'cultivoId', type: 'uuid', isNullable: true },
          { name: 'cultivoOtro', type: 'varchar', length: '100', isNullable: true },
          { name: 'variedad', type: 'varchar', length: '100', isNullable: true },
          { name: 'fecha', type: 'timestamp with time zone', isNullable: false },
          { name: 'cantidadSemillas', type: 'numeric', precision: 12, scale: 2, isNullable: true },
          { name: 'unidad', type: 'varchar', length: '30', isNullable: true },
          {
            name: 'distanciaEntreFilas',
            type: 'numeric',
            precision: 6,
            scale: 2,
            isNullable: true,
          },
          {
            name: 'distanciaEntrePlantas',
            type: 'numeric',
            precision: 6,
            scale: 2,
            isNullable: true,
          },
          { name: 'observaciones', type: 'text', isNullable: true },
          { name: 'userId', type: 'uuid', isNullable: false },
          { name: 'createdAt', type: 'timestamp with time zone', default: 'CURRENT_TIMESTAMP' },
          { name: 'updatedAt', type: 'timestamp with time zone', default: 'CURRENT_TIMESTAMP' },
          { name: 'deletedAt', type: 'timestamp with time zone', isNullable: true },
        ],
      }),
      true,
    );

    await queryRunner.createForeignKey(
      'siembras',
      new TableForeignKey({
        columnNames: ['loteId'],
        referencedTableName: 'lotes',
        referencedColumnNames: ['id'],
        onDelete: 'CASCADE',
      }),
    );
    await queryRunner.createForeignKey(
      'siembras',
      new TableForeignKey({
        columnNames: ['cultivoId'],
        referencedTableName: 'cultivos',
        referencedColumnNames: ['id'],
        onDelete: 'SET NULL',
      }),
    );
    await queryRunner.createForeignKey(
      'siembras',
      new TableForeignKey({
        columnNames: ['userId'],
        referencedTableName: 'users',
        referencedColumnNames: ['id'],
        onDelete: 'CASCADE',
      }),
    );
    await queryRunner.createIndex(
      'siembras',
      new TableIndex({ name: 'IDX_siembras_loteId', columnNames: ['loteId'] }),
    );
    await queryRunner.createIndex(
      'siembras',
      new TableIndex({ name: 'IDX_siembras_userId', columnNames: ['userId'] }),
    );
    await queryRunner.createIndex(
      'siembras',
      new TableIndex({ name: 'IDX_siembras_fecha', columnNames: ['fecha'] }),
    );

    // ════════════════════════════════════════════════════════
    // TABLA: riego
    // ════════════════════════════════════════════════════════
    await queryRunner.createTable(
      new Table({
        name: 'riego',
        columns: [
          { name: 'id', type: 'uuid', isPrimary: true, default: 'gen_random_uuid()' },
          { name: 'loteId', type: 'uuid', isNullable: false },
          { name: 'tipo', type: 'varchar', length: '50', isNullable: false },
          { name: 'duracionMinutos', type: 'numeric', precision: 10, scale: 2, isNullable: true },
          { name: 'cantidadLitros', type: 'numeric', precision: 12, scale: 2, isNullable: true },
          { name: 'fecha', type: 'timestamp with time zone', isNullable: false },
          { name: 'humedad', type: 'numeric', precision: 5, scale: 2, isNullable: true },
          { name: 'observaciones', type: 'text', isNullable: true },
          { name: 'userId', type: 'uuid', isNullable: false },
          { name: 'createdAt', type: 'timestamp with time zone', default: 'CURRENT_TIMESTAMP' },
          { name: 'updatedAt', type: 'timestamp with time zone', default: 'CURRENT_TIMESTAMP' },
          { name: 'deletedAt', type: 'timestamp with time zone', isNullable: true },
        ],
      }),
      true,
    );

    await queryRunner.createForeignKey(
      'riego',
      new TableForeignKey({
        columnNames: ['loteId'],
        referencedTableName: 'lotes',
        referencedColumnNames: ['id'],
        onDelete: 'CASCADE',
      }),
    );
    await queryRunner.createForeignKey(
      'riego',
      new TableForeignKey({
        columnNames: ['userId'],
        referencedTableName: 'users',
        referencedColumnNames: ['id'],
        onDelete: 'CASCADE',
      }),
    );
    await queryRunner.createIndex(
      'riego',
      new TableIndex({ name: 'IDX_riego_loteId', columnNames: ['loteId'] }),
    );
    await queryRunner.createIndex(
      'riego',
      new TableIndex({ name: 'IDX_riego_userId', columnNames: ['userId'] }),
    );
    await queryRunner.createIndex(
      'riego',
      new TableIndex({ name: 'IDX_riego_fecha', columnNames: ['fecha'] }),
    );

    // ════════════════════════════════════════════════════════
    // TABLA: fertilizacion
    // ════════════════════════════════════════════════════════
    await queryRunner.createTable(
      new Table({
        name: 'fertilizacion',
        columns: [
          { name: 'id', type: 'uuid', isPrimary: true, default: 'gen_random_uuid()' },
          { name: 'loteId', type: 'uuid', isNullable: false },
          { name: 'fertilizanteId', type: 'uuid', isNullable: true },
          { name: 'fertilizanteOtro', type: 'varchar', length: '100', isNullable: true },
          { name: 'dosis', type: 'numeric', precision: 12, scale: 2, isNullable: true },
          { name: 'unidad', type: 'varchar', length: '30', isNullable: true },
          { name: 'metodoAplicacion', type: 'varchar', length: '50', isNullable: true },
          { name: 'fecha', type: 'timestamp with time zone', isNullable: false },
          { name: 'observaciones', type: 'text', isNullable: true },
          { name: 'userId', type: 'uuid', isNullable: false },
          { name: 'createdAt', type: 'timestamp with time zone', default: 'CURRENT_TIMESTAMP' },
          { name: 'updatedAt', type: 'timestamp with time zone', default: 'CURRENT_TIMESTAMP' },
          { name: 'deletedAt', type: 'timestamp with time zone', isNullable: true },
        ],
      }),
      true,
    );

    await queryRunner.createForeignKey(
      'fertilizacion',
      new TableForeignKey({
        columnNames: ['loteId'],
        referencedTableName: 'lotes',
        referencedColumnNames: ['id'],
        onDelete: 'CASCADE',
      }),
    );
    await queryRunner.createForeignKey(
      'fertilizacion',
      new TableForeignKey({
        columnNames: ['fertilizanteId'],
        referencedTableName: 'fertilizantes',
        referencedColumnNames: ['id'],
        onDelete: 'SET NULL',
      }),
    );
    await queryRunner.createForeignKey(
      'fertilizacion',
      new TableForeignKey({
        columnNames: ['userId'],
        referencedTableName: 'users',
        referencedColumnNames: ['id'],
        onDelete: 'CASCADE',
      }),
    );
    await queryRunner.createIndex(
      'fertilizacion',
      new TableIndex({ name: 'IDX_fertilizacion_loteId', columnNames: ['loteId'] }),
    );
    await queryRunner.createIndex(
      'fertilizacion',
      new TableIndex({ name: 'IDX_fertilizacion_userId', columnNames: ['userId'] }),
    );
    await queryRunner.createIndex(
      'fertilizacion',
      new TableIndex({ name: 'IDX_fertilizacion_fecha', columnNames: ['fecha'] }),
    );

    // ════════════════════════════════════════════════════════
    // TABLA: hallazgos
    // ════════════════════════════════════════════════════════
    await queryRunner.createTable(
      new Table({
        name: 'hallazgos',
        columns: [
          { name: 'id', type: 'uuid', isPrimary: true, default: 'gen_random_uuid()' },
          { name: 'loteId', type: 'uuid', isNullable: false },
          { name: 'plagaId', type: 'uuid', isNullable: true },
          { name: 'plagaOtro', type: 'varchar', length: '100', isNullable: true },
          { name: 'severidad', type: 'varchar', length: '20', isNullable: false },
          { name: 'descripcion', type: 'text', isNullable: true },
          { name: 'fotoPath', type: 'varchar', length: '500', isNullable: true },
          { name: 'fecha', type: 'timestamp with time zone', isNullable: false },
          { name: 'userId', type: 'uuid', isNullable: false },
          { name: 'createdAt', type: 'timestamp with time zone', default: 'CURRENT_TIMESTAMP' },
          { name: 'updatedAt', type: 'timestamp with time zone', default: 'CURRENT_TIMESTAMP' },
          { name: 'deletedAt', type: 'timestamp with time zone', isNullable: true },
        ],
      }),
      true,
    );

    await queryRunner.createForeignKey(
      'hallazgos',
      new TableForeignKey({
        columnNames: ['loteId'],
        referencedTableName: 'lotes',
        referencedColumnNames: ['id'],
        onDelete: 'CASCADE',
      }),
    );
    await queryRunner.createForeignKey(
      'hallazgos',
      new TableForeignKey({
        columnNames: ['plagaId'],
        referencedTableName: 'plagas',
        referencedColumnNames: ['id'],
        onDelete: 'SET NULL',
      }),
    );
    await queryRunner.createForeignKey(
      'hallazgos',
      new TableForeignKey({
        columnNames: ['userId'],
        referencedTableName: 'users',
        referencedColumnNames: ['id'],
        onDelete: 'CASCADE',
      }),
    );
    await queryRunner.createIndex(
      'hallazgos',
      new TableIndex({ name: 'IDX_hallazgos_loteId', columnNames: ['loteId'] }),
    );
    await queryRunner.createIndex(
      'hallazgos',
      new TableIndex({ name: 'IDX_hallazgos_userId', columnNames: ['userId'] }),
    );
    await queryRunner.createIndex(
      'hallazgos',
      new TableIndex({ name: 'IDX_hallazgos_fecha', columnNames: ['fecha'] }),
    );
    await queryRunner.createIndex(
      'hallazgos',
      new TableIndex({ name: 'IDX_hallazgos_severidad', columnNames: ['severidad'] }),
    );

    // ════════════════════════════════════════════════════════
    // TABLA: tratamientos
    // ════════════════════════════════════════════════════════
    await queryRunner.createTable(
      new Table({
        name: 'tratamientos',
        columns: [
          { name: 'id', type: 'uuid', isPrimary: true, default: 'gen_random_uuid()' },
          { name: 'loteId', type: 'uuid', isNullable: false },
          { name: 'hallazgoId', type: 'uuid', isNullable: true },
          { name: 'producto', type: 'varchar', length: '150', isNullable: false },
          { name: 'dosis', type: 'numeric', precision: 12, scale: 2, isNullable: true },
          { name: 'unidad', type: 'varchar', length: '30', isNullable: true },
          { name: 'metodoAplicacion', type: 'varchar', length: '50', isNullable: true },
          { name: 'fecha', type: 'timestamp with time zone', isNullable: false },
          { name: 'observaciones', type: 'text', isNullable: true },
          { name: 'userId', type: 'uuid', isNullable: false },
          { name: 'createdAt', type: 'timestamp with time zone', default: 'CURRENT_TIMESTAMP' },
          { name: 'updatedAt', type: 'timestamp with time zone', default: 'CURRENT_TIMESTAMP' },
          { name: 'deletedAt', type: 'timestamp with time zone', isNullable: true },
        ],
      }),
      true,
    );

    await queryRunner.createForeignKey(
      'tratamientos',
      new TableForeignKey({
        columnNames: ['loteId'],
        referencedTableName: 'lotes',
        referencedColumnNames: ['id'],
        onDelete: 'CASCADE',
      }),
    );
    await queryRunner.createForeignKey(
      'tratamientos',
      new TableForeignKey({
        columnNames: ['hallazgoId'],
        referencedTableName: 'hallazgos',
        referencedColumnNames: ['id'],
        onDelete: 'SET NULL',
      }),
    );
    await queryRunner.createForeignKey(
      'tratamientos',
      new TableForeignKey({
        columnNames: ['userId'],
        referencedTableName: 'users',
        referencedColumnNames: ['id'],
        onDelete: 'CASCADE',
      }),
    );
    await queryRunner.createIndex(
      'tratamientos',
      new TableIndex({ name: 'IDX_tratamientos_loteId', columnNames: ['loteId'] }),
    );
    await queryRunner.createIndex(
      'tratamientos',
      new TableIndex({ name: 'IDX_tratamientos_userId', columnNames: ['userId'] }),
    );
    await queryRunner.createIndex(
      'tratamientos',
      new TableIndex({ name: 'IDX_tratamientos_fecha', columnNames: ['fecha'] }),
    );

    // ════════════════════════════════════════════════════════
    // TABLA: observaciones
    // ════════════════════════════════════════════════════════
    await queryRunner.createTable(
      new Table({
        name: 'observaciones',
        columns: [
          { name: 'id', type: 'uuid', isPrimary: true, default: 'gen_random_uuid()' },
          { name: 'loteId', type: 'uuid', isNullable: false },
          { name: 'descripcion', type: 'text', isNullable: false },
          { name: 'tipo', type: 'varchar', length: '50', isNullable: true },
          { name: 'fecha', type: 'timestamp with time zone', isNullable: false },
          { name: 'userId', type: 'uuid', isNullable: false },
          { name: 'createdAt', type: 'timestamp with time zone', default: 'CURRENT_TIMESTAMP' },
          { name: 'updatedAt', type: 'timestamp with time zone', default: 'CURRENT_TIMESTAMP' },
          { name: 'deletedAt', type: 'timestamp with time zone', isNullable: true },
        ],
      }),
      true,
    );

    await queryRunner.createForeignKey(
      'observaciones',
      new TableForeignKey({
        columnNames: ['loteId'],
        referencedTableName: 'lotes',
        referencedColumnNames: ['id'],
        onDelete: 'CASCADE',
      }),
    );
    await queryRunner.createForeignKey(
      'observaciones',
      new TableForeignKey({
        columnNames: ['userId'],
        referencedTableName: 'users',
        referencedColumnNames: ['id'],
        onDelete: 'CASCADE',
      }),
    );
    await queryRunner.createIndex(
      'observaciones',
      new TableIndex({ name: 'IDX_observaciones_loteId', columnNames: ['loteId'] }),
    );
    await queryRunner.createIndex(
      'observaciones',
      new TableIndex({ name: 'IDX_observaciones_userId', columnNames: ['userId'] }),
    );
    await queryRunner.createIndex(
      'observaciones',
      new TableIndex({ name: 'IDX_observaciones_fecha', columnNames: ['fecha'] }),
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    // Drop en orden inverso (tratamientos depende de hallazgos)
    await queryRunner.dropTable('observaciones');
    await queryRunner.dropTable('tratamientos');
    await queryRunner.dropTable('hallazgos');
    await queryRunner.dropTable('fertilizacion');
    await queryRunner.dropTable('riego');
    await queryRunner.dropTable('siembras');
  }
}
