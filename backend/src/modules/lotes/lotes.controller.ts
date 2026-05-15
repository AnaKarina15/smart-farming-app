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
import {
  ApiBearerAuth,
  ApiOperation,
  ApiParam,
  ApiQuery,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';

import { CurrentUser, JwtPayload } from '@/common/decorators/current-user.decorator';
import { Roles } from '@/common/decorators/roles.decorator';
import { JwtAuthGuard } from '@/common/guards/jwt-auth.guard';
import { RolesGuard } from '@/common/guards/roles.guard';
import { UserRole } from '@/modules/users/entities/user-role.enum';

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
  async create(
    @CurrentUser() user: JwtPayload,
    @Body() dto: CreateLoteDto,
  ): Promise<LoteResponseDto> {
    return this.lotesService.create(user.sub, dto);
  }

  @Get()
  @ApiOperation({
    summary: 'Listar lotes',
    description:
      'Si el usuario es PEQUENO_PRODUCTOR, lista solo SUS lotes. ' +
      'Si es ADMINISTRADOR, lista TODOS los lotes del sistema.',
  })
  @ApiResponse({ status: 200, type: [LoteResponseDto] })
  async findAll(@CurrentUser() user: JwtPayload): Promise<LoteResponseDto[]> {
    // Admin ve todos los lotes, otros usuarios solo los suyos
    if (user.role === UserRole.ADMINISTRADOR) {
      return this.lotesService.findAll();
    }
    return this.lotesService.findAllByPropietario(user.sub);
  }

  @Get('admin/todos')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMINISTRADOR)
  @ApiOperation({
    summary: '[ADMIN] Listar TODOS los lotes con filtros',
    description: 'Endpoint dedicado para admin. Permite filtrar por propietario.',
  })
  @ApiQuery({ name: 'propietarioId', required: false, format: 'uuid' })
  @ApiResponse({ status: 200, type: [LoteResponseDto] })
  async findAllAdmin(@Query('propietarioId') propietarioId?: string): Promise<LoteResponseDto[]> {
    if (propietarioId) {
      return this.lotesService.findAllByPropietario(propietarioId);
    }
    return this.lotesService.findAll();
  }

  @Get('admin/stats')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMINISTRADOR)
  @ApiOperation({ summary: '[ADMIN] Estadisticas de lotes' })
  async getStats() {
    return this.lotesService.getStats();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Obtener detalle de un lote' })
  @ApiParam({ name: 'id', format: 'uuid' })
  async findOne(
    @CurrentUser() user: JwtPayload,
    @Param('id', ParseUUIDPipe) id: string,
  ): Promise<LoteResponseDto> {
    // Admin puede ver cualquier lote, otros solo los suyos
    if (user.role === UserRole.ADMINISTRADOR) {
      return this.lotesService.findOneAdmin(id);
    }
    return this.lotesService.findOne(id, user.sub);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Actualizar lote' })
  @ApiParam({ name: 'id', format: 'uuid' })
  async update(
    @CurrentUser() user: JwtPayload,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateLoteDto,
  ): Promise<LoteResponseDto> {
    return this.lotesService.update(id, user.sub, dto, user.role as UserRole);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Eliminar lote' })
  @ApiParam({ name: 'id', format: 'uuid' })
  async remove(
    @CurrentUser() user: JwtPayload,
    @Param('id', ParseUUIDPipe) id: string,
  ): Promise<void> {
    await this.lotesService.remove(id, user.sub, user.role as UserRole);
  }
}
