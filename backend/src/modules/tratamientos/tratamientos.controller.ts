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

import { CreateTratamientoDto } from './dto/create-tratamiento.dto';
import { ListTratamientosQueryDto } from './dto/list-tratamientos-query.dto';
import { TratamientoResponseDto } from './dto/tratamiento-response.dto';
import { UpdateTratamientoDto } from './dto/update-tratamiento.dto';
import { TratamientosService } from './tratamientos.service';

@ApiTags('Tratamientos')
@Controller('tratamientos')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth('JWT-auth')
export class TratamientosController {
  constructor(private readonly tratamientosService: TratamientosService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Registrar un tratamiento fitosanitario',
    description:
      'Crea un registro de aplicacion de producto. Puede asociarse opcionalmente a un hallazgo.',
  })
  @ApiResponse({ status: 201, type: TratamientoResponseDto })
  create(
    @CurrentUser() user: JwtPayload,
    @Body() dto: CreateTratamientoDto,
  ): Promise<TratamientoResponseDto> {
    return this.tratamientosService.create(dto, user.sub, user.role);
  }

  @Get()
  @ApiOperation({
    summary: 'Listar tratamientos',
    description:
      'El usuario ve los suyos. Admin ve todos. Soporta filtros por loteId y hallazgoId.',
  })
  @ApiResponse({ status: 200 })
  findAll(@CurrentUser() user: JwtPayload, @Query() query: ListTratamientosQueryDto) {
    return this.tratamientosService.findAll(query, user.sub, user.role);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Obtener un tratamiento por ID' })
  @ApiResponse({ status: 200, type: TratamientoResponseDto })
  findOne(
    @CurrentUser() user: JwtPayload,
    @Param('id', ParseUUIDPipe) id: string,
  ): Promise<TratamientoResponseDto> {
    return this.tratamientosService.findOne(id, user.sub, user.role);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Actualizar un tratamiento existente' })
  @ApiResponse({ status: 200, type: TratamientoResponseDto })
  update(
    @CurrentUser() user: JwtPayload,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateTratamientoDto,
  ): Promise<TratamientoResponseDto> {
    return this.tratamientosService.update(id, dto, user.sub, user.role);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Eliminar (soft) un tratamiento' })
  @ApiResponse({ status: 204 })
  remove(@CurrentUser() user: JwtPayload, @Param('id', ParseUUIDPipe) id: string): Promise<void> {
    return this.tratamientosService.remove(id, user.sub, user.role);
  }
}
