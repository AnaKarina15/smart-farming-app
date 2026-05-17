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

import { CreateFertilizacionDto } from './dto/create-fertilizacion.dto';
import { FertilizacionResponseDto } from './dto/fertilizacion-response.dto';
import { ListFertilizacionQueryDto } from './dto/list-fertilizacion-query.dto';
import { UpdateFertilizacionDto } from './dto/update-fertilizacion.dto';
import { FertilizacionService } from './fertilizacion.service';

@ApiTags('Fertilizacion')
@Controller('fertilizacion')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth('JWT-auth')
export class FertilizacionController {
  constructor(private readonly fertilizacionService: FertilizacionService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Registrar una aplicacion de fertilizante',
    description:
      'Crea un registro de fertilizacion. Requiere fertilizanteId del catalogo o fertilizanteOtro.',
  })
  @ApiResponse({ status: 201, type: FertilizacionResponseDto })
  create(
    @CurrentUser() user: JwtPayload,
    @Body() dto: CreateFertilizacionDto,
  ): Promise<FertilizacionResponseDto> {
    return this.fertilizacionService.create(dto, user.sub, user.role);
  }

  @Get()
  @ApiOperation({
    summary: 'Listar fertilizaciones',
    description: 'El usuario ve las suyas. Admin ve todas. Soporta paginacion y filtro por loteId.',
  })
  @ApiResponse({ status: 200 })
  findAll(@CurrentUser() user: JwtPayload, @Query() query: ListFertilizacionQueryDto) {
    return this.fertilizacionService.findAll(query, user.sub, user.role);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Obtener una fertilizacion por ID' })
  @ApiResponse({ status: 200, type: FertilizacionResponseDto })
  findOne(
    @CurrentUser() user: JwtPayload,
    @Param('id', ParseUUIDPipe) id: string,
  ): Promise<FertilizacionResponseDto> {
    return this.fertilizacionService.findOne(id, user.sub, user.role);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Actualizar una fertilizacion existente' })
  @ApiResponse({ status: 200, type: FertilizacionResponseDto })
  update(
    @CurrentUser() user: JwtPayload,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateFertilizacionDto,
  ): Promise<FertilizacionResponseDto> {
    return this.fertilizacionService.update(id, dto, user.sub, user.role);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Eliminar (soft) una fertilizacion' })
  @ApiResponse({ status: 204 })
  remove(@CurrentUser() user: JwtPayload, @Param('id', ParseUUIDPipe) id: string): Promise<void> {
    return this.fertilizacionService.remove(id, user.sub, user.role);
  }
}
