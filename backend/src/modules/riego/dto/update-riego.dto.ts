import { OmitType, PartialType } from '@nestjs/swagger';

import { CreateRiegoDto } from './create-riego.dto';

/**
 * DTO para actualizar un Riego.
 * loteId NO se permite cambiar (un riego pertenece a un lote especifico).
 */
export class UpdateRiegoDto extends PartialType(OmitType(CreateRiegoDto, ['loteId'] as const)) {}
