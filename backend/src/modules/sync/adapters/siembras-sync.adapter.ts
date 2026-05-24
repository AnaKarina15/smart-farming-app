import { BadRequestException, Injectable } from '@nestjs/common';

import { Cultivo } from '../../catalogos/entities/cultivo.entity';
import { Siembra } from '../../siembras/entities/siembra.entity';
import { AbstractSyncResourceAdapter } from './abstract-sync-resource.adapter';
import { SyncWriteContext, SyncWriteExistingContext } from './sync-resource.adapter';

@Injectable()
export class SiembrasSyncAdapter extends AbstractSyncResourceAdapter<Siembra> {
  readonly resourceType = 'siembras';
  readonly endpointAliases = ['siembras', 'siembra'];
  readonly pullKey = 'siembras';

  constructor() {
    super(Siembra, 'Siembra', 'siembra');
  }

  async create(context: SyncWriteContext): Promise<string> {
    const { manager, item, user, clientUpdatedAt } = context;
    const payload = item.payload;
    const loteId = this.requiredString(payload, 'loteId');

    await this.assertLoteOwnership(manager, loteId, user);

    const cultivoId = this.optionalString(payload, 'cultivoId');
    const cultivoOtro = this.optionalString(payload, 'cultivoOtro');

    if (!cultivoId && !cultivoOtro) {
      throw new BadRequestException('Debe especificar cultivoId o cultivoOtro');
    }

    if (cultivoId) {
      await this.assertExists(manager, Cultivo, cultivoId, 'Cultivo');
    }

    const entity = manager.create(Siembra, {
      loteId,
      cultivoId,
      cultivoOtro,
      variedad: this.optionalString(payload, 'variedad'),
      fecha: this.requiredDate(payload, 'fecha'),
      cantidadSemillas: this.optionalNumber(payload, 'cantidadSemillas'),
      unidad: this.optionalString(payload, 'unidad'),
      distanciaEntreFilas: this.optionalNumber(payload, 'distanciaEntreFilas'),
      distanciaEntrePlantas: this.optionalNumber(payload, 'distanciaEntrePlantas'),
      observaciones: this.optionalString(payload, 'observaciones'),
      userId: user.sub,
      createdAt: this.optionalDate(payload, 'createdAt') ?? clientUpdatedAt,
      updatedAt: clientUpdatedAt,
    });

    const saved = await manager.save(entity);
    await this.updateLoteCultivoActual(manager, loteId, cultivoId, cultivoOtro);

    return saved.id;
  }

  protected async buildUpdatePatch(
    context: SyncWriteExistingContext,
    entity: Siembra,
  ): Promise<Record<string, unknown>> {
    const { manager, item } = context;
    const payload = item.payload;
    const cultivoId = this.optionalString(payload, 'cultivoId');
    const cultivoOtro = this.optionalString(payload, 'cultivoOtro');

    if (cultivoId) {
      await this.assertExists(manager, Cultivo, cultivoId, 'Cultivo');
    }

    if (payload.cultivoId !== undefined || payload.cultivoOtro !== undefined) {
      const finalCultivoId = payload.cultivoId !== undefined ? cultivoId : entity.cultivoId;
      const finalCultivoOtro = payload.cultivoOtro !== undefined ? cultivoOtro : entity.cultivoOtro;

      if (!finalCultivoId && !finalCultivoOtro) {
        throw new BadRequestException('Debe quedar cultivoId o cultivoOtro');
      }
    }

    const patch = this.pick(
      payload,
      [
        'cultivoId',
        'cultivoOtro',
        'variedad',
        'cantidadSemillas',
        'unidad',
        'distanciaEntreFilas',
        'distanciaEntrePlantas',
        'observaciones',
      ],
      ['fecha'],
    );

    if (patch.cultivoId !== undefined || patch.cultivoOtro !== undefined) {
      await this.updateLoteCultivoActual(
        manager,
        entity.loteId,
        (patch.cultivoId as string | null | undefined) ?? entity.cultivoId,
        (patch.cultivoOtro as string | null | undefined) ?? entity.cultivoOtro,
      );
    }

    return patch;
  }
}
