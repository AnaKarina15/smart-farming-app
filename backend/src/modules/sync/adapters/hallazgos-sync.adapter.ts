import { BadRequestException, Injectable } from '@nestjs/common';

import { Plaga } from '../../catalogos/entities/plaga.entity';
import { SEVERIDADES } from '../../hallazgos/dto/create-hallazgo.dto';
import { Hallazgo } from '../../hallazgos/entities/hallazgo.entity';
import { AbstractSyncResourceAdapter } from './abstract-sync-resource.adapter';
import { SyncWriteContext, SyncWriteExistingContext } from './sync-resource.adapter';

@Injectable()
export class HallazgosSyncAdapter extends AbstractSyncResourceAdapter<Hallazgo> {
  readonly resourceType = 'hallazgos';
  readonly endpointAliases = ['hallazgos', 'hallazgo'];
  readonly pullKey = 'hallazgos';

  constructor() {
    super(Hallazgo, 'Hallazgo', 'hallazgo');
  }

  async create(context: SyncWriteContext): Promise<string> {
    const { manager, item, user, clientUpdatedAt } = context;
    const payload = item.payload;
    const loteId = this.requiredString(payload, 'loteId');
    const plagaId = this.optionalString(payload, 'plagaId');
    const plagaOtro = this.optionalString(payload, 'plagaOtro');
    const severidad = this.requiredString(payload, 'severidad');

    await this.assertLoteOwnership(manager, loteId, user);

    if (!plagaId && !plagaOtro) {
      throw new BadRequestException('Debe especificar plagaId o plagaOtro');
    }

    if (plagaId) {
      await this.assertExists(manager, Plaga, plagaId, 'Plaga');
    }

    this.assertIn(severidad, SEVERIDADES, 'severidad');

    const entity = manager.create(Hallazgo, {
      loteId,
      plagaId,
      plagaOtro,
      severidad,
      descripcion: this.optionalString(payload, 'descripcion'),
      fotoPath: this.optionalString(payload, 'fotoPath'),
      fecha: this.requiredDate(payload, 'fecha'),
      userId: user.sub,
      createdAt: this.optionalDate(payload, 'createdAt') ?? clientUpdatedAt,
      updatedAt: clientUpdatedAt,
    });

    return (await manager.save(entity)).id;
  }

  protected async buildUpdatePatch(
    context: SyncWriteExistingContext,
    entity: Hallazgo,
  ): Promise<Record<string, unknown>> {
    const { manager, item } = context;
    const payload = item.payload;
    const plagaId = this.optionalString(payload, 'plagaId');
    const plagaOtro = this.optionalString(payload, 'plagaOtro');
    const severidad = this.optionalString(payload, 'severidad');

    if (plagaId) {
      await this.assertExists(manager, Plaga, plagaId, 'Plaga');
    }

    if (payload.plagaId !== undefined || payload.plagaOtro !== undefined) {
      const finalPlagaId = payload.plagaId !== undefined ? plagaId : entity.plagaId;
      const finalPlagaOtro = payload.plagaOtro !== undefined ? plagaOtro : entity.plagaOtro;

      if (!finalPlagaId && !finalPlagaOtro) {
        throw new BadRequestException('Debe quedar plagaId o plagaOtro');
      }
    }

    if (severidad) {
      this.assertIn(severidad, SEVERIDADES, 'severidad');
    }

    return this.pick(
      payload,
      ['plagaId', 'plagaOtro', 'severidad', 'descripcion', 'fotoPath'],
      ['fecha'],
    );
  }
}
