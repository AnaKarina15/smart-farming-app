import { Injectable, NotFoundException } from '@nestjs/common';

import { TipoSuelo } from '../../catalogos/entities/tipo-suelo.entity';
import { EstadoTerreno } from '../../estado-terreno/entities/estado-terreno.entity';
import { Siembra } from '../../siembras/entities/siembra.entity';
import { AbstractSyncResourceAdapter } from './abstract-sync-resource.adapter';
import { SyncWriteContext, SyncWriteExistingContext } from './sync-resource.adapter';

@Injectable()
export class EstadoTerrenoSyncAdapter extends AbstractSyncResourceAdapter<EstadoTerreno> {
  readonly resourceType = 'estado-terreno';
  readonly endpointAliases = ['estado-terreno', 'estado_terreno'];
  readonly pullKey = 'estadoTerreno';

  constructor() {
    super(EstadoTerreno, 'EstadoTerreno', 'estado_terreno');
  }

  async create(context: SyncWriteContext): Promise<string> {
    const { manager, item, user, clientUpdatedAt } = context;
    const payload = item.payload;
    const loteId = this.requiredString(payload, 'loteId');
    const siembraId = this.optionalString(payload, 'siembraId');
    const tipoSueloId = this.optionalString(payload, 'tipoSueloId');

    await this.assertLoteOwnership(manager, loteId, user);

    if (siembraId) {
      await this.assertSiembraExists(manager, siembraId);
    }

    if (tipoSueloId) {
      await this.assertExists(manager, TipoSuelo, tipoSueloId, 'Tipo de suelo');
    }

    const entity = manager.create(EstadoTerreno, {
      loteId,
      siembraId,
      estado: this.requiredString(payload, 'estado'),
      tipoSueloId,
      notas: this.optionalString(payload, 'notas') ?? this.optionalString(payload, 'observaciones'),
      userId: user.sub,
      createdAt:
        this.optionalDate(payload, 'createdAt') ??
        this.optionalDate(payload, 'fecha') ??
        clientUpdatedAt,
      updatedAt: clientUpdatedAt,
    });

    return (await manager.save(entity)).id;
  }

  protected async buildUpdatePatch(
    context: SyncWriteExistingContext,
  ): Promise<Record<string, unknown>> {
    const { manager, item } = context;
    const payload = item.payload;
    const siembraId = this.optionalString(payload, 'siembraId');
    const tipoSueloId = this.optionalString(payload, 'tipoSueloId');

    if (payload.siembraId !== undefined && siembraId) {
      await this.assertSiembraExists(manager, siembraId);
    }

    if (payload.tipoSueloId !== undefined && tipoSueloId) {
      await this.assertExists(manager, TipoSuelo, tipoSueloId, 'Tipo de suelo');
    }

    const patch = this.pick(payload, ['siembraId', 'estado', 'tipoSueloId', 'notas']);

    if (payload.observaciones !== undefined && patch.notas === undefined) {
      patch.notas = this.optionalString(payload, 'observaciones');
    }

    return patch;
  }

  private async assertSiembraExists(
    manager: SyncWriteContext['manager'],
    siembraId: string,
  ): Promise<void> {
    const siembra = await manager.findOne(Siembra, {
      where: { id: siembraId },
    });

    if (!siembra) {
      throw new NotFoundException(`Siembra ${siembraId} no encontrada`);
    }
  }
}
