import { OmitType, PartialType } from '@nestjs/swagger';

import { CreateFertilizacionDto } from './create-fertilizacion.dto';

export class UpdateFertilizacionDto extends PartialType(
  OmitType(CreateFertilizacionDto, ['loteId'] as const),
) {}
