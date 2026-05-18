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

import { CreateEstadoTerrenoDto } from './dto/create-estado-terreno.dto';
import { ListEstadoTerrenoQueryDto } from './dto/list-estado-terreno-query.dto';
import { EstadoTerrenoResponseDto } from './dto/estado-terreno-response.dto';
import { UpdateEstadoTerrenoDto } from './dto/update-estado-terreno.dto';
import { EstadoTerrenoService } from './estado-terreno.service';

@ApiTags('EstadoTerreno')
@Controller('estado-terreno')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth('JWT-auth')
export class EstadoTerrenoController {
  constructor(private readonly estadoTerrenoService: EstadoTerrenoService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Registrar caracterización física y de preparación del suelo de un lote',
    description: 'Permite registrar o actualizar el estado del lote (antes y después de siembra) y vincularlo a un tipo de suelo del catálogo',
  })
  @ApiResponse({ status: 201, type: EstadoTerrenoResponseDto })
  create(
    @CurrentUser() user: JwtPayload,
    @Body() dto: CreateEstadoTerrenoDto,
  ): Promise<EstadoTerrenoResponseDto> {
    return this.estadoTerrenoService.create(dto, user.sub, user.role);
  }

  @Get()
  @ApiOperation({
    summary: 'Listar registros de estado del terreno',
    description: 'El productor ve solo sus registros. El administrador ve todos. Soporta filtros por loteId y siembraId.',
  })
  @ApiResponse({ status: 200 })
  findAll(@CurrentUser() user: JwtPayload, @Query() query: ListEstadoTerrenoQueryDto) {
    return this.estadoTerrenoService.findAll(query, user.sub, user.role);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Obtener un registro de estado de terreno por ID' })
  @ApiResponse({ status: 200, type: EstadoTerrenoResponseDto })
  findOne(
    @CurrentUser() user: JwtPayload,
    @Param('id', ParseUUIDPipe) id: string,
  ): Promise<EstadoTerrenoResponseDto> {
    return this.estadoTerrenoService.findOne(id, user.sub, user.role);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Actualizar un registro existente de estado de terreno' })
  @ApiResponse({ status: 200, type: EstadoTerrenoResponseDto })
  update(
    @CurrentUser() user: JwtPayload,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateEstadoTerrenoDto,
  ): Promise<EstadoTerrenoResponseDto> {
    return this.estadoTerrenoService.update(id, dto, user.sub, user.role);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Eliminar (soft) un registro de estado de terreno' })
  @ApiResponse({ status: 204 })
  remove(@CurrentUser() user: JwtPayload, @Param('id', ParseUUIDPipe) id: string): Promise<void> {
    return this.estadoTerrenoService.remove(id, user.sub, user.role);
  }
}
