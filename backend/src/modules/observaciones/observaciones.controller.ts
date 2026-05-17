import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';

import { CurrentUser, JwtPayload } from '@/common/decorators/current-user.decorator';
import { JwtAuthGuard } from '@/common/guards/jwt-auth.guard';

import { CreateObservacionDto } from './dto/create-observacion.dto';
import { ListObservacionesQueryDto } from './dto/list-observaciones-query.dto';
import { ObservacionResponseDto } from './dto/observacion-response.dto';
import { UpdateObservacionDto } from './dto/update-observacion.dto';
import { ObservacionesService } from './observaciones.service';

@ApiTags('Observaciones')
@Controller('observaciones')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth('JWT-auth')
export class ObservacionesController {
  constructor(private readonly observacionesService: ObservacionesService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Registrar una observacion sobre el lote',
    description: 'Notas libres del productor (clima, fauna, eventos, recordatorios, etc.)',
  })
  @ApiResponse({ status: 201, type: ObservacionResponseDto })
  create(
    @CurrentUser() user: JwtPayload,
    @Body() dto: CreateObservacionDto,
  ): Promise<ObservacionResponseDto> {
    return this.observacionesService.create(dto, user.sub, user.role);
  }

  @Get()
  @ApiOperation({
    summary: 'Listar observaciones',
    description: 'El usuario ve las suyas. Admin ve todas. Soporta filtros por loteId y tipo.',
  })
  @ApiResponse({ status: 200 })
  findAll(@CurrentUser() user: JwtPayload, @Query() query: ListObservacionesQueryDto) {
    return this.observacionesService.findAll(query, user.sub, user.role);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Obtener una observacion por ID' })
  @ApiResponse({ status: 200, type: ObservacionResponseDto })
  findOne(
    @CurrentUser() user: JwtPayload,
    @Param('id', ParseUUIDPipe) id: string,
  ): Promise<ObservacionResponseDto> {
    return this.observacionesService.findOne(id, user.sub, user.role);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Actualizar una observacion existente' })
  @ApiResponse({ status: 200, type: ObservacionResponseDto })
  update(
    @CurrentUser() user: JwtPayload,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateObservacionDto,
  ): Promise<ObservacionResponseDto> {
    return this.observacionesService.update(id, dto, user.sub, user.role);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Eliminar (soft) una observacion' })
  @ApiResponse({ status: 204 })
  remove(@CurrentUser() user: JwtPayload, @Param('id', ParseUUIDPipe) id: string): Promise<void> {
    return this.observacionesService.remove(id, user.sub, user.role);
  }
}
