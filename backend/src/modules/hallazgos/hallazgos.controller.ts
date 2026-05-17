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

import { CreateHallazgoDto } from './dto/create-hallazgo.dto';
import { HallazgoResponseDto } from './dto/hallazgo-response.dto';
import { ListHallazgosQueryDto } from './dto/list-hallazgos-query.dto';
import { UpdateHallazgoDto } from './dto/update-hallazgo.dto';
import { HallazgosService } from './hallazgos.service';

@ApiTags('Hallazgos')
@Controller('hallazgos')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth('JWT-auth')
export class HallazgosController {
  constructor(private readonly hallazgosService: HallazgosService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Registrar un hallazgo fitosanitario',
    description:
      'Crea un registro de hallazgo (plaga, enfermedad u otro). Requiere plagaId del catalogo o plagaOtro.',
  })
  @ApiResponse({ status: 201, type: HallazgoResponseDto })
  create(
    @CurrentUser() user: JwtPayload,
    @Body() dto: CreateHallazgoDto,
  ): Promise<HallazgoResponseDto> {
    return this.hallazgosService.create(dto, user.sub, user.role);
  }

  @Get()
  @ApiOperation({
    summary: 'Listar hallazgos',
    description:
      'El usuario ve los suyos. Admin ve todos. Soporta paginacion, filtro por loteId y por severidad.',
  })
  @ApiResponse({ status: 200 })
  findAll(@CurrentUser() user: JwtPayload, @Query() query: ListHallazgosQueryDto) {
    return this.hallazgosService.findAll(query, user.sub, user.role);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Obtener un hallazgo por ID' })
  @ApiResponse({ status: 200, type: HallazgoResponseDto })
  findOne(
    @CurrentUser() user: JwtPayload,
    @Param('id', ParseUUIDPipe) id: string,
  ): Promise<HallazgoResponseDto> {
    return this.hallazgosService.findOne(id, user.sub, user.role);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Actualizar un hallazgo existente' })
  @ApiResponse({ status: 200, type: HallazgoResponseDto })
  update(
    @CurrentUser() user: JwtPayload,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateHallazgoDto,
  ): Promise<HallazgoResponseDto> {
    return this.hallazgosService.update(id, dto, user.sub, user.role);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Eliminar (soft) un hallazgo' })
  @ApiResponse({ status: 204 })
  remove(@CurrentUser() user: JwtPayload, @Param('id', ParseUUIDPipe) id: string): Promise<void> {
    return this.hallazgosService.remove(id, user.sub, user.role);
  }
}
