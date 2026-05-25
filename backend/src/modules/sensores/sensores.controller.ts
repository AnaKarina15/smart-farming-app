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

import { BatchLecturasSensorDto } from './dto/batch-lecturas-sensor.dto';
import { CreateLecturaSensorDto } from './dto/create-lectura-sensor.dto';
import { CreateSensorDto } from './dto/create-sensor.dto';
import { LecturaSensorResponseDto } from './dto/lectura-sensor-response.dto';
import { ListLecturasSensorQueryDto } from './dto/list-lecturas-sensor-query.dto';
import { ListSensoresQueryDto } from './dto/list-sensores-query.dto';
import { SensorResponseDto } from './dto/sensor-response.dto';
import { UpdateSensorDto } from './dto/update-sensor.dto';
import { SensoresService } from './sensores.service';

@ApiTags('Sensores')
@Controller('sensores')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth('JWT-auth')
export class SensoresController {
  constructor(private readonly sensoresService: SensoresService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Registrar un sensor IoT o manual asociado a un lote' })
  @ApiResponse({ status: 201, type: SensorResponseDto })
  create(
    @CurrentUser() user: JwtPayload,
    @Body() dto: CreateSensorDto,
  ): Promise<SensorResponseDto> {
    return this.sensoresService.create(dto, user.sub, user.role);
  }

  @Get()
  @ApiOperation({ summary: 'Listar sensores del usuario autenticado' })
  @ApiResponse({ status: 200 })
  findAll(@CurrentUser() user: JwtPayload, @Query() query: ListSensoresQueryDto) {
    return this.sensoresService.findAll(query, user.sub, user.role);
  }

  @Post('lecturas/batch')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Registrar varias lecturas offline en una sola llamada',
    description:
      'Endpoint batch idempotente mediante clientLocalId. Permite sincronizar lecturas tomadas offline por BLE/manual/simulado.',
  })
  @ApiResponse({ status: 201 })
  createLecturasBatch(@CurrentUser() user: JwtPayload, @Body() dto: BatchLecturasSensorDto) {
    return this.sensoresService.createLecturasBatch(dto, user.sub, user.role);
  }

  @Post(':id/lecturas')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Registrar una lectura para un sensor' })
  @ApiResponse({ status: 201, type: LecturaSensorResponseDto })
  createLectura(
    @CurrentUser() user: JwtPayload,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: CreateLecturaSensorDto,
  ): Promise<LecturaSensorResponseDto> {
    return this.sensoresService.createLectura(id, dto, user.sub, user.role);
  }

  @Get(':id/lecturas')
  @ApiOperation({ summary: 'Consultar historico paginado de lecturas de un sensor' })
  @ApiResponse({ status: 200 })
  findLecturas(
    @CurrentUser() user: JwtPayload,
    @Param('id', ParseUUIDPipe) id: string,
    @Query() query: ListLecturasSensorQueryDto,
  ) {
    return this.sensoresService.findLecturas(id, query, user.sub, user.role);
  }

  @Get(':id/ultima')
  @ApiOperation({ summary: 'Consultar la ultima lectura disponible de un sensor' })
  @ApiResponse({ status: 200, type: LecturaSensorResponseDto })
  findUltimaLectura(@CurrentUser() user: JwtPayload, @Param('id', ParseUUIDPipe) id: string) {
    return this.sensoresService.findUltimaLectura(id, user.sub, user.role);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Obtener un sensor por ID' })
  @ApiResponse({ status: 200, type: SensorResponseDto })
  findOne(
    @CurrentUser() user: JwtPayload,
    @Param('id', ParseUUIDPipe) id: string,
  ): Promise<SensorResponseDto> {
    return this.sensoresService.findOne(id, user.sub, user.role);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Actualizar metadatos de un sensor' })
  @ApiResponse({ status: 200, type: SensorResponseDto })
  update(
    @CurrentUser() user: JwtPayload,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateSensorDto,
  ): Promise<SensorResponseDto> {
    return this.sensoresService.update(id, dto, user.sub, user.role);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Eliminar logicamente un sensor' })
  @ApiResponse({ status: 204 })
  remove(@CurrentUser() user: JwtPayload, @Param('id', ParseUUIDPipe) id: string): Promise<void> {
    return this.sensoresService.remove(id, user.sub, user.role);
  }
}
