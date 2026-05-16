import 'package:flutter/material.dart';
import '../../core/storage/database_helper.dart';
import '../models/catalogos_models.dart';

class CatalogosProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<Cultivo> cultivos = [];
  List<Municipio> municipios = [];
  List<Plaga> plagas = [];
  List<Fertilizante> fertilizantes = [];
  List<TipoSuelo> tiposSuelo = [];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> cargarCatalogos() async {
    _isLoading = true;
    notifyListeners();

    try {
      final resCultivos = await _db.queryAllRows(DatabaseHelper.tableCatCultivos);
      final resMunicipios = await _db.queryAllRows(DatabaseHelper.tableCatMunicipios);
      final resPlagas = await _db.queryAllRows(DatabaseHelper.tableCatPlagas);
      final resFertilizantes = await _db.queryAllRows(DatabaseHelper.tableCatFertilizantes);
      final resTiposSuelo = await _db.queryAllRows(DatabaseHelper.tableCatTiposSuelo);

      cultivos = resCultivos.map((j) => Cultivo.fromJson(j)).toList();
      municipios = resMunicipios.map((j) => Municipio.fromJson(j)).toList();
      plagas = resPlagas.map((j) => Plaga.fromJson(j)).toList();
      fertilizantes = resFertilizantes.map((j) => Fertilizante.fromJson(j)).toList();
      tiposSuelo = resTiposSuelo.map((j) => TipoSuelo.fromJson(j)).toList();
      
      // Ordenar por nombre
      cultivos.sort((a, b) => a.nombre.compareTo(b.nombre));
      municipios.sort((a, b) => a.nombre.compareTo(b.nombre));
      plagas.sort((a, b) => a.nombre.compareTo(b.nombre));
      fertilizantes.sort((a, b) => a.nombre.compareTo(b.nombre));
      tiposSuelo.sort((a, b) => a.nombre.compareTo(b.nombre));

    } catch (e) {
      debugPrint('Error cargando catálogos desde SQLite: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
