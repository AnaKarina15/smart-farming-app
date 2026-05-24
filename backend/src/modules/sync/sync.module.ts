import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { Cultivo } from '../catalogos/entities/cultivo.entity';
import { Fertilizante } from '../catalogos/entities/fertilizante.entity';
import { Plaga } from '../catalogos/entities/plaga.entity';
import { TipoSuelo } from '../catalogos/entities/tipo-suelo.entity';
import { EstadoTerreno } from '../estado-terreno/entities/estado-terreno.entity';
import { Fertilizacion } from '../fertilizacion/entities/fertilizacion.entity';
import { Hallazgo } from '../hallazgos/entities/hallazgo.entity';
import { Lote } from '../lotes/entities/lote.entity';
import { Observacion } from '../observaciones/entities/observacion.entity';
import { Riego } from '../riego/entities/riego.entity';
import { Siembra } from '../siembras/entities/siembra.entity';
import { Tratamiento } from '../tratamientos/entities/tratamiento.entity';
import { EstadoTerrenoSyncAdapter } from './adapters/estado-terreno-sync.adapter';
import { FertilizacionSyncAdapter } from './adapters/fertilizacion-sync.adapter';
import { HallazgosSyncAdapter } from './adapters/hallazgos-sync.adapter';
import { ObservacionesSyncAdapter } from './adapters/observaciones-sync.adapter';
import { RiegoSyncAdapter } from './adapters/riego-sync.adapter';
import { SiembrasSyncAdapter } from './adapters/siembras-sync.adapter';
import { TratamientosSyncAdapter } from './adapters/tratamientos-sync.adapter';
import { SyncOperation } from './entities/sync-operation.entity';
import { SyncController } from './sync.controller';
import { SyncOperationRepository } from './sync-operation.repository';
import { SyncRegistry } from './sync-registry';
import { SyncService } from './sync.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      SyncOperation,
      Lote,
      Siembra,
      Riego,
      Fertilizacion,
      Hallazgo,
      Tratamiento,
      Observacion,
      EstadoTerreno,
      Cultivo,
      Fertilizante,
      Plaga,
      TipoSuelo,
    ]),
  ],
  controllers: [SyncController],
  providers: [
    SiembrasSyncAdapter,
    RiegoSyncAdapter,
    FertilizacionSyncAdapter,
    HallazgosSyncAdapter,
    TratamientosSyncAdapter,
    ObservacionesSyncAdapter,
    EstadoTerrenoSyncAdapter,
    SyncRegistry,
    SyncOperationRepository,
    SyncService,
  ],
  exports: [SyncService],
})
export class SyncModule {}
