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

import { CreateSiembraDto } from './dto/create-siembra.dto';
import { ListSiembrasQueryDto } from './dto/list-siembras-query.dto';
import { SiembraResponseDto } from './dto/siembra-response.dto';
import { UpdateSiembraDto } from './dto/update-siembra.dto';
import { SiembrasService } from './siembras.service';

@ApiTags('Siembras')
@Controller('siembras')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth('JWT-auth')
export class SiembrasController {
  constructor(private readonly siembrasService: SiembrasService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Registrar una nueva siembra',
    description:
      'Crea un registro de siembra en un lote del usuario. Requiere cultivoId del catalogo o cultivoOtro (texto libre).',
  })
  @ApiResponse({ status: 201, type: SiembraResponseDto })
  create(
    @CurrentUser() user: JwtPayload,
    @Body() dto: CreateSiembraDto,
  ): Promise<SiembraResponseDto> {
    return this.siembrasService.create(dto, user.sub, user.role);
  }

  @Get()
  @ApiOperation({
    summary: 'Listar siembras',
    description:
      'El usuario ve sus siembras. El administrador ve todas. Soporta paginacion y filtro por loteId.',
  })
  @ApiResponse({ status: 200 })
  findAll(@CurrentUser() user: JwtPayload, @Query() query: ListSiembrasQueryDto) {
    return this.siembrasService.findAll(query, user.sub, user.role);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Obtener una siembra por ID' })
  @ApiResponse({ status: 200, type: SiembraResponseDto })
  findOne(
    @CurrentUser() user: JwtPayload,
    @Param('id', ParseUUIDPipe) id: string,
  ): Promise<SiembraResponseDto> {
    return this.siembrasService.findOne(id, user.sub, user.role);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Actualizar una siembra existente' })
  @ApiResponse({ status: 200, type: SiembraResponseDto })
  update(
    @CurrentUser() user: JwtPayload,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateSiembraDto,
  ): Promise<SiembraResponseDto> {
    return this.siembrasService.update(id, dto, user.sub, user.role);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Eliminar (soft) una siembra' })
  @ApiResponse({ status: 204 })
  remove(@CurrentUser() user: JwtPayload, @Param('id', ParseUUIDPipe) id: string): Promise<void> {
    return this.siembrasService.remove(id, user.sub, user.role);
  }
}
