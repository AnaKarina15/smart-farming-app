import { OmitType, PartialType } from '@nestjs/swagger';

import { CreateObservacionDto } from './create-observacion.dto';

export class UpdateObservacionDto extends PartialType(
  OmitType(CreateObservacionDto, ['loteId'] as const),
) {}
