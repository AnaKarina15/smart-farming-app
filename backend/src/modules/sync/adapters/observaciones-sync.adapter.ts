import { Injectable } from '@nestjs/common';

import { TIPOS_OBSERVACION } from '../../observaciones/dto/create-observacion.dto';
import { Observacion } from '../../observaciones/entities/observacion.entity';
import { AbstractSyncResourceAdapter } from './abstract-sync-resource.adapter';
import { SyncWriteContext, SyncWriteExistingContext } from './sync-resource.adapter';

@Injectable()
export class ObservacionesSyncAdapter extends AbstractSyncResourceAdapter<Observacion> {
  readonly resourceType = 'observaciones';
  readonly endpointAliases = ['observaciones', 'observacion'];
  readonly pullKey = 'observaciones';

  constructor() {
    super(Observacion, 'Observacion', 'observacion');
  }

  async create(context: SyncWriteContext): Promise<string> {
    const { manager, item, user, clientUpdatedAt } = context;
    const payload = item.payload;
    const loteId = this.requiredString(payload, 'loteId');
    const tipo = this.optionalString(payload, 'tipo');

    await this.assertLoteOwnership(manager, loteId, user);

    if (tipo) {
      this.assertIn(tipo, TIPOS_OBSERVACION, 'tipo');
    }

    const entity = manager.create(Observacion, {
      loteId,
      descripcion: this.requiredString(payload, 'descripcion'),
      tipo,
      fecha: this.requiredDate(payload, 'fecha'),
      userId: user.sub,
      createdAt: this.optionalDate(payload, 'createdAt') ?? clientUpdatedAt,
      updatedAt: clientUpdatedAt,
    });

    return (await manager.save(entity)).id;
  }

  protected async buildUpdatePatch(
    context: SyncWriteExistingContext,
  ): Promise<Record<string, unknown>> {
    const payload = context.item.payload;
    const tipo = this.optionalString(payload, 'tipo');

    if (tipo) {
      this.assertIn(tipo, TIPOS_OBSERVACION, 'tipo');
    }

    return this.pick(payload, ['descripcion', 'tipo'], ['fecha']);
  }
}
