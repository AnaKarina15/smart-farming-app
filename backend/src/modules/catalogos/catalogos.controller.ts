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
import { ApiBearerAuth, ApiOperation, ApiParam, ApiResponse, ApiTags } from '@nestjs/swagger';

import { Roles } from '../../common/decorators/roles.decorator';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { UserRole } from '../users/entities/user-role.enum';

import { CatalogosService } from './catalogos.service';
import { CreateCultivoDto } from './dto/create-cultivo.dto';
import { CreateFertilizanteDto } from './dto/create-fertilizante.dto';
import { CreateMunicipioDto } from './dto/create-municipio.dto';
import { CreatePlagaDto } from './dto/create-plaga.dto';
import { CreateTipoSueloDto } from './dto/create-tipo-suelo.dto';
import { CultivoResponseDto } from './dto/cultivo-response.dto';
import { FertilizanteResponseDto } from './dto/fertilizante-response.dto';
import { MunicipioResponseDto } from './dto/municipio-response.dto';
import { PlagaResponseDto } from './dto/plaga-response.dto';
import { TipoSueloResponseDto } from './dto/tipo-suelo-response.dto';
import {
  UpdateCultivoDto,
  UpdateFertilizanteDto,
  UpdateMunicipioDto,
  UpdatePlagaDto,
  UpdateTipoSueloDto,
} from './dto/update-catalogo.dto';

/**
 * Catalogos del dominio agricola del Magdalena.
 *
 * - GET (lectura): autenticado, accesible para todos los roles.
 * - POST/PATCH/DELETE (escritura): solo administradores.
 *
 * Los catalogos son datos de referencia que alimentan los dropdowns
 * de las pantallas operativas del frontend (siembra, riego, fertilizacion,
 * fitosanitario).
 */
@ApiTags('Catalogos')
@ApiBearerAuth('JWT-auth')
@UseGuards(JwtAuthGuard)
@Controller('catalogos')
export class CatalogosController {
  constructor(private readonly service: CatalogosService) {}

  // ════════════════════════════════════════════════════════
  // MUNICIPIOS
  // ════════════════════════════════════════════════════════

  @Get('municipios')
  @ApiOperation({
    summary: 'Listar municipios del Magdalena',
    description:
      'Devuelve los 30 municipios del departamento. Lectura abierta a todos los usuarios autenticados.',
  })
  @ApiResponse({ status: 200, type: [MunicipioResponseDto] })
  findAllMunicipios(): Promise<MunicipioResponseDto[]> {
    return this.service.findAllMunicipios();
  }

  @Get('municipios/:id')
  @ApiOperation({ summary: 'Ver detalle de un municipio' })
  @ApiParam({ name: 'id', format: 'uuid' })
  @ApiResponse({ status: 200, type: MunicipioResponseDto })
  @ApiResponse({ status: 404, description: 'Municipio no encontrado' })
  findMunicipioById(@Param('id', ParseUUIDPipe) id: string): Promise<MunicipioResponseDto> {
    return this.service.findMunicipioById(id);
  }

  @Post('municipios')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMINISTRADOR)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: '[ADMIN] Crear un nuevo municipio' })
  @ApiResponse({ status: 201, type: MunicipioResponseDto })
  @ApiResponse({ status: 409, description: 'Ya existe un municipio con ese codigo DANE o nombre' })
  createMunicipio(@Body() dto: CreateMunicipioDto): Promise<MunicipioResponseDto> {
    return this.service.createMunicipio(dto);
  }

  @Patch('municipios/:id')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMINISTRADOR)
  @ApiOperation({ summary: '[ADMIN] Actualizar un municipio' })
  @ApiParam({ name: 'id', format: 'uuid' })
  @ApiResponse({ status: 200, type: MunicipioResponseDto })
  updateMunicipio(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateMunicipioDto,
  ): Promise<MunicipioResponseDto> {
    return this.service.updateMunicipio(id, dto);
  }

  @Delete('municipios/:id')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMINISTRADOR)
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: '[ADMIN] Eliminar un municipio (soft-delete)' })
  @ApiParam({ name: 'id', format: 'uuid' })
  @ApiResponse({ status: 204, description: 'Municipio eliminado' })
  deleteMunicipio(@Param('id', ParseUUIDPipe) id: string): Promise<void> {
    return this.service.deleteMunicipio(id);
  }

  // ════════════════════════════════════════════════════════
  // CULTIVOS
  // ════════════════════════════════════════════════════════

  @Get('cultivos')
  @ApiOperation({
    summary: 'Listar cultivos disponibles',
    description: 'Cultivos del Magdalena: cereales, frutales, hortalizas, comerciales.',
  })
  @ApiResponse({ status: 200, type: [CultivoResponseDto] })
  findAllCultivos(): Promise<CultivoResponseDto[]> {
    return this.service.findAllCultivos();
  }

  @Get('cultivos/:id')
  @ApiOperation({ summary: 'Ver detalle de un cultivo' })
  @ApiParam({ name: 'id', format: 'uuid' })
  @ApiResponse({ status: 200, type: CultivoResponseDto })
  findCultivoById(@Param('id', ParseUUIDPipe) id: string): Promise<CultivoResponseDto> {
    return this.service.findCultivoById(id);
  }

  @Post('cultivos')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMINISTRADOR)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: '[ADMIN] Crear un nuevo cultivo' })
  @ApiResponse({ status: 201, type: CultivoResponseDto })
  @ApiResponse({ status: 409, description: 'Cultivo duplicado' })
  createCultivo(@Body() dto: CreateCultivoDto): Promise<CultivoResponseDto> {
    return this.service.createCultivo(dto);
  }

  @Patch('cultivos/:id')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMINISTRADOR)
  @ApiOperation({ summary: '[ADMIN] Actualizar un cultivo' })
  @ApiParam({ name: 'id', format: 'uuid' })
  @ApiResponse({ status: 200, type: CultivoResponseDto })
  updateCultivo(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateCultivoDto,
  ): Promise<CultivoResponseDto> {
    return this.service.updateCultivo(id, dto);
  }

  @Delete('cultivos/:id')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMINISTRADOR)
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: '[ADMIN] Eliminar un cultivo (soft-delete)' })
  @ApiParam({ name: 'id', format: 'uuid' })
  deleteCultivo(@Param('id', ParseUUIDPipe) id: string): Promise<void> {
    return this.service.deleteCultivo(id);
  }

  // ════════════════════════════════════════════════════════
  // PLAGAS
  // ════════════════════════════════════════════════════════

  @Get('plagas')
  @ApiOperation({
    summary: 'Listar plagas conocidas',
    description: 'Plagas, enfermedades, hongos y malezas del Magdalena.',
  })
  @ApiResponse({ status: 200, type: [PlagaResponseDto] })
  findAllPlagas(): Promise<PlagaResponseDto[]> {
    return this.service.findAllPlagas();
  }

  @Get('plagas/:id')
  @ApiOperation({ summary: 'Ver detalle de una plaga' })
  @ApiParam({ name: 'id', format: 'uuid' })
  @ApiResponse({ status: 200, type: PlagaResponseDto })
  findPlagaById(@Param('id', ParseUUIDPipe) id: string): Promise<PlagaResponseDto> {
    return this.service.findPlagaById(id);
  }

  @Post('plagas')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMINISTRADOR)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: '[ADMIN] Crear una nueva plaga' })
  @ApiResponse({ status: 201, type: PlagaResponseDto })
  @ApiResponse({ status: 409, description: 'Plaga duplicada' })
  createPlaga(@Body() dto: CreatePlagaDto): Promise<PlagaResponseDto> {
    return this.service.createPlaga(dto);
  }

  @Patch('plagas/:id')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMINISTRADOR)
  @ApiOperation({ summary: '[ADMIN] Actualizar una plaga' })
  @ApiParam({ name: 'id', format: 'uuid' })
  @ApiResponse({ status: 200, type: PlagaResponseDto })
  updatePlaga(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdatePlagaDto,
  ): Promise<PlagaResponseDto> {
    return this.service.updatePlaga(id, dto);
  }

  @Delete('plagas/:id')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMINISTRADOR)
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: '[ADMIN] Eliminar una plaga (soft-delete)' })
  @ApiParam({ name: 'id', format: 'uuid' })
  deletePlaga(@Param('id', ParseUUIDPipe) id: string): Promise<void> {
    return this.service.deletePlaga(id);
  }

  // ════════════════════════════════════════════════════════
  // FERTILIZANTES
  // ════════════════════════════════════════════════════════

  @Get('fertilizantes')
  @ApiOperation({
    summary: 'Listar fertilizantes disponibles',
    description: 'Fertilizantes nitrogenados, fosfatados, potasicos, compuestos y organicos.',
  })
  @ApiResponse({ status: 200, type: [FertilizanteResponseDto] })
  findAllFertilizantes(): Promise<FertilizanteResponseDto[]> {
    return this.service.findAllFertilizantes();
  }

  @Get('fertilizantes/:id')
  @ApiOperation({ summary: 'Ver detalle de un fertilizante' })
  @ApiParam({ name: 'id', format: 'uuid' })
  @ApiResponse({ status: 200, type: FertilizanteResponseDto })
  findFertilizanteById(@Param('id', ParseUUIDPipe) id: string): Promise<FertilizanteResponseDto> {
    return this.service.findFertilizanteById(id);
  }

  @Post('fertilizantes')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMINISTRADOR)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: '[ADMIN] Crear un nuevo fertilizante' })
  @ApiResponse({ status: 201, type: FertilizanteResponseDto })
  @ApiResponse({ status: 409, description: 'Fertilizante duplicado' })
  createFertilizante(@Body() dto: CreateFertilizanteDto): Promise<FertilizanteResponseDto> {
    return this.service.createFertilizante(dto);
  }

  @Patch('fertilizantes/:id')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMINISTRADOR)
  @ApiOperation({ summary: '[ADMIN] Actualizar un fertilizante' })
  @ApiParam({ name: 'id', format: 'uuid' })
  @ApiResponse({ status: 200, type: FertilizanteResponseDto })
  updateFertilizante(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateFertilizanteDto,
  ): Promise<FertilizanteResponseDto> {
    return this.service.updateFertilizante(id, dto);
  }

  @Delete('fertilizantes/:id')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMINISTRADOR)
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: '[ADMIN] Eliminar un fertilizante (soft-delete)' })
  @ApiParam({ name: 'id', format: 'uuid' })
  deleteFertilizante(@Param('id', ParseUUIDPipe) id: string): Promise<void> {
    return this.service.deleteFertilizante(id);
  }

  // ════════════════════════════════════════════════════════
  // TIPOS DE SUELO
  // ════════════════════════════════════════════════════════

  @Get('tipos-suelo')
  @ApiOperation({
    summary: 'Listar tipos de suelo',
    description: 'Clasificacion textural FAO/USDA: arenoso, franco, arcilloso, etc.',
  })
  @ApiResponse({ status: 200, type: [TipoSueloResponseDto] })
  findAllTiposSuelo(): Promise<TipoSueloResponseDto[]> {
    return this.service.findAllTiposSuelo();
  }

  @Get('tipos-suelo/:id')
  @ApiOperation({ summary: 'Ver detalle de un tipo de suelo' })
  @ApiParam({ name: 'id', format: 'uuid' })
  @ApiResponse({ status: 200, type: TipoSueloResponseDto })
  findTipoSueloById(@Param('id', ParseUUIDPipe) id: string): Promise<TipoSueloResponseDto> {
    return this.service.findTipoSueloById(id);
  }

  @Post('tipos-suelo')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMINISTRADOR)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: '[ADMIN] Crear un nuevo tipo de suelo' })
  @ApiResponse({ status: 201, type: TipoSueloResponseDto })
  @ApiResponse({ status: 409, description: 'Tipo de suelo duplicado' })
  createTipoSuelo(@Body() dto: CreateTipoSueloDto): Promise<TipoSueloResponseDto> {
    return this.service.createTipoSuelo(dto);
  }

  @Patch('tipos-suelo/:id')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMINISTRADOR)
  @ApiOperation({ summary: '[ADMIN] Actualizar un tipo de suelo' })
  @ApiParam({ name: 'id', format: 'uuid' })
  @ApiResponse({ status: 200, type: TipoSueloResponseDto })
  updateTipoSuelo(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateTipoSueloDto,
  ): Promise<TipoSueloResponseDto> {
    return this.service.updateTipoSuelo(id, dto);
  }

  @Delete('tipos-suelo/:id')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMINISTRADOR)
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: '[ADMIN] Eliminar un tipo de suelo (soft-delete)' })
  @ApiParam({ name: 'id', format: 'uuid' })
  deleteTipoSuelo(@Param('id', ParseUUIDPipe) id: string): Promise<void> {
    return this.service.deleteTipoSuelo(id);
  }
}
