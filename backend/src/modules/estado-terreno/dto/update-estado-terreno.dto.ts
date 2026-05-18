import { PartialType } from '@nestjs/swagger';
import { CreateEstadoTerrenoDto } from './create-estado-terreno.dto';

export class UpdateEstadoTerrenoDto extends PartialType(CreateEstadoTerrenoDto) {}
