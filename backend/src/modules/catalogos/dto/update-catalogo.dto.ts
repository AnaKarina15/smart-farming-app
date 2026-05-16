import { PartialType } from '@nestjs/swagger';

import { CreateCultivoDto } from './create-cultivo.dto';
import { CreateFertilizanteDto } from './create-fertilizante.dto';
import { CreateMunicipioDto } from './create-municipio.dto';
import { CreatePlagaDto } from './create-plaga.dto';
import { CreateTipoSueloDto } from './create-tipo-suelo.dto';

export class UpdateMunicipioDto extends PartialType(CreateMunicipioDto) {}
export class UpdateCultivoDto extends PartialType(CreateCultivoDto) {}
export class UpdatePlagaDto extends PartialType(CreatePlagaDto) {}
export class UpdateFertilizanteDto extends PartialType(CreateFertilizanteDto) {}
export class UpdateTipoSueloDto extends PartialType(CreateTipoSueloDto) {}
