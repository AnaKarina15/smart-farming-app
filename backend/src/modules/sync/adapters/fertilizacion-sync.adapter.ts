import { BadRequestException, Injectable } from '@nestjs/common';

import { Fertilizante } from '../../catalogos/entities/fertilizante.entity';
import { METODOS_APLICACION } from '../../fertilizacion/dto/create-fertilizacion.dto';
import { Fertilizacion } from '../../fertilizacion/entities/fertilizacion.entity';
import { AbstractSyncResourceAdapter } from './abstract-sync-resource.adapter';
import { SyncWriteContext, SyncWriteExistingContext } from './sync-resource.adapter';

@Injectable()
export class FertilizacionSyncAdapter extends AbstractSyncResourceAdapter<Fertilizacion> {
  readonly resourceType = 'fertilizacion';
  readonly endpointAliases = ['fertilizacion', 'fertilizaciones'];
  readonly pullKey = 'fertilizacion';

  constructor() {
    super(Fertilizacion, 'Fertilizacion', 'fertilizacion');
  }

  async create(context: SyncWriteContext): Promise<string> {
    const { manager, item, user, clientUpdatedAt } = context;
    const payload = item.payload;
    const loteId = this.requiredString(payload, 'loteId');
    const fertilizanteId = this.optionalString(payload, 'fertilizanteId');
    const fertilizanteOtro = this.optionalString(payload, 'fertilizanteOtro');
    const metodoAplicacion = this.optionalString(payload, 'metodoAplicacion');

    await this.assertLoteOwnership(manager, loteId, user);

    if (!fertilizanteId && !fertilizanteOtro) {
      throw new BadRequestException('Debe especificar fertilizanteId o fertilizanteOtro');
    }

    if (fertilizanteId) {
      await this.assertExists(manager, Fertilizante, fertilizanteId, 'Fertilizante');
    }

    if (metodoAplicacion) {
      this.assertIn(metodoAplicacion, METODOS_APLICACION, 'metodoAplicacion');
    }

    const entity = manager.create(Fertilizacion, {
      loteId,
      fertilizanteId,
      fertilizanteOtro,
      dosis: this.optionalNumber(payload, 'dosis'),
      unidad: this.optionalString(payload, 'unidad'),
      metodoAplicacion,
      fecha: this.requiredDate(payload, 'fecha'),
      observaciones: this.optionalString(payload, 'observaciones'),
      userId: user.sub,
      createdAt: this.optionalDate(payload, 'createdAt') ?? clientUpdatedAt,
      updatedAt: clientUpdatedAt,
    });

    return (await manager.save(entity)).id;
  }

  protected async buildUpdatePatch(
    context: SyncWriteExistingContext,
    entity: Fertilizacion,
  ): Promise<Record<string, unknown>> {
    const { manager, item } = context;
    const payload = item.payload;
    const fertilizanteId = this.optionalString(payload, 'fertilizanteId');
    const fertilizanteOtro = this.optionalString(payload, 'fertilizanteOtro');
    const metodoAplicacion = this.optionalString(payload, 'metodoAplicacion');

    if (fertilizanteId) {
      await this.assertExists(manager, Fertilizante, fertilizanteId, 'Fertilizante');
    }

    if (payload.fertilizanteId !== undefined || payload.fertilizanteOtro !== undefined) {
      const finalFertilizanteId =
        payload.fertilizanteId !== undefined ? fertilizanteId : entity.fertilizanteId;
      const finalFertilizanteOtro =
        payload.fertilizanteOtro !== undefined ? fertilizanteOtro : entity.fertilizanteOtro;

      if (!finalFertilizanteId && !finalFertilizanteOtro) {
        throw new BadRequestException('Debe quedar fertilizanteId o fertilizanteOtro');
      }
    }

    if (metodoAplicacion) {
      this.assertIn(metodoAplicacion, METODOS_APLICACION, 'metodoAplicacion');
    }

    return this.pick(
      payload,
      [
        'fertilizanteId',
        'fertilizanteOtro',
        'dosis',
        'unidad',
        'metodoAplicacion',
        'observaciones',
      ],
      ['fecha'],
    );
  }
}
