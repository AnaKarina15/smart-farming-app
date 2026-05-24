import { BadRequestException, Injectable } from '@nestjs/common';

import { TIPOS_RIEGO } from '../../riego/dto/create-riego.dto';
import { Riego } from '../../riego/entities/riego.entity';
import { AbstractSyncResourceAdapter } from './abstract-sync-resource.adapter';
import { SyncWriteContext, SyncWriteExistingContext } from './sync-resource.adapter';

@Injectable()
export class RiegoSyncAdapter extends AbstractSyncResourceAdapter<Riego> {
  readonly resourceType = 'riego';
  readonly endpointAliases = ['riego'];
  readonly pullKey = 'riego';

  constructor() {
    super(Riego, 'Riego', 'riego');
  }

  async create(context: SyncWriteContext): Promise<string> {
    const { manager, item, user, clientUpdatedAt } = context;
    const payload = item.payload;
    const loteId = this.requiredString(payload, 'loteId');
    const tipo = this.requiredString(payload, 'tipo');
    const humedad = this.optionalNumber(payload, 'humedad');

    await this.assertLoteOwnership(manager, loteId, user);
    this.assertIn(tipo, TIPOS_RIEGO, 'tipo');

    if (humedad !== null && humedad > 100) {
      throw new BadRequestException('humedad debe estar entre 0 y 100');
    }

    const entity = manager.create(Riego, {
      loteId,
      tipo,
      duracionMinutos: this.optionalNumber(payload, 'duracionMinutos'),
      cantidadLitros: this.optionalNumber(payload, 'cantidadLitros'),
      fecha: this.requiredDate(payload, 'fecha'),
      humedad,
      observaciones: this.optionalString(payload, 'observaciones'),
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
    const humedad = this.optionalNumber(payload, 'humedad');

    if (tipo) {
      this.assertIn(tipo, TIPOS_RIEGO, 'tipo');
    }

    if (payload.humedad !== undefined && humedad !== null && humedad > 100) {
      throw new BadRequestException('humedad debe estar entre 0 y 100');
    }

    return this.pick(
      payload,
      ['tipo', 'duracionMinutos', 'cantidadLitros', 'humedad', 'observaciones'],
      ['fecha'],
    );
  }
}
