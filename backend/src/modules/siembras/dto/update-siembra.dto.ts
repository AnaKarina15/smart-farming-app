import { PartialType, OmitType } from '@nestjs/swagger';

import { CreateSiembraDto } from './create-siembra.dto';

/**
 * DTO para actualizar una Siembra.
 * - loteId NO se permite cambiar (una siembra no se "mueve" entre lotes).
 */
export class UpdateSiembraDto extends PartialType(
  OmitType(CreateSiembraDto, ['loteId'] as const),
) {}
