import { BadRequestException, Injectable } from '@nestjs/common';
import { EntityManager, MoreThan } from 'typeorm';

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

    // Solo refleja el cultivo en el lote si esta siembra es la mas reciente.
    // Evita que sincronizar una siembra antigua (creada offline hace dias)
    // sobrescriba el cultivo actual del lote con uno desactualizado.
    if (await this.esLaSiembraMasReciente(manager, loteId, saved)) {
      await this.updateLoteCultivoActual(manager, loteId, cultivoId, cultivoOtro);
    }

    return saved.id;
  }

  /**
   * Determina si una siembra es la mas reciente del lote (por fecha).
   * Empate de fecha se desempata por createdAt para un resultado estable.
   */
  private async esLaSiembraMasReciente(
    manager: EntityManager,
    loteId: string,
    siembra: Siembra,
  ): Promise<boolean> {
    const masNueva = await manager.findOne(Siembra, {
      where: { loteId, fecha: MoreThan(siembra.fecha) },
      order: { fecha: 'DESC' },
    });

    if (masNueva) {
      return false;
    }

    // Misma fecha: gana la creada mas recientemente.
    const mismaFecha = await manager.find(Siembra, {
      where: { loteId, fecha: siembra.fecha },
      order: { createdAt: 'DESC' },
      take: 1,
    });

    return mismaFecha.length === 0 || mismaFecha[0].id === siembra.id;
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
      // Igual que en create: solo refleja el cultivo en el lote si esta
      // siembra sigue siendo la mas reciente del lote tras la edicion.
      if (await this.esLaSiembraMasReciente(manager, entity.loteId, entity)) {
        await this.updateLoteCultivoActual(
          manager,
          entity.loteId,
          (patch.cultivoId as string | null | undefined) ?? entity.cultivoId,
          (patch.cultivoOtro as string | null | undefined) ?? entity.cultivoOtro,
        );
      }
    }

    return patch;
  }
}
