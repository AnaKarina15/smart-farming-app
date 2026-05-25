import 'package:flutter/foundation.dart';
import '../../core/storage/database_helper.dart';
import 'catalogos_service.dart';

class CatalogosSyncService {
  final CatalogosService _api;
  final DatabaseHelper _db = DatabaseHelper.instance;

  CatalogosSyncService(this._api);

  Future<void> sincronizarCatalogos() async {
    if (kDebugMode) print('Sincronizando catálogos...');

    try {
      final results = await Future.wait([
        _api.getCultivos(),
        _api.getMunicipios(),
        _api.getPlagas(),
        _api.getFertilizantes(),
        _api.getTiposSuelo(),
      ]);

      await _db.upsertCatalogo(
        DatabaseHelper.tableCatCultivos,
        results[0],
        replaceExisting: true,
      );
      await _db.upsertCatalogo(
        DatabaseHelper.tableCatMunicipios,
        results[1],
        replaceExisting: true,
      );
      await _db.upsertCatalogo(
        DatabaseHelper.tableCatPlagas,
        results[2],
        replaceExisting: true,
      );
      await _db.upsertCatalogo(
        DatabaseHelper.tableCatFertilizantes,
        results[3],
        replaceExisting: true,
      );
      await _db.upsertCatalogo(
        DatabaseHelper.tableCatTiposSuelo,
        results[4],
        replaceExisting: true,
      );

      if (kDebugMode) print('Catálogos sincronizados exitosamente.');
    } catch (e) {
      if (kDebugMode) print('Error sincronizando catálogos: $e');
    }
  }
}
