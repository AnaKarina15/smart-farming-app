import { OmitType, PartialType } from '@nestjs/swagger';

import { CreateReglaDto } from './create-regla.dto';

/**
 * Todos los campos son opcionales y NO permite cambiar el codigo
 * (el codigo es identificador estable de la regla).
 */
export class UpdateReglaDto extends PartialType(OmitType(CreateReglaDto, ['codigo'] as const)) {}
