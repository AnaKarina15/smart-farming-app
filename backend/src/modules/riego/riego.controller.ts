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

import { CreateRiegoDto } from './dto/create-riego.dto';
import { ListRiegoQueryDto } from './dto/list-riego-query.dto';
import { RiegoResponseDto } from './dto/riego-response.dto';
import { UpdateRiegoDto } from './dto/update-riego.dto';
import { RiegoService } from './riego.service';

@ApiTags('Riego')
@Controller('riego')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth('JWT-auth')
export class RiegoController {
  constructor(private readonly riegoService: RiegoService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Registrar un evento de riego',
    description: 'Crea un registro de riego en un lote del usuario.',
  })
  @ApiResponse({ status: 201, type: RiegoResponseDto })
  create(@CurrentUser() user: JwtPayload, @Body() dto: CreateRiegoDto): Promise<RiegoResponseDto> {
    return this.riegoService.create(dto, user.sub, user.role);
  }

  @Get()
  @ApiOperation({
    summary: 'Listar riegos',
    description:
      'El usuario ve sus riegos. Admin ve todos. Soporta paginacion y filtro por loteId.',
  })
  @ApiResponse({ status: 200 })
  findAll(@CurrentUser() user: JwtPayload, @Query() query: ListRiegoQueryDto) {
    return this.riegoService.findAll(query, user.sub, user.role);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Obtener un riego por ID' })
  @ApiResponse({ status: 200, type: RiegoResponseDto })
  findOne(
    @CurrentUser() user: JwtPayload,
    @Param('id', ParseUUIDPipe) id: string,
  ): Promise<RiegoResponseDto> {
    return this.riegoService.findOne(id, user.sub, user.role);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Actualizar un riego existente' })
  @ApiResponse({ status: 200, type: RiegoResponseDto })
  update(
    @CurrentUser() user: JwtPayload,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateRiegoDto,
  ): Promise<RiegoResponseDto> {
    return this.riegoService.update(id, dto, user.sub, user.role);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Eliminar (soft) un riego' })
  @ApiResponse({ status: 204 })
  remove(@CurrentUser() user: JwtPayload, @Param('id', ParseUUIDPipe) id: string): Promise<void> {
    return this.riegoService.remove(id, user.sub, user.role);
  }
}
