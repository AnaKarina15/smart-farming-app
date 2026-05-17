import 'package:flutter/foundation.dart';
import '../../core/storage/database_helper.dart';
import '../services/operaciones_service.dart';
import '../models/operaciones_models.dart';

class OperacionesProvider extends ChangeNotifier {
  final OperacionesService service;
  final DatabaseHelper _db = DatabaseHelper.instance;

  OperacionesProvider(this.service);

  // --- SIEMBRAS ---
  Future<void> crearSiembra(Map<String, dynamic> data) async {
    final siembraId = 'local_${DateTime.now().millisecondsSinceEpoch}';
    data['id'] = siembraId;
    data['isPendingSync'] = 1;
    await _db.insert(DatabaseHelper.tableSiembras, data);
    notifyListeners();
  }

  Future<List<Siembra>> getSiembras(String loteId) async {
    final rows = await _db
        .queryWhere(DatabaseHelper.tableSiembras, 'loteId = ?', [loteId]);
    return rows.map((row) => Siembra.fromJson(row)).toList();
  }

  // --- RIEGO ---
  Future<void> crearRiego(Map<String, dynamic> data) async {
    final riegoId = 'local_${DateTime.now().millisecondsSinceEpoch}';
    data['id'] = riegoId;
    data['isPendingSync'] = 1;
    await _db.insert(DatabaseHelper.tableRiego, data);
    notifyListeners();
  }

  Future<List<Riego>> getRiegos(String loteId) async {
    final rows =
        await _db.queryWhere(DatabaseHelper.tableRiego, 'loteId = ?', [loteId]);
    return rows.map((row) => Riego.fromJson(row)).toList();
  }

  // --- FERTILIZACION ---
  Future<void> crearFertilizacion(Map<String, dynamic> data) async {
    final fertId = 'local_${DateTime.now().millisecondsSinceEpoch}';
    data['id'] = fertId;
    data['isPendingSync'] = 1;
    await _db.insert(DatabaseHelper.tableFertilizacion, data);
    notifyListeners();
  }

  Future<List<Fertilizacion>> getFertilizaciones(String loteId) async {
    final rows = await _db
        .queryWhere(DatabaseHelper.tableFertilizacion, 'loteId = ?', [loteId]);
    return rows.map((row) => Fertilizacion.fromJson(row)).toList();
  }

  // --- HALLAZGOS ---
  Future<void> crearHallazgo(Map<String, dynamic> data) async {
    final hallazgoId = 'local_${DateTime.now().millisecondsSinceEpoch}';
    data['id'] = hallazgoId;
    data['isPendingSync'] = 1;
    await _db.insert(DatabaseHelper.tableHallazgos, data);
    notifyListeners();
  }

  Future<List<Hallazgo>> getHallazgos(String loteId) async {
    final rows = await _db
        .queryWhere(DatabaseHelper.tableHallazgos, 'loteId = ?', [loteId]);
    return rows.map((row) => Hallazgo.fromJson(row)).toList();
  }

  // --- TRATAMIENTOS ---
  Future<void> crearTratamiento(Map<String, dynamic> data) async {
    final id = 'local_${DateTime.now().millisecondsSinceEpoch}';
    data['id'] = id;
    data['isPendingSync'] = 1;
    await _db.insert(DatabaseHelper.tableTratamientos, data);
    notifyListeners();
  }

  Future<List<Tratamiento>> getTratamientos(String loteId) async {
    final rows = await _db
        .queryWhere(DatabaseHelper.tableTratamientos, 'loteId = ?', [loteId]);
    return rows.map((row) => Tratamiento.fromJson(row)).toList();
  }

  // --- OBSERVACIONES ---
  Future<void> crearObservacion(Map<String, dynamic> data) async {
    final id = 'local_${DateTime.now().millisecondsSinceEpoch}';
    data['id'] = id;
    data['isPendingSync'] = 1;
    await _db.insert(DatabaseHelper.tableObservaciones, data);
    notifyListeners();
  }

  Future<List<Observacion>> getObservaciones(String loteId) async {
    final rows = await _db
        .queryWhere(DatabaseHelper.tableObservaciones, 'loteId = ?', [loteId]);
    return rows.map((row) => Observacion.fromJson(row)).toList();
  }
}
