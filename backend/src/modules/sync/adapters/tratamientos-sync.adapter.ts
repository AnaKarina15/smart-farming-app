import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';

import { Hallazgo } from '../../hallazgos/entities/hallazgo.entity';
import { METODOS_APLICACION_TRATAMIENTO } from '../../tratamientos/dto/create-tratamiento.dto';
import { Tratamiento } from '../../tratamientos/entities/tratamiento.entity';
import { AbstractSyncResourceAdapter } from './abstract-sync-resource.adapter';
import { SyncWriteContext, SyncWriteExistingContext } from './sync-resource.adapter';

@Injectable()
export class TratamientosSyncAdapter extends AbstractSyncResourceAdapter<Tratamiento> {
  readonly resourceType = 'tratamientos';
  readonly endpointAliases = ['tratamientos', 'tratamiento'];
  readonly pullKey = 'tratamientos';

  constructor() {
    super(Tratamiento, 'Tratamiento', 'tratamiento');
  }

  async create(context: SyncWriteContext): Promise<string> {
    const { manager, item, user, clientUpdatedAt } = context;
    const payload = item.payload;
    const loteId = this.requiredString(payload, 'loteId');
    const hallazgoId = this.optionalString(payload, 'hallazgoId');
    const metodoAplicacion = this.optionalString(payload, 'metodoAplicacion');

    await this.assertLoteOwnership(manager, loteId, user);

    if (hallazgoId) {
      await this.assertHallazgoDelLote(manager, hallazgoId, loteId);
    }

    if (metodoAplicacion) {
      this.assertIn(metodoAplicacion, METODOS_APLICACION_TRATAMIENTO, 'metodoAplicacion');
    }

    const entity = manager.create(Tratamiento, {
      loteId,
      hallazgoId,
      producto: this.requiredString(payload, 'producto'),
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
    entity: Tratamiento,
  ): Promise<Record<string, unknown>> {
    const { manager, item } = context;
    const payload = item.payload;
    const hallazgoId = this.optionalString(payload, 'hallazgoId');
    const metodoAplicacion = this.optionalString(payload, 'metodoAplicacion');

    if (payload.hallazgoId !== undefined && hallazgoId) {
      await this.assertHallazgoDelLote(manager, hallazgoId, entity.loteId);
    }

    if (metodoAplicacion) {
      this.assertIn(metodoAplicacion, METODOS_APLICACION_TRATAMIENTO, 'metodoAplicacion');
    }

    return this.pick(
      payload,
      ['hallazgoId', 'producto', 'dosis', 'unidad', 'metodoAplicacion', 'observaciones'],
      ['fecha'],
    );
  }

  private async assertHallazgoDelLote(
    manager: SyncWriteContext['manager'],
    hallazgoId: string,
    loteId: string,
  ): Promise<void> {
    const hallazgo = await manager.findOne(Hallazgo, {
      where: { id: hallazgoId },
    });

    if (!hallazgo) {
      throw new NotFoundException(`Hallazgo ${hallazgoId} no encontrado`);
    }

    if (hallazgo.loteId !== loteId) {
      throw new BadRequestException('El hallazgo asociado no pertenece al lote indicado');
    }
  }
}
