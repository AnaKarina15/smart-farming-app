import { OmitType, PartialType } from '@nestjs/swagger';

import { CreateTratamientoDto } from './create-tratamiento.dto';

export class UpdateTratamientoDto extends PartialType(
  OmitType(CreateTratamientoDto, ['loteId'] as const),
) {}
