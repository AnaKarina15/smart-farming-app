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
import { Roles } from '@/common/decorators/roles.decorator';
import { RolesGuard } from '@/common/guards/roles.guard';
import { UserRole } from '@/modules/users/entities/user-role.enum';

import { AplicarRecomendacionDto } from './dto/aplicar-recomendacion.dto';
import { CreateReglaDto } from './dto/create-regla.dto';
import { ListReglasQueryDto } from './dto/list-reglas-query.dto';
import { RecomendacionEvaluadaResponseDto } from './dto/recomendacion-evaluada-response.dto';
import { ReglaResponseDto } from './dto/regla-response.dto';
import { UpdateReglaDto } from './dto/update-regla.dto';
import { RecomendacionesService } from './recomendaciones.service';

/**
 * Controller del Sistema Experto de Recomendaciones (Sprint 4).
 *
 * Expone DOS conjuntos de endpoints:
 *
 * 1. ADMIN (CRUD del catalogo de reglas) -> /admin/reglas
 *    Solo el rol administrador puede gestionar reglas.
 *
 * 2. PUBLICO (evaluar y aplicar) -> /recomendaciones
 *    Todos los productores pueden:
 *    - Consultar recomendaciones para sus lotes
 *    - Registrar la decision tomada (audit log)
 *
 * Marco etico aplicado:
 * - El sistema solo SUGIERE.
 * - El productor decide y queda registrado.
 * - Cada regla tiene fuente cientifica obligatoria.
 */
@ApiTags('Recomendaciones')
@Controller()
@UseGuards(JwtAuthGuard)
@ApiBearerAuth('JWT-auth')
export class RecomendacionesController {
  constructor(private readonly service: RecomendacionesService) {}

  // ══════════════════════════════════════════════════════════
  // ADMIN: CRUD de reglas (/admin/reglas)
  // ══════════════════════════════════════════════════════════

  @Post('admin/reglas')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMINISTRADOR)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: '[ADMIN] Crear una nueva regla del sistema experto',
    description:
      'Solo accesible para administradores. Cada regla debe llevar fuenteCientifica obligatoria.',
  })
  @ApiResponse({ status: 201, type: ReglaResponseDto })
  createRegla(@Body() dto: CreateReglaDto): Promise<ReglaResponseDto> {
    return this.service.createRegla(dto);
  }

  @Get('admin/reglas')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMINISTRADOR)
  @ApiOperation({
    summary: '[ADMIN] Listar todas las reglas del sistema experto',
    description:
      'Soporta filtros por tipo, cultivo, plaga, estado activa, y busqueda por codigo/nombre.',
  })
  @ApiResponse({ status: 200 })
  findAllReglas(@Query() query: ListReglasQueryDto) {
    return this.service.findAllReglas(query);
  }

  @Get('admin/reglas/:id')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMINISTRADOR)
  @ApiOperation({ summary: '[ADMIN] Obtener una regla por ID' })
  @ApiResponse({ status: 200, type: ReglaResponseDto })
  findReglaById(@Param('id', ParseUUIDPipe) id: string): Promise<ReglaResponseDto> {
    return this.service.findReglaById(id);
  }

  @Patch('admin/reglas/:id')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMINISTRADOR)
  @ApiOperation({
    summary: '[ADMIN] Actualizar una regla existente',
    description: 'No permite cambiar el codigo (identificador estable).',
  })
  @ApiResponse({ status: 200, type: ReglaResponseDto })
  updateRegla(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateReglaDto,
  ): Promise<ReglaResponseDto> {
    return this.service.updateRegla(id, dto);
  }

  @Delete('admin/reglas/:id')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMINISTRADOR)
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({
    summary: '[ADMIN] Eliminar (soft) una regla',
    description: 'Marca la regla como eliminada. La regla deja de evaluarse en el motor.',
  })
  @ApiResponse({ status: 204 })
  removeRegla(@Param('id', ParseUUIDPipe) id: string): Promise<void> {
    return this.service.removeRegla(id);
  }

  // ══════════════════════════════════════════════════════════
  // PUBLICO: evaluar recomendaciones (/recomendaciones)
  // ══════════════════════════════════════════════════════════

  @Get('recomendaciones/lote/:loteId')
  @ApiOperation({
    summary: 'Obtener recomendaciones aplicables para un lote',
    description:
      'El motor evalua TODAS las reglas activas contra el contexto del lote ' +
      '(cultivo, hallazgos abiertos, ultima siembra/fase, ultimo riego, estacion) ' +
      'y devuelve las recomendaciones que aplican, ordenadas por prioridad. ' +
      'El productor solo ve sus propios lotes (admin ve todos).',
  })
  @ApiResponse({ status: 200, type: [RecomendacionEvaluadaResponseDto] })
  evaluarRecomendaciones(
    @CurrentUser() user: JwtPayload,
    @Param('loteId', ParseUUIDPipe) loteId: string,
  ): Promise<RecomendacionEvaluadaResponseDto[]> {
    return this.service.evaluarRecomendacionesParaLote(loteId, user.sub, user.role);
  }

  @Post('recomendaciones/:reglaId/aplicar')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Registrar la decision del productor sobre una recomendacion',
    description:
      'Audit log: el productor indica si aplico, ignoro o aplico diferente la recomendacion. ' +
      'Marco etico: el sistema sugiere, el productor decide. Esta operacion deja trazabilidad.',
  })
  @ApiResponse({ status: 201 })
  aplicarRecomendacion(
    @CurrentUser() user: JwtPayload,
    @Param('reglaId', ParseUUIDPipe) reglaId: string,
    @Body() dto: AplicarRecomendacionDto,
  ) {
    return this.service.aplicarRecomendacion(reglaId, dto, user.sub, user.role);
  }

  @Get('recomendaciones/historial/:loteId')
  @ApiOperation({
    summary: 'Historial de recomendaciones aplicadas en un lote',
    description:
      'Devuelve todas las decisiones tomadas por el productor (aplicada/ignorada/aplicada_diferente) ' +
      'sobre recomendaciones de este lote. Util para reportes y seguimiento.',
  })
  @ApiResponse({ status: 200 })
  historialDelLote(
    @CurrentUser() user: JwtPayload,
    @Param('loteId', ParseUUIDPipe) loteId: string,
  ) {
    return this.service.historialDelLote(loteId, user.sub, user.role);
  }
}
