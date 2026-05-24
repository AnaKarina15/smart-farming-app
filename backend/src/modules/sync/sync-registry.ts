import { BadRequestException, Injectable } from '@nestjs/common';

import { EstadoTerrenoSyncAdapter } from './adapters/estado-terreno-sync.adapter';
import { FertilizacionSyncAdapter } from './adapters/fertilizacion-sync.adapter';
import { HallazgosSyncAdapter } from './adapters/hallazgos-sync.adapter';
import { ObservacionesSyncAdapter } from './adapters/observaciones-sync.adapter';
import { RiegoSyncAdapter } from './adapters/riego-sync.adapter';
import { SiembrasSyncAdapter } from './adapters/siembras-sync.adapter';
import { SyncResourceAdapter } from './adapters/sync-resource.adapter';
import { TratamientosSyncAdapter } from './adapters/tratamientos-sync.adapter';
import { SyncBatchItemDto } from './dto/sync-batch.dto';

@Injectable()
export class SyncRegistry {
  private readonly adapters: SyncResourceAdapter[];
  private readonly aliasIndex: Map<string, SyncResourceAdapter>;

  constructor(
    siembras: SiembrasSyncAdapter,
    riego: RiegoSyncAdapter,
    fertilizacion: FertilizacionSyncAdapter,
    hallazgos: HallazgosSyncAdapter,
    tratamientos: TratamientosSyncAdapter,
    observaciones: ObservacionesSyncAdapter,
    estadoTerreno: EstadoTerrenoSyncAdapter,
  ) {
    this.adapters = [
      siembras,
      riego,
      fertilizacion,
      hallazgos,
      tratamientos,
      observaciones,
      estadoTerreno,
    ];
    this.aliasIndex = new Map<string, SyncResourceAdapter>();

    for (const adapter of this.adapters) {
      this.aliasIndex.set(adapter.resourceType, adapter);

      for (const alias of adapter.endpointAliases) {
        this.aliasIndex.set(alias, adapter);
      }
    }
  }

  all(): SyncResourceAdapter[] {
    return this.adapters;
  }

  resolve(item: SyncBatchItemDto): SyncResourceAdapter {
    const explicit = item.resourceType ? this.normalize(item.resourceType) : null;

    if (explicit) {
      return explicit;
    }

    const inferred = this.inferFromEndpoint(item.endpoint);

    if (inferred) {
      return inferred;
    }

    throw new BadRequestException(
      'resourceType es obligatorio si no puede inferirse desde endpoint',
    );
  }

  private normalize(resourceType: string): SyncResourceAdapter | null {
    return this.aliasIndex.get(resourceType) ?? null;
  }

  private inferFromEndpoint(endpoint?: string): SyncResourceAdapter | null {
    if (!endpoint) return null;

    const cleaned = endpoint.replace(/^\/api\/v\d+\//, '/').split('?')[0];
    const segments = cleaned.split('/').filter(Boolean);
    const candidate = segments[0];

    return candidate ? this.normalize(candidate) : null;
  }
}
