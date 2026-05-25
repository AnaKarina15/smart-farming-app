import 'package:flutter/foundation.dart';
import '../../core/storage/database_helper.dart';
import 'catalogos_service.dart';

class CatalogosRemotos {
  final List<Map<String, dynamic>> cultivos;
  final List<Map<String, dynamic>> municipios;
  final List<Map<String, dynamic>> plagas;
  final List<Map<String, dynamic>> fertilizantes;
  final List<Map<String, dynamic>> tiposSuelo;

  const CatalogosRemotos({
    required this.cultivos,
    required this.municipios,
    required this.plagas,
    required this.fertilizantes,
    required this.tiposSuelo,
  });
}

class CatalogosSyncService {
  final CatalogosService _api;
  final DatabaseHelper _db = DatabaseHelper.instance;

  CatalogosSyncService(this._api);

  Future<CatalogosRemotos> obtenerCatalogosRemotos() async {
    final results = await Future.wait([
      _api.getCultivos(),
      _api.getMunicipios(),
      _api.getPlagas(),
      _api.getFertilizantes(),
      _api.getTiposSuelo(),
    ]);

    return CatalogosRemotos(
      cultivos: results[0],
      municipios: results[1],
      plagas: results[2],
      fertilizantes: results[3],
      tiposSuelo: results[4],
    );
  }

  Future<void> sincronizarCatalogos() async {
    if (kDebugMode) print('Sincronizando catálogos...');

    try {
      final results = await obtenerCatalogosRemotos();

      await _db.upsertCatalogo(
        DatabaseHelper.tableCatCultivos,
        results.cultivos,
        replaceExisting: true,
      );
      await _db.upsertCatalogo(
        DatabaseHelper.tableCatMunicipios,
        results.municipios,
        replaceExisting: true,
      );
      await _db.upsertCatalogo(
        DatabaseHelper.tableCatPlagas,
        results.plagas,
        replaceExisting: true,
      );
      await _db.upsertCatalogo(
        DatabaseHelper.tableCatFertilizantes,
        results.fertilizantes,
        replaceExisting: true,
      );
      await _db.upsertCatalogo(
        DatabaseHelper.tableCatTiposSuelo,
        results.tiposSuelo,
        replaceExisting: true,
      );

      if (kDebugMode) print('Catálogos sincronizados exitosamente.');
    } catch (e) {
      if (kDebugMode) print('Error sincronizando catálogos: $e');
    }
  }
}
