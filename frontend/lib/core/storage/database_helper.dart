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
  static const _databaseVersion = 10;

  // Nombres de tablas
  static const tableLotes = 'lotes';
  static const tableSyncQueue = 'sync_queue';
  static const tableSiembras = 'siembras';
  static const tableRiego = 'riego';
  static const tableFertilizacion = 'fertilizacion';
  static const tableHallazgos = 'hallazgos';
  static const tableTratamientos = 'tratamientos';
  static const tableObservaciones = 'observaciones';
  static const tableEstadoTerreno = 'estado_terreno';

  // Catálogos (Sprint 2)
  static const tableCatCultivos = 'catalogo_cultivos';
  static const tableCatMunicipios = 'catalogo_municipios';
  static const tableCatPlagas = 'catalogo_plagas';
  static const tableCatFertilizantes = 'catalogo_fertilizantes';
  static const tableCatTiposSuelo = 'catalogo_tipos_suelo';

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
    await _seedCatalogos(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createSiembras(db);
      await _createRiego(db);
      await _createFertilizacion(db);
      await _createHallazgos(db);
      await _createTratamientos(db);
      await _createObservaciones(db);
    }
    if (oldVersion < 3) {
      // Sprint 2: Catálogos y cambios en lotes
      await _createCatalogoCultivos(db);
      await _createCatalogoMunicipios(db);
      await _createCatalogoPlagas(db);
      await _createCatalogoFertilizantes(db);
      await _createCatalogoTiposSuelo(db);
      
      // Agregar columnas a lotes
      await db.execute('ALTER TABLE $tableLotes ADD COLUMN cultivoActualId TEXT');
      await db.execute('ALTER TABLE $tableLotes ADD COLUMN municipioId TEXT');
    }
    if (oldVersion < 4) {
      // Sprint 2: IDs de catálogos en tareas
      await db.execute('ALTER TABLE $tableSiembras ADD COLUMN cultivoId TEXT');
      await db.execute('ALTER TABLE $tableFertilizacion ADD COLUMN fertilizanteId TEXT');
    }
    if (oldVersion < 5) {
      // Sprint 3: Agregar serverId, syncError, y campos 'Otro'
      await db.execute('ALTER TABLE $tableSiembras ADD COLUMN cultivoOtro TEXT');
      await db.execute('ALTER TABLE $tableSiembras ADD COLUMN serverId TEXT');
      await db.execute('ALTER TABLE $tableSiembras ADD COLUMN syncError TEXT');

      await db.execute('ALTER TABLE $tableRiego ADD COLUMN serverId TEXT');
      await db.execute('ALTER TABLE $tableRiego ADD COLUMN syncError TEXT');

      await db.execute('ALTER TABLE $tableFertilizacion ADD COLUMN fertilizanteOtro TEXT');
      await db.execute('ALTER TABLE $tableFertilizacion ADD COLUMN serverId TEXT');
      await db.execute('ALTER TABLE $tableFertilizacion ADD COLUMN syncError TEXT');

      await db.execute('ALTER TABLE $tableHallazgos ADD COLUMN plagaId TEXT');
      await db.execute('ALTER TABLE $tableHallazgos ADD COLUMN plagaOtro TEXT');
      await db.execute('ALTER TABLE $tableHallazgos ADD COLUMN serverId TEXT');
      await db.execute('ALTER TABLE $tableHallazgos ADD COLUMN syncError TEXT');

      await db.execute('ALTER TABLE $tableTratamientos ADD COLUMN serverId TEXT');
      await db.execute('ALTER TABLE $tableTratamientos ADD COLUMN syncError TEXT');

      await db.execute('ALTER TABLE $tableObservaciones ADD COLUMN serverId TEXT');
      await db.execute('ALTER TABLE $tableObservaciones ADD COLUMN syncError TEXT');
    }
    if (oldVersion < 6) {
      // Sprint 3: Datos semilla para catálogos offline + tipo de suelo en lotes
      try {
        await db.execute('ALTER TABLE $tableLotes ADD COLUMN tipoSueloId TEXT');
      } catch (_) {} // Columna ya existe
      await _seedCatalogos(db);
    }
    if (oldVersion < 7) {
      // Sprint 4: Tabla de estado del terreno vinculada a lote y siembra
      await _createEstadoTerreno(db);
    }
    if (oldVersion < 8) {
      try {
        await db.execute('ALTER TABLE $tableLotes ADD COLUMN isPendingSync INTEGER NOT NULL DEFAULT 0');
      } catch (_) {}
    }
    if (oldVersion < 9) {
      // Parche para asegurar que estas columnas existan en todos los dispositivos
      try {
        await db.execute('ALTER TABLE $tableLotes ADD COLUMN cultivoActualId TEXT');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE $tableLotes ADD COLUMN municipioId TEXT');
      } catch (_) {}
    }
    if (oldVersion < 10) {
      try {
        await db.execute('ALTER TABLE $tableObservaciones ADD COLUMN fotoPath TEXT');
      } catch (_) {}
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
    // Catálogos
    await _createCatalogoCultivos(db);
    await _createCatalogoMunicipios(db);
    await _createCatalogoPlagas(db);
    await _createCatalogoFertilizantes(db);
    await _createCatalogoTiposSuelo(db);
    await _createEstadoTerreno(db);
  }

  // ─── Datos semilla (offline-first) ────────────────────────
  Future<void> _seedCatalogos(Database db) async {
    // Solo insertar si las tablas están vacías
    final existing = await db.rawQuery('SELECT COUNT(*) as c FROM $tableCatMunicipios');
    if ((existing.first['c'] as int? ?? 0) > 0) return;

    final batch = db.batch();
    final now = DateTime.now().toIso8601String();

    // ── 30 Municipios del Magdalena (DANE) ──────────────────
    final municipios = [
      {'id': 'mun-001', 'codigoDane': '47001', 'nombre': 'Santa Marta', 'subregion': 'Santa Marta', 'latitud': 11.2408, 'longitud': -74.1990},
      {'id': 'mun-002', 'codigoDane': '47030', 'nombre': 'Algarrobo', 'subregion': 'Río Ariguaní', 'latitud': 10.1600, 'longitud': -74.0850},
      {'id': 'mun-003', 'codigoDane': '47053', 'nombre': 'Aracataca', 'subregion': 'Zona Bananera', 'latitud': 10.5922, 'longitud': -74.1889},
      {'id': 'mun-004', 'codigoDane': '47058', 'nombre': 'Ariguaní', 'subregion': 'Río Ariguaní', 'latitud': 9.8500, 'longitud': -74.0667},
      {'id': 'mun-005', 'codigoDane': '47161', 'nombre': 'Cerro de San Antonio', 'subregion': 'Sur', 'latitud': 10.3250, 'longitud': -74.8625},
      {'id': 'mun-006', 'codigoDane': '47170', 'nombre': 'Chibolo', 'subregion': 'Sur', 'latitud': 10.0239, 'longitud': -74.6264},
      {'id': 'mun-007', 'codigoDane': '47189', 'nombre': 'Ciénaga', 'subregion': 'Zona Bananera', 'latitud': 11.0069, 'longitud': -74.2486},
      {'id': 'mun-008', 'codigoDane': '47205', 'nombre': 'Concordia', 'subregion': 'Sur', 'latitud': 10.2900, 'longitud': -74.7750},
      {'id': 'mun-009', 'codigoDane': '47245', 'nombre': 'El Banco', 'subregion': 'Sur', 'latitud': 9.0008, 'longitud': -73.9786},
      {'id': 'mun-010', 'codigoDane': '47258', 'nombre': 'El Piñón', 'subregion': 'Sur', 'latitud': 10.3994, 'longitud': -74.9592},
      {'id': 'mun-011', 'codigoDane': '47268', 'nombre': 'El Retén', 'subregion': 'Zona Bananera', 'latitud': 10.6117, 'longitud': -74.2694},
      {'id': 'mun-012', 'codigoDane': '47288', 'nombre': 'Fundación', 'subregion': 'Zona Bananera', 'latitud': 10.5206, 'longitud': -74.1847},
      {'id': 'mun-013', 'codigoDane': '47318', 'nombre': 'Guamal', 'subregion': 'Sur', 'latitud': 9.1456, 'longitud': -74.2231},
      {'id': 'mun-014', 'codigoDane': '47460', 'nombre': 'Nueva Granada', 'subregion': 'Río Ariguaní', 'latitud': 10.0333, 'longitud': -74.3833},
      {'id': 'mun-015', 'codigoDane': '47541', 'nombre': 'Pedraza', 'subregion': 'Sur', 'latitud': 10.1872, 'longitud': -74.9103},
      {'id': 'mun-016', 'codigoDane': '47545', 'nombre': 'Pijiño del Carmen', 'subregion': 'Sur', 'latitud': 9.3292, 'longitud': -74.4553},
      {'id': 'mun-017', 'codigoDane': '47551', 'nombre': 'Pivijay', 'subregion': 'Río Ariguaní', 'latitud': 10.4622, 'longitud': -74.6158},
      {'id': 'mun-018', 'codigoDane': '47555', 'nombre': 'Plato', 'subregion': 'Sur', 'latitud': 9.7933, 'longitud': -74.7861},
      {'id': 'mun-019', 'codigoDane': '47570', 'nombre': 'Pueblo Viejo', 'subregion': 'Zona Bananera', 'latitud': 10.9939, 'longitud': -74.2833},
      {'id': 'mun-020', 'codigoDane': '47605', 'nombre': 'Remolino', 'subregion': 'Sur', 'latitud': 10.6833, 'longitud': -74.7167},
      {'id': 'mun-021', 'codigoDane': '47660', 'nombre': 'Sabanas de San Ángel', 'subregion': 'Río Ariguaní', 'latitud': 10.0000, 'longitud': -74.2167},
      {'id': 'mun-022', 'codigoDane': '47675', 'nombre': 'Salamina', 'subregion': 'Sur', 'latitud': 10.4972, 'longitud': -74.7925},
      {'id': 'mun-023', 'codigoDane': '47692', 'nombre': 'San Sebastián de Buenavista', 'subregion': 'Sur', 'latitud': 9.2403, 'longitud': -74.3803},
      {'id': 'mun-024', 'codigoDane': '47703', 'nombre': 'San Zenón', 'subregion': 'Sur', 'latitud': 9.2394, 'longitud': -74.5000},
      {'id': 'mun-025', 'codigoDane': '47707', 'nombre': 'Santa Ana', 'subregion': 'Sur', 'latitud': 9.3247, 'longitud': -74.5714},
      {'id': 'mun-026', 'codigoDane': '47720', 'nombre': 'Santa Bárbara de Pinto', 'subregion': 'Sur', 'latitud': 9.4428, 'longitud': -74.6972},
      {'id': 'mun-027', 'codigoDane': '47745', 'nombre': 'Sitionuevo', 'subregion': 'Sur', 'latitud': 10.7764, 'longitud': -74.8681},
      {'id': 'mun-028', 'codigoDane': '47798', 'nombre': 'Tenerife', 'subregion': 'Sur', 'latitud': 9.8994, 'longitud': -74.8575},
      {'id': 'mun-029', 'codigoDane': '47960', 'nombre': 'Zapayán', 'subregion': 'Sur', 'latitud': 10.2036, 'longitud': -74.8508},
      {'id': 'mun-030', 'codigoDane': '47980', 'nombre': 'Zona Bananera', 'subregion': 'Zona Bananera', 'latitud': 10.7500, 'longitud': -74.1500},
    ];

    for (final m in municipios) {
      batch.insert(tableCatMunicipios, {...m, 'activo': 1, 'syncedAt': now},
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    // ── Cultivos comunes del Magdalena ───────────────────────
    final cultivos = [
      {'id': 'cul-001', 'nombre': 'Banano', 'categoria': 'Fruta', 'descripcion': 'Cultivo principal de la Zona Bananera'},
      {'id': 'cul-002', 'nombre': 'Palma de aceite', 'categoria': 'Oleaginosa', 'descripcion': 'Palma africana para extracción de aceite'},
      {'id': 'cul-003', 'nombre': 'Café', 'categoria': 'Bebida', 'descripcion': 'Café arábica de la Sierra Nevada'},
      {'id': 'cul-004', 'nombre': 'Cacao', 'categoria': 'Bebida', 'descripcion': 'Cacao fino de aroma'},
      {'id': 'cul-005', 'nombre': 'Arroz', 'categoria': 'Cereal', 'descripcion': 'Arroz paddy riego y secano'},
      {'id': 'cul-006', 'nombre': 'Maíz', 'categoria': 'Cereal', 'descripcion': 'Maíz tradicional y tecnificado'},
      {'id': 'cul-007', 'nombre': 'Yuca', 'categoria': 'Tubérculo', 'descripcion': 'Yuca para consumo y agroindustria'},
      {'id': 'cul-008', 'nombre': 'Mango', 'categoria': 'Fruta', 'descripcion': 'Mango de azúcar, Tommy, Keitt'},
      {'id': 'cul-009', 'nombre': 'Tomate', 'categoria': 'Hortaliza', 'descripcion': 'Tomate bajo invernadero y a campo abierto'},
      {'id': 'cul-010', 'nombre': 'Ají', 'categoria': 'Hortaliza', 'descripcion': 'Ají dulce y picante'},
      {'id': 'cul-011', 'nombre': 'Plátano', 'categoria': 'Fruta', 'descripcion': 'Plátano hartón y dominico'},
      {'id': 'cul-012', 'nombre': 'Sorgo', 'categoria': 'Cereal', 'descripcion': 'Sorgo para alimentación animal'},
      {'id': 'cul-013', 'nombre': 'Algodón', 'categoria': 'Fibra', 'descripcion': 'Algodón upland'},
      {'id': 'cul-014', 'nombre': 'Frijol', 'categoria': 'Leguminosa', 'descripcion': 'Frijol zaragoza y caupí'},
      {'id': 'cul-015', 'nombre': 'Aguacate', 'categoria': 'Fruta', 'descripcion': 'Aguacate Hass y criollo'},
      {'id': 'cul-016', 'nombre': 'Limón', 'categoria': 'Cítrico', 'descripcion': 'Limón Tahití'},
      {'id': 'cul-017', 'nombre': 'Naranja', 'categoria': 'Cítrico', 'descripcion': 'Naranja Valencia'},
      {'id': 'cul-018', 'nombre': 'Guayaba', 'categoria': 'Fruta', 'descripcion': 'Guayaba pera y agria'},
      {'id': 'cul-019', 'nombre': 'Papaya', 'categoria': 'Fruta', 'descripcion': 'Papaya maradol'},
      {'id': 'cul-020', 'nombre': 'Ñame', 'categoria': 'Tubérculo', 'descripcion': 'Ñame espino y diamante'},
    ];

    for (final c in cultivos) {
      batch.insert(tableCatCultivos, {...c, 'activo': 1, 'syncedAt': now},
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    // ── Plagas comunes del Magdalena ─────────────────────────
    final plagas = [
      {'id': 'pla-001', 'nombre': 'Sigatoka negra', 'nombreCientifico': 'Mycosphaerella fijiensis', 'tipo': 'hongo', 'severidadTipica': 'critica', 'sintomas': 'Manchas alargadas color cafe oscuro a negro en hojas, defoliacion progresiva, racimos pequeños y maduracion prematura.', 'cultivosAfectados': 'Banano, Plátano'},
      {'id': 'pla-002', 'nombre': 'Picudo del banano', 'nombreCientifico': 'Cosmopolites sordidus', 'tipo': 'insecto', 'severidadTipica': 'alta', 'sintomas': 'Galerias en el corm/rizoma, plantas debiles que se voltean por viento. Adulto: cucarron negro de 1 cm.', 'cultivosAfectados': 'Banano, Plátano'},
      {'id': 'pla-003', 'nombre': 'Gusano cogollero', 'nombreCientifico': 'Spodoptera frugiperda', 'tipo': 'insecto', 'severidadTipica': 'alta', 'sintomas': 'Hojas con perforaciones irregulares, presencia de excrementos en el cogollo, larvas verdes con cabeza oscura.', 'cultivosAfectados': 'Maíz, Sorgo, Arroz'},
      {'id': 'pla-004', 'nombre': 'Mosca blanca', 'nombreCientifico': 'Bemisia tabaci', 'tipo': 'insecto', 'severidadTipica': 'alta', 'sintomas': 'Adultos blancos volando al sacudir la planta, hojas amarillentas, fumagina (hongo negro) por melaza. Transmite virus.', 'cultivosAfectados': 'Yuca, Frijol, Ahuyama, Patilla, Tomate'},
      {'id': 'pla-005', 'nombre': 'Antracnosis', 'nombreCientifico': 'Colletotrichum spp.', 'tipo': 'hongo', 'severidadTipica': 'alta', 'sintomas': 'Manchas circulares hundidas y oscuras en frutos, hojas con lesiones cafe de aspecto quemado. Frecuente en epoca lluviosa.', 'cultivosAfectados': 'Mango, Aguacate, Banano, Plátano, Cacao'},
      {'id': 'pla-006', 'nombre': 'Broca del café', 'nombreCientifico': 'Hypothenemus hampei', 'tipo': 'insecto', 'severidadTipica': 'critica', 'sintomas': 'Perforación circular en cereza/grano de café, granos vanos o dañados. Reduce calidad y peso.', 'cultivosAfectados': 'Café'},
      {'id': 'pla-007', 'nombre': 'Roya del café', 'nombreCientifico': 'Hemileia vastatrix', 'tipo': 'hongo', 'severidadTipica': 'alta', 'sintomas': 'Manchas amarillo-naranja con polvo en el envés de las hojas, defoliación severa, pérdida de producción.', 'cultivosAfectados': 'Café'},
      {'id': 'pla-008', 'nombre': 'Trips', 'nombreCientifico': 'Frankliniella occidentalis', 'tipo': 'insecto', 'severidadTipica': 'media', 'sintomas': 'Manchas plateadas en hojas and frutos, puntos negros (excrementos), deformación de frutos jóvenes.', 'cultivosAfectados': 'Aguacate, Mango, Patilla, Frijol'},
      {'id': 'pla-009', 'nombre': 'Minador de hojas', 'nombreCientifico': 'Liriomyza spp.', 'tipo': 'insecto', 'severidadTipica': 'media', 'sintomas': 'Galerías o canales serpenteantes y blanquecinos en las hojas por alimentación de las larvas.', 'cultivosAfectados': 'Tomate, Papa, Frijol, Hortalizas'},
      {'id': 'pla-010', 'nombre': 'Áfidos (pulgones)', 'nombreCientifico': 'Aphis spp.', 'tipo': 'insecto', 'severidadTipica': 'media', 'sintomas': 'Colonias en envés de hojas y brotes nuevos, hojas enrolladas, presencia de melaza y hormigas.', 'cultivosAfectados': 'Maíz, Frijol, Hortalizas, Cítricos'},
      {'id': 'pla-011', 'nombre': 'Marchitez bacteriana', 'nombreCientifico': 'Ralstonia solanacearum', 'tipo': 'bacteria', 'severidadTipica': 'alta', 'sintomas': 'Marchitez repentina del follaje durante las horas más calurosas del día sin amarillamiento previo, pudrición vascular.', 'cultivosAfectados': 'Tomate, Papa, Berenjena, Plátano'},
      {'id': 'pla-012', 'nombre': 'Hormiga arriera', 'nombreCientifico': 'Atta spp.', 'tipo': 'insecto', 'severidadTipica': 'media', 'sintomas': 'Corte semicircular de hojas y defoliación rápida de ramas completas.', 'cultivosAfectados': 'Yuca, Cítricos, Cacao, Café, Frutales'},
      {'id': 'pla-013', 'nombre': 'Mildiu', 'nombreCientifico': 'Peronospora spp.', 'tipo': 'hongo', 'severidadTipica': 'media', 'sintomas': 'Manchas amarillentas en el haz de las hojas y moho grisáceo o blanquecino en el envés en condiciones de alta humedad.', 'cultivosAfectados': 'Hortalizas, Papa, Frutales'},
      {'id': 'pla-014', 'nombre': 'Tizón tardío (papa/tomate)', 'nombreCientifico': 'Phytophthora infestans', 'tipo': 'hongo', 'severidadTipica': 'alta', 'sintomas': 'Manchas necróticas café-negras de aspecto húmedo en hojas y tallos, pudrición húmeda del fruto y tubérculos.', 'cultivosAfectados': 'Tomate, Papa'},
      {'id': 'pla-015', 'nombre': 'Fusariosis', 'nombreCientifico': 'Fusarium oxysporum', 'tipo': 'hongo', 'severidadTipica': 'alta', 'sintomas': 'Marchitamiento progresivo, amarillamiento foliar unilateral y oscurecimiento de los vasos conductores.', 'cultivosAfectados': 'Tomate, Banano, Plátano, Flores, Frijol'},
      {'id': 'pla-016', 'nombre': 'Botrytis (moho gris)', 'nombreCientifico': 'Botrytis cinerea', 'tipo': 'hongo', 'severidadTipica': 'media', 'sintomas': 'Moho gris velloso sobre flores, hojas y frutos, provocando pudrición blanda.', 'cultivosAfectados': 'Tomate, Frutales, Hortalizas'},
      {'id': 'pla-017', 'nombre': 'Mancha bacteriana', 'nombreCientifico': 'Xanthomonas spp.', 'tipo': 'bacteria', 'severidadTipica': 'media', 'sintomas': 'Pequeñas manchas oscuras y acuosas en hojas y frutos, a menudo rodeadas de un halo amarillento.', 'cultivosAfectados': 'Tomate, Pimentón, Cítricos'},
      {'id': 'pla-018', 'nombre': 'Necrosis foliar', 'nombreCientifico': 'Pseudomonas syringae', 'tipo': 'bacteria', 'severidadTipica': 'media', 'sintomas': 'Manchas foliares necróticas oscuras, a menudo rodeadas de un halo amarillo, muerte regresiva de brotes.', 'cultivosAfectados': 'Hortalizas, Frutales'},
      {'id': 'pla-019', 'nombre': 'Fuego bacteriano', 'nombreCientifico': 'Erwinia amylovora', 'tipo': 'bacteria', 'severidadTipica': 'alta', 'sintomas': 'Flores, hojas y ramas que se marchitan rápidamente, se tornan negras y toman aspecto de quemadas por fuego.', 'cultivosAfectados': 'Frutales'},
      {'id': 'pla-020', 'nombre': 'Nematodo agallador', 'nombreCientifico': 'Meloidogyne spp.', 'tipo': 'nematodo', 'severidadTipica': 'alta', 'sintomas': 'Agallas/nudos en raíces, plantas raquíticas, marchitamiento aun con suelo húmedo, amarillamiento general.', 'cultivosAfectados': 'Tomate, Ahuyama, Patilla, Frijol, Banano'},
      {'id': 'pla-021', 'nombre': 'Nematodo lesionador', 'nombreCientifico': 'Pratylenchus spp.', 'tipo': 'nematodo', 'severidadTipica': 'media', 'sintomas': 'Lesiones necróticas oscuras en las raíces secundarias, reducción del sistema radicular y retraso en el crecimiento.', 'cultivosAfectados': 'Maíz, Plátano, Café, Papa'},
      {'id': 'pla-022', 'nombre': 'Grama', 'nombreCientifico': 'Cynodon dactylon', 'tipo': 'maleza', 'severidadTipica': 'media', 'sintomas': 'Maleza perenne de cobertura densa y rápida expansión por estolones, compite agresivamente por agua y nutrientes.', 'cultivosAfectados': 'Todos los cultivos'},
      {'id': 'pla-023', 'nombre': 'Kikuyo', 'nombreCientifico': 'Pennisetum clandestinum', 'tipo': 'maleza', 'severidadTipica': 'media', 'sintomas': 'Pasto rastrero sumamente invasivo con estolones fuertes que ahoga otros cultivos.', 'cultivosAfectados': 'Todos los cultivos'},
      {'id': 'pla-024', 'nombre': 'Parietaria', 'nombreCientifico': 'Parietaria officinalis', 'tipo': 'maleza', 'severidadTipica': 'baja', 'sintomas': 'Hierba de crecimiento rápido en zonas húmedas y sombreadas, compite con plántulas de hortalizas.', 'cultivosAfectados': 'Hortalizas, Frutales'},
      {'id': 'pla-025', 'nombre': 'Ratón de campo', 'nombreCientifico': 'Mus musculus', 'tipo': 'otro', 'severidadTipica': 'media', 'sintomas': 'Daño por roedura en tallos, raíces y frutos, pérdida de grano almacenado o en campo.', 'cultivosAfectados': 'Maíz, Arroz, Hortalizas, Cacao'},
      {'id': 'pla-026', 'nombre': 'Paloma común', 'nombreCientifico': 'Columba livia', 'tipo': 'otro', 'severidadTipica': 'baja', 'sintomas': 'Consumo de semillas recién sembradas y frutos maduros, contaminación foliar con excrementos.', 'cultivosAfectados': 'Maíz, Sorgo, Arroz, Frutas'},
      {'id': 'pla-027', 'nombre': 'Fusarium R4T', 'nombreCientifico': 'Fusarium oxysporum f. sp. cubense raza 4', 'tipo': 'hongo', 'severidadTipica': 'critica', 'sintomas': 'Amarillamiento de hojas viejas, marchitamiento, pudrición vascular oscura en el rizoma. Enfermedad de cuarentena en Colombia.', 'cultivosAfectados': 'Banano, Plátano'},
      {'id': 'pla-028', 'nombre': 'Moko del plátano', 'nombreCientifico': 'Ralstonia solanacearum raza 2', 'tipo': 'bacteria', 'severidadTipica': 'critica', 'sintomas': 'Marchitamiento súbito de plantas adultas, pudrición vascular con exudado bacteriano, fruto con pudrición seca interna.', 'cultivosAfectados': 'Plátano, Banano'},
      {'id': 'pla-029', 'nombre': 'Tizón temprano', 'nombreCientifico': 'Alternaria solani', 'tipo': 'hongo', 'severidadTipica': 'media', 'sintomas': 'Manchas concéntricas con anillos concéntricos en hojas viejas, defoliación ascendente.', 'cultivosAfectados': 'Tomate, Papa, Patilla'},
      {'id': 'pla-030', 'nombre': 'Virus del mosaico de la yuca', 'nombreCientifico': 'Cassava mosaic virus', 'tipo': 'virus', 'severidadTipica': 'alta', 'sintomas': 'Mosaico amarillo y verde en hojas, deformación del follaje, reducción de tamaño de raíces.', 'cultivosAfectados': 'Yuca'},
      {'id': 'pla-031', 'nombre': 'Coquito', 'nombreCientifico': 'Cyperus rotundus', 'tipo': 'maleza', 'severidadTipica': 'alta', 'sintomas': 'Maleza perenne de hoja angosta, propagación por tubérculos subterráneos, competencia agresiva.', 'cultivosAfectados': 'Todos los cultivos'},
      {'id': 'pla-032', 'nombre': 'Bledo', 'nombreCientifico': 'Amaranthus spinosus', 'tipo': 'maleza', 'severidadTipica': 'media', 'sintomas': 'Maleza anual de hoja ancha con espinas, crecimiento rápido, hospedera de plagas.', 'cultivosAfectados': 'Maíz, Frijol, Hortalizas'},
    ];

    for (final p in plagas) {
      batch.insert(tableCatPlagas, {...p, 'activo': 1, 'syncedAt': now},
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    // ── Fertilizantes comunes ────────────────────────────────
    final fertilizantes = [
      {'id': 'fer-001', 'nombre': 'Urea', 'tipo': 'químico', 'composicionNpk': '46-0-0', 'presentacion': 'Granulado', 'dosisRecomendadaKgHa': 150.0, 'descripcion': 'Fuente concentrada de nitrógeno'},
      {'id': 'fer-002', 'nombre': 'DAP', 'tipo': 'químico', 'composicionNpk': '18-46-0', 'presentacion': 'Granulado', 'dosisRecomendadaKgHa': 100.0, 'descripcion': 'Fosfato diamónico, arranque de cultivos'},
      {'id': 'fer-003', 'nombre': 'KCl (Cloruro de potasio)', 'tipo': 'químico', 'composicionNpk': '0-0-60', 'presentacion': 'Granulado', 'dosisRecomendadaKgHa': 120.0, 'descripcion': 'Fuente de potasio para fructificación'},
      {'id': 'fer-004', 'nombre': 'Triple 15', 'tipo': 'químico', 'composicionNpk': '15-15-15', 'presentacion': 'Granulado', 'dosisRecomendadaKgHa': 200.0, 'descripcion': 'Fórmula balanceada NPK'},
      {'id': 'fer-005', 'nombre': '10-30-10', 'tipo': 'químico', 'composicionNpk': '10-30-10', 'presentacion': 'Granulado', 'dosisRecomendadaKgHa': 150.0, 'descripcion': 'Alto fósforo para floración'},
      {'id': 'fer-006', 'nombre': 'Sulfato de amonio', 'tipo': 'químico', 'composicionNpk': '21-0-0', 'presentacion': 'Cristalino', 'dosisRecomendadaKgHa': 200.0, 'descripcion': 'Nitrógeno + azufre para suelos alcalinos'},
      {'id': 'fer-007', 'nombre': 'Nitrato de potasio', 'tipo': 'químico', 'composicionNpk': '13-0-46', 'presentacion': 'Cristalino', 'dosisRecomendadaKgHa': 80.0, 'descripcion': 'Fertirrigación, libre de cloro'},
      {'id': 'fer-008', 'nombre': 'Cal dolomita', 'tipo': 'enmienda', 'composicionNpk': '0-0-0', 'presentacion': 'Polvo', 'dosisRecomendadaKgHa': 1000.0, 'descripcion': 'Corrector de pH, aporta Ca y Mg'},
      {'id': 'fer-009', 'nombre': 'Gallinaza', 'tipo': 'orgánico', 'composicionNpk': '3-3-2', 'presentacion': 'Sólido', 'dosisRecomendadaKgHa': 2000.0, 'descripcion': 'Abono orgánico de alta disponibilidad'},
      {'id': 'fer-010', 'nombre': 'Compost', 'tipo': 'orgánico', 'composicionNpk': '1.5-1-1', 'presentacion': 'Sólido', 'dosisRecomendadaKgHa': 3000.0, 'descripcion': 'Materia orgánica descompuesta'},
      {'id': 'fer-011', 'nombre': 'Bocashi', 'tipo': 'orgánico', 'composicionNpk': '2-2-1', 'presentacion': 'Sólido', 'dosisRecomendadaKgHa': 2500.0, 'descripcion': 'Abono fermentado japonés'},
      {'id': 'fer-012', 'nombre': 'Humus de lombriz', 'tipo': 'orgánico', 'composicionNpk': '1-1-1', 'presentacion': 'Sólido', 'dosisRecomendadaKgHa': 2000.0, 'descripcion': 'Lombricompuesto, mejora estructura'},
      {'id': 'fer-013', 'nombre': 'Sulfato de zinc', 'tipo': 'químico', 'composicionNpk': '0-0-0', 'presentacion': 'Polvo', 'dosisRecomendadaKgHa': 15.0, 'descripcion': 'Micronutriente para arroz y maíz'},
      {'id': 'fer-014', 'nombre': 'Boro (Bórax)', 'tipo': 'químico', 'composicionNpk': '0-0-0', 'presentacion': 'Polvo', 'dosisRecomendadaKgHa': 10.0, 'descripcion': 'Micronutriente para palma y frutales'},
      {'id': 'fer-015', 'nombre': 'Fosforita Huila', 'tipo': 'enmienda', 'composicionNpk': '0-20-0', 'presentacion': 'Polvo', 'dosisRecomendadaKgHa': 500.0, 'descripcion': 'Roca fosfórica de liberación lenta'},
    ];

    for (final f in fertilizantes) {
      batch.insert(tableCatFertilizantes, {...f, 'activo': 1, 'syncedAt': now},
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    // ── Tipos de suelo del Magdalena ─────────────────────────
    final tiposSuelo = [
      {'id': 'sue-001', 'nombre': 'Franco', 'clase': 'Clase II', 'drenaje': 'Bueno', 'retencionHumedadPct': 45.0, 'phTipico': 6.5, 'cultivosRecomendados': 'Banano, Maíz, Hortalizas', 'descripcion': 'Equilibrio ideal de arena, limo y arcilla'},
      {'id': 'sue-002', 'nombre': 'Franco arcilloso', 'clase': 'Clase III', 'drenaje': 'Moderado', 'retencionHumedadPct': 55.0, 'phTipico': 6.2, 'cultivosRecomendados': 'Arroz, Palma, Cacao', 'descripcion': 'Alta retención de humedad y nutrientes'},
      {'id': 'sue-003', 'nombre': 'Franco arenoso', 'clase': 'Clase II', 'drenaje': 'Rápido', 'retencionHumedadPct': 30.0, 'phTipico': 6.8, 'cultivosRecomendados': 'Yuca, Sandía, Melón', 'descripcion': 'Buen drenaje, baja retención de agua'},
      {'id': 'sue-004', 'nombre': 'Arcilloso', 'clase': 'Clase IV', 'drenaje': 'Lento', 'retencionHumedadPct': 65.0, 'phTipico': 5.8, 'cultivosRecomendados': 'Arroz, Pastos', 'descripcion': 'Alta retención pero difícil laboreo'},
      {'id': 'sue-005', 'nombre': 'Arenoso', 'clase': 'Clase V', 'drenaje': 'Muy rápido', 'retencionHumedadPct': 15.0, 'phTipico': 7.0, 'cultivosRecomendados': 'Coco, Marañón', 'descripcion': 'Zonas costeras, requiere riego frecuente'},
      {'id': 'sue-006', 'nombre': 'Aluvial', 'clase': 'Clase I', 'drenaje': 'Bueno', 'retencionHumedadPct': 50.0, 'phTipico': 6.5, 'cultivosRecomendados': 'Banano, Palma, Cacao, Frutales', 'descripcion': 'Suelos fértiles de llanuras de inundación'},
      {'id': 'sue-007', 'nombre': 'Orgánico (turba)', 'clase': 'Clase VI', 'drenaje': 'Pobre', 'retencionHumedadPct': 80.0, 'phTipico': 5.0, 'cultivosRecomendados': 'Pastos, Arroz', 'descripcion': 'Zonas de ciénaga, alto contenido orgánico'},
      {'id': 'sue-008', 'nombre': 'Vertisol', 'clase': 'Clase III', 'drenaje': 'Moderado', 'retencionHumedadPct': 60.0, 'phTipico': 7.2, 'cultivosRecomendados': 'Algodón, Sorgo, Maíz', 'descripcion': 'Arcillas expansivas, grietas en sequía'},
    ];

    for (final s in tiposSuelo) {
      batch.insert(tableCatTiposSuelo, {...s, 'activo': 1, 'syncedAt': now},
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    await batch.commit(noResult: true);
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
        cultivoActualId TEXT,
        municipioId TEXT,
        tipoSueloId TEXT,
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
        cultivoId TEXT,
        cultivoOtro TEXT,
        variedad TEXT,
        fecha TEXT NOT NULL,
        cantidadSemillas REAL,
        unidad TEXT,
        distanciaEntreFilas REAL,
        distanciaEntrePlantas REAL,
        observaciones TEXT,
        userId TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        isPendingSync INTEGER NOT NULL DEFAULT 1,
        serverId TEXT,
        syncError TEXT
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
        isPendingSync INTEGER NOT NULL DEFAULT 1,
        serverId TEXT,
        syncError TEXT
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
        fertilizanteId TEXT,
        fertilizanteOtro TEXT,
        nombre TEXT,
        dosis REAL,
        unidad TEXT,
        metodoAplicacion TEXT,
        fecha TEXT NOT NULL,
        observaciones TEXT,
        userId TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        isPendingSync INTEGER NOT NULL DEFAULT 1,
        serverId TEXT,
        syncError TEXT
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
        plagaId TEXT,
        plagaOtro TEXT,
        severidad TEXT NOT NULL,
        descripcion TEXT,
        fotoPath TEXT,
        fecha TEXT NOT NULL,
        userId TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        isPendingSync INTEGER NOT NULL DEFAULT 1,
        serverId TEXT,
        syncError TEXT
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
        isPendingSync INTEGER NOT NULL DEFAULT 1,
        serverId TEXT,
        syncError TEXT
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
        fotoPath TEXT,
        tipo TEXT,
        fecha TEXT NOT NULL,
        userId TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        isPendingSync INTEGER NOT NULL DEFAULT 1,
        serverId TEXT,
        syncError TEXT
      )
    ''');
  }

  Future<void> _createEstadoTerreno(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableEstadoTerreno (
        id TEXT PRIMARY KEY,
        loteId TEXT NOT NULL,
        loteNombre TEXT NOT NULL,
        siembraId TEXT,
        estado TEXT NOT NULL,
        tipoSueloId TEXT,
        notas TEXT,
        userId TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        isPendingSync INTEGER NOT NULL DEFAULT 1,
        serverId TEXT,
        syncError TEXT
      )
    ''');
  }

  // ─── Tablas de Catálogos (Sprint 2) ─────────────────────────

  Future<void> _createCatalogoCultivos(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableCatCultivos (
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        nombreCientifico TEXT,
        categoria TEXT,
        cicloVegetativo TEXT,
        diasCosecha INTEGER,
        densidadSiembraPorHa INTEGER,
        descripcion TEXT,
        activo INTEGER DEFAULT 1,
        syncedAt TEXT
      )
    ''');
  }

  Future<void> _createCatalogoMunicipios(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableCatMunicipios (
        id TEXT PRIMARY KEY,
        codigoDane TEXT,
        nombre TEXT NOT NULL,
        subregion TEXT,
        latitud REAL,
        longitud REAL,
        activo INTEGER DEFAULT 1,
        syncedAt TEXT
      )
    ''');
  }

  Future<void> _createCatalogoPlagas(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableCatPlagas (
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        nombreCientifico TEXT,
        tipo TEXT,
        severidadTipica TEXT,
        sintomas TEXT,
        cultivosAfectados TEXT,
        activo INTEGER DEFAULT 1,
        syncedAt TEXT
      )
    ''');
  }

  Future<void> _createCatalogoFertilizantes(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableCatFertilizantes (
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        tipo TEXT,
        composicionNpk TEXT,
        presentacion TEXT,
        dosisRecomendadaKgHa REAL,
        descripcion TEXT,
        activo INTEGER DEFAULT 1,
        syncedAt TEXT
      )
    ''');
  }

  Future<void> _createCatalogoTiposSuelo(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableCatTiposSuelo (
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        clase TEXT,
        drenaje TEXT,
        retencionHumedadPct REAL,
        phTipico REAL,
        cultivosRecomendados TEXT,
        descripcion TEXT,
        activo INTEGER DEFAULT 1,
        syncedAt TEXT
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

  // ─── Catálogos ─────────────────────────────────────────────

  Future<void> upsertCatalogo(String table, List<Map<String, dynamic>> items) async {
    final db = await database;
    final batch = db.batch();
    final syncedAt = DateTime.now().toIso8601String();
    
    for (final item in items) {
      final data = Map<String, dynamic>.from(item);
      data['syncedAt'] = syncedAt;
      // Convertir booleanos a enteros para SQLite
      if (data.containsKey('activo')) {
        data['activo'] = (data['activo'] == true || data['activo'] == 1) ? 1 : 0;
      }
      batch.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
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
      tableEstadoTerreno,
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
