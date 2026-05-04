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
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiParam,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';

import { CurrentUser, JwtPayload } from '@/common/decorators/current-user.decorator';
import { JwtAuthGuard } from '@/common/guards/jwt-auth.guard';

import { CreateLoteDto } from './dto/create-lote.dto';
import { LoteResponseDto } from './dto/lote-response.dto';
import { UpdateLoteDto } from './dto/update-lote.dto';
import { LotesService } from './lotes.service';

@ApiTags('Lotes')
@Controller('lotes')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth('JWT-auth')
export class LotesController {
  constructor(private readonly lotesService: LotesService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Crear lote (RF04 - Registrar estado del terreno)',
    description: 'Crea una nueva parcela. Valida que la superficie total no exceda 5 hectareas.',
  })
  @ApiResponse({ status: 201, description: 'Lote creado', type: LoteResponseDto })
  @ApiResponse({ status: 400, description: 'Datos invalidos o superficie excede el limite' })
  async create(
    @CurrentUser() user: JwtPayload,
    @Body() dto: CreateLoteDto,
  ): Promise<LoteResponseDto> {
    return this.lotesService.create(user.sub, dto);
  }

  @Get()
  @ApiOperation({ summary: 'Listar lotes del productor autenticado' })
  @ApiResponse({ status: 200, description: 'Lista de lotes', type: [LoteResponseDto] })
  async findAll(@CurrentUser() user: JwtPayload): Promise<LoteResponseDto[]> {
    return this.lotesService.findAllByPropietario(user.sub);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Obtener detalle de un lote' })
  @ApiParam({ name: 'id', format: 'uuid' })
  @ApiResponse({ status: 200, description: 'Detalle del lote', type: LoteResponseDto })
  @ApiResponse({ status: 404, description: 'Lote no encontrado' })
  async findOne(
    @CurrentUser() user: JwtPayload,
    @Param('id', ParseUUIDPipe) id: string,
  ): Promise<LoteResponseDto> {
    return this.lotesService.findOne(id, user.sub);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Actualizar lote' })
  @ApiParam({ name: 'id', format: 'uuid' })
  @ApiResponse({ status: 200, description: 'Lote actualizado', type: LoteResponseDto })
  async update(
    @CurrentUser() user: JwtPayload,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateLoteDto,
  ): Promise<LoteResponseDto> {
    return this.lotesService.update(id, user.sub, dto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Eliminar lote' })
  @ApiParam({ name: 'id', format: 'uuid' })
  @ApiResponse({ status: 204, description: 'Lote eliminado' })
  async remove(
    @CurrentUser() user: JwtPayload,
    @Param('id', ParseUUIDPipe) id: string,
  ): Promise<void> {
    await this.lotesService.remove(id, user.sub);
  }
}
