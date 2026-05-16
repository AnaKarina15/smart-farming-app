import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

/// Helper singleton para la base de datos SQLite local (offline-first).
///
/// Tablas:
/// - lotes          → parcelas del productor (sincroniza con backend Sprint 1)
/// - sync_queue     → acciones pendientes de enviar al servidor
/// - siembras       → registros de siembra (Sprint 2 backend)
/// - riego          → registros de riego
/// - fertilizacion  → registros de fertilización
/// - hallazgos      → hallazgos fitosanitarios
/// - tratamientos   → tratamientos aplicados
/// - observaciones  → observaciones generales del campo
class DatabaseHelper {
  static const _databaseName = 'AgroField.db';
  static const _databaseVersion = 2;

  // Nombres de tablas
  static const tableLotes = 'lotes';
  static const tableSyncQueue = 'sync_queue';
  static const tableSiembras = 'siembras';
  static const tableRiego = 'riego';
  static const tableFertilizacion = 'fertilizacion';
  static const tableHallazgos = 'hallazgos';
  static const tableTratamientos = 'tratamientos';
  static const tableObservaciones = 'observaciones';

  // Singleton
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createAllTables(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Migración desde v1: agregar las nuevas tablas
      await _createSiembras(db);
      await _createRiego(db);
      await _createFertilizacion(db);
      await _createHallazgos(db);
      await _createTratamientos(db);
      await _createObservaciones(db);
    }
  }

  Future<void> _createAllTables(Database db) async {
    await _createLotes(db);
    await _createSyncQueue(db);
    await _createSiembras(db);
    await _createRiego(db);
    await _createFertilizacion(db);
    await _createHallazgos(db);
    await _createTratamientos(db);
    await _createObservaciones(db);
  }

  // ─── Tablas ───────────────────────────────────────────────

  Future<void> _createLotes(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableLotes (
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        descripcion TEXT,
        superficieHectareas REAL NOT NULL,
        cultivoActual TEXT,
        latitud REAL,
        longitud REAL,
        estado TEXT NOT NULL DEFAULT 'saludable',
        propietarioId TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        isPendingSync INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<void> _createSyncQueue(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableSyncQueue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        method TEXT NOT NULL,
        endpoint TEXT NOT NULL,
        payload TEXT,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createSiembras(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableSiembras (
        id TEXT PRIMARY KEY,
        loteId TEXT NOT NULL,
        loteNombre TEXT NOT NULL,
        cultivo TEXT NOT NULL,
        variedad TEXT,
        fecha TEXT NOT NULL,
        cantidadSemillas REAL,
        unidad TEXT,
        distanciaEntreFilas REAL,
        distanciaEntrePlantas REAL,
        observaciones TEXT,
        userId TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        isPendingSync INTEGER NOT NULL DEFAULT 1
      )
    ''');
  }

  Future<void> _createRiego(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableRiego (
        id TEXT PRIMARY KEY,
        loteId TEXT NOT NULL,
        loteNombre TEXT NOT NULL,
        tipo TEXT NOT NULL,
        duracionMinutos REAL,
        cantidadLitros REAL,
        fecha TEXT NOT NULL,
        humedad REAL,
        observaciones TEXT,
        userId TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        isPendingSync INTEGER NOT NULL DEFAULT 1
      )
    ''');
  }

  Future<void> _createFertilizacion(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableFertilizacion (
        id TEXT PRIMARY KEY,
        loteId TEXT NOT NULL,
        loteNombre TEXT NOT NULL,
        tipoFertilizante TEXT NOT NULL,
        nombre TEXT,
        dosis REAL,
        unidad TEXT,
        metodoAplicacion TEXT,
        fecha TEXT NOT NULL,
        observaciones TEXT,
        userId TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        isPendingSync INTEGER NOT NULL DEFAULT 1
      )
    ''');
  }

  Future<void> _createHallazgos(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableHallazgos (
        id TEXT PRIMARY KEY,
        loteId TEXT NOT NULL,
        loteNombre TEXT NOT NULL,
        tipo TEXT NOT NULL,
        severidad TEXT NOT NULL,
        descripcion TEXT,
        fotoPath TEXT,
        fecha TEXT NOT NULL,
        userId TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        isPendingSync INTEGER NOT NULL DEFAULT 1
      )
    ''');
  }

  Future<void> _createTratamientos(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableTratamientos (
        id TEXT PRIMARY KEY,
        hallazgoId TEXT,
        loteId TEXT NOT NULL,
        loteNombre TEXT NOT NULL,
        producto TEXT NOT NULL,
        dosis REAL,
        unidad TEXT,
        metodoAplicacion TEXT,
        fecha TEXT NOT NULL,
        observaciones TEXT,
        userId TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        isPendingSync INTEGER NOT NULL DEFAULT 1
      )
    ''');
  }

  Future<void> _createObservaciones(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableObservaciones (
        id TEXT PRIMARY KEY,
        loteId TEXT NOT NULL,
        loteNombre TEXT NOT NULL,
        descripcion TEXT NOT NULL,
        tipo TEXT,
        fecha TEXT NOT NULL,
        userId TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        isPendingSync INTEGER NOT NULL DEFAULT 1
      )
    ''');
  }

  // ─── Operaciones genéricas ─────────────────────────────────

  Future<int> insert(String table, Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert(table, row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> queryAllRows(String table) async {
    final db = await database;
    return await db.query(table);
  }

  Future<List<Map<String, dynamic>>> queryWhere(
    String table,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await database;
    return await db.query(table, where: where, whereArgs: whereArgs);
  }

  Future<int> update(
    String table,
    Map<String, dynamic> row,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await database;
    return await db.update(table, row, where: where, whereArgs: whereArgs);
  }

  Future<int> deleteById(String table, String id) async {
    final db = await database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteWhere(String table, String where, List<dynamic> whereArgs) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<void> clearTable(String table) async {
    final db = await database;
    await db.delete(table);
  }

  // ─── Lotes ────────────────────────────────────────────────

  Future<void> upsertLotes(List<Map<String, dynamic>> lotes) async {
    final db = await database;
    final batch = db.batch();
    for (final lote in lotes) {
      batch.insert(tableLotes, lote, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getLotes() async {
    final db = await database;
    return await db.query(tableLotes, orderBy: 'nombre ASC');
  }

  Future<int> getPendingSyncCount() async {
    final db = await database;
    int total = 0;
    final tables = [
      tableSyncQueue,
      tableSiembras,
      tableRiego,
      tableFertilizacion,
      tableHallazgos,
      tableTratamientos,
      tableObservaciones,
    ];
    for (final t in tables) {
      try {
        final result = await db.rawQuery(
          'SELECT COUNT(*) as count FROM $t WHERE isPendingSync = 1',
        );
        total += (result.first['count'] as int? ?? 0);
      } catch (_) {
        // sync_queue no tiene isPendingSync
        if (t == tableSyncQueue) {
          final r = await db.rawQuery('SELECT COUNT(*) as count FROM $t');
          total += (r.first['count'] as int? ?? 0);
        }
      }
    }
    return total;
  }
}
