import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/storage/database_helper.dart';
import '../services/operaciones_service.dart';
import '../models/operaciones_models.dart';
import '../../core/network/api_endpoints.dart';

class OperacionesProvider extends ChangeNotifier {
  final OperacionesService service;
  final DatabaseHelper _db = DatabaseHelper.instance;

  OperacionesProvider(this.service);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    return !(result.contains(ConnectivityResult.none) && result.length == 1);
  }

  Future<void> sincronizarOperaciones(String loteId) async {
    final online = await _checkConnectivity();
    if (!online) return;

    _isLoading = true;
    notifyListeners();

    try {
      final siembras = await service.getSiembras(loteId);
      final riegos = await service.getRiegos(loteId);
      final ferts = await service.getFertilizaciones(loteId);
      final hallazgos = await service.getHallazgos(loteId);
      final tratamientos = await service.getTratamientos(loteId);
      final observaciones = await service.getObservaciones(loteId);
      final estados = await service.getEstadosTerreno(loteId);

      final db = await _db.database;
      final batch = db.batch();

      void upsert(String table, List<dynamic> items) {
        for (var i in items) {
          final data = i.toMap();
          data['isPendingSync'] = 0;
          batch.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }

      upsert(DatabaseHelper.tableSiembras, siembras);
      upsert(DatabaseHelper.tableRiego, riegos);
      upsert(DatabaseHelper.tableFertilizacion, ferts);
      upsert(DatabaseHelper.tableHallazgos, hallazgos);
      upsert(DatabaseHelper.tableTratamientos, tratamientos);
      upsert(DatabaseHelper.tableObservaciones, observaciones);
      upsert(DatabaseHelper.tableEstadoTerreno, estados);

      await batch.commit(noResult: true);
    } catch (e) {
      debugPrint('[OperacionesProvider] Error sincronizando: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sincronizarTodasLasOperaciones(List<String> loteIds) async {
    final online = await _checkConnectivity();
    if (!online) return;
    
    _isLoading = true;
    notifyListeners();
    
    for (final id in loteIds) {
      // Usamos el mismo try-catch de sincronizarOperaciones internamente
      await sincronizarOperaciones(id);
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _handleCreateFallback(String table, String endpoint, Map<String, dynamic> data) async {
    final id = 'local_${DateTime.now().millisecondsSinceEpoch}';
    data['id'] = id;
    data['isPendingSync'] = 1;
    data['createdAt'] ??= DateTime.now().toUtc().toIso8601String();
    data['updatedAt'] ??= DateTime.now().toUtc().toIso8601String();

    await _db.insert(table, data);
    
    await _db.insert(DatabaseHelper.tableSyncQueue, {
      'method': 'POST',
      'endpoint': endpoint,
      'payload': json.encode({...data, 'localId': id}),
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  // --- SIEMBRAS ---
  Future<void> crearSiembra(Map<String, dynamic> data) async {
    final online = await _checkConnectivity();
    if (online) {
      try {
        final result = await service.createSiembra(data);
        final mapData = result.toMap();
        mapData['isPendingSync'] = 0;
        await _db.insert(DatabaseHelper.tableSiembras, mapData);
        notifyListeners();
        return;
      } catch (e) { debugPrint('Error red siembra: $e'); }
    }
    await _handleCreateFallback(DatabaseHelper.tableSiembras, ApiEndpoints.siembras, data);
    notifyListeners();
  }

  Future<List<Siembra>> getSiembras(String loteId) async {
    final rows = await _db.queryWhere(DatabaseHelper.tableSiembras, 'loteId = ?', [loteId]);
    return rows.map((row) => Siembra.fromJson(row)).toList();
  }

  // --- RIEGO ---
  Future<void> crearRiego(Map<String, dynamic> data) async {
    final online = await _checkConnectivity();
    if (online) {
      try {
        final result = await service.createRiego(data);
        final mapData = result.toMap();
        mapData['isPendingSync'] = 0;
        await _db.insert(DatabaseHelper.tableRiego, mapData);
        notifyListeners();
        return;
      } catch (e) { debugPrint('Error red riego: $e'); }
    }
    await _handleCreateFallback(DatabaseHelper.tableRiego, ApiEndpoints.riego, data);
    notifyListeners();
  }

  Future<List<Riego>> getRiegos(String loteId) async {
    final rows = await _db.queryWhere(DatabaseHelper.tableRiego, 'loteId = ?', [loteId]);
    return rows.map((row) => Riego.fromJson(row)).toList();
  }

  // --- FERTILIZACION ---
  Future<void> crearFertilizacion(Map<String, dynamic> data) async {
    final online = await _checkConnectivity();
    if (online) {
      try {
        final result = await service.createFertilizacion(data);
        final mapData = result.toMap();
        mapData['isPendingSync'] = 0;
        await _db.insert(DatabaseHelper.tableFertilizacion, mapData);
        notifyListeners();
        return;
      } catch (e) { debugPrint('Error red fertilizacion: $e'); }
    }
    await _handleCreateFallback(DatabaseHelper.tableFertilizacion, ApiEndpoints.fertilizacion, data);
    notifyListeners();
  }

  Future<List<Fertilizacion>> getFertilizaciones(String loteId) async {
    final rows = await _db.queryWhere(DatabaseHelper.tableFertilizacion, 'loteId = ?', [loteId]);
    return rows.map((row) => Fertilizacion.fromJson(row)).toList();
  }

  // --- HALLAZGOS ---
  Future<void> crearHallazgo(Map<String, dynamic> data) async {
    final online = await _checkConnectivity();
    if (online) {
      try {
        final result = await service.createHallazgo(data);
        final mapData = result.toMap();
        mapData['isPendingSync'] = 0;
        await _db.insert(DatabaseHelper.tableHallazgos, mapData);
        notifyListeners();
        return;
      } catch (e) { debugPrint('Error red hallazgo: $e'); }
    }
    await _handleCreateFallback(DatabaseHelper.tableHallazgos, ApiEndpoints.hallazgos, data);
    notifyListeners();
  }

  Future<List<Hallazgo>> getHallazgos(String loteId) async {
    final rows = await _db.queryWhere(DatabaseHelper.tableHallazgos, 'loteId = ?', [loteId]);
    return rows.map((row) => Hallazgo.fromJson(row)).toList();
  }

  // --- TRATAMIENTOS ---
  Future<void> crearTratamiento(Map<String, dynamic> data) async {
    final online = await _checkConnectivity();
    if (online) {
      try {
        final result = await service.createTratamiento(data);
        final mapData = result.toMap();
        mapData['isPendingSync'] = 0;
        await _db.insert(DatabaseHelper.tableTratamientos, mapData);
        notifyListeners();
        return;
      } catch (e) { debugPrint('Error red tratamiento: $e'); }
    }
    await _handleCreateFallback(DatabaseHelper.tableTratamientos, ApiEndpoints.tratamientos, data);
    notifyListeners();
  }

  Future<List<Tratamiento>> getTratamientos(String loteId) async {
    final rows = await _db.queryWhere(DatabaseHelper.tableTratamientos, 'loteId = ?', [loteId]);
    return rows.map((row) => Tratamiento.fromJson(row)).toList();
  }

  // --- OBSERVACIONES ---
  Future<void> crearObservacion(Map<String, dynamic> data) async {
    final online = await _checkConnectivity();
    if (online) {
      try {
        final result = await service.createObservacion(data);
        final mapData = result.toMap();
        mapData['isPendingSync'] = 0;
        await _db.insert(DatabaseHelper.tableObservaciones, mapData);
        notifyListeners();
        return;
      } catch (e) { debugPrint('Error red observacion: $e'); }
    }
    await _handleCreateFallback(DatabaseHelper.tableObservaciones, ApiEndpoints.observaciones, data);
    notifyListeners();
  }

  Future<List<Observacion>> getObservaciones(String loteId) async {
    final rows = await _db.queryWhere(DatabaseHelper.tableObservaciones, 'loteId = ?', [loteId]);
    return rows.map((row) => Observacion.fromJson(row)).toList();
  }

  // --- ESTADO TERRENO ---
  Future<void> crearEstadoTerreno(Map<String, dynamic> data) async {
    final online = await _checkConnectivity();
    if (online) {
      try {
        final result = await service.createEstadoTerreno(data);
        final mapData = result.toMap();
        mapData['isPendingSync'] = 0;
        await _db.insert(DatabaseHelper.tableEstadoTerreno, mapData);
        notifyListeners();
        return;
      } catch (e) { debugPrint('Error red estadoTerreno: $e'); }
    }
    await _handleCreateFallback(DatabaseHelper.tableEstadoTerreno, ApiEndpoints.estadoTerreno, data);
    notifyListeners();
  }

  Future<List<EstadoTerreno>> getEstadosTerreno(String loteId) async {
    final rows = await _db.queryWhere(DatabaseHelper.tableEstadoTerreno, 'loteId = ?', [loteId]);
    return rows.map((row) => EstadoTerreno.fromJson(row)).toList();
  }
}
