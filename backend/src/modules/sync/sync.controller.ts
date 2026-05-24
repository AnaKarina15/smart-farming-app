import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';

import { CurrentUser, JwtPayload } from '@/common/decorators/current-user.decorator';
import { JwtAuthGuard } from '@/common/guards/jwt-auth.guard';

import { SyncBatchDto } from './dto/sync-batch.dto';
import { SyncBatchResponseDto, SyncValidateTokenResponseDto } from './dto/sync-response.dto';
import { SyncSinceQueryDto } from './dto/sync-since-query.dto';
import { SyncService } from './sync.service';

@ApiTags('Sync')
@Controller('sync')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth('JWT-auth')
export class SyncController {
  constructor(private readonly syncService: SyncService) {}

  @Post('batch')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Sincronizar lote de operaciones offline',
    description:
      'Recibe operaciones creadas o modificadas offline en SQLite y las aplica de forma idempotente. Nunca toma userId del body; lo toma del JWT.',
  })
  @ApiResponse({ status: 201, type: SyncBatchResponseDto })
  batch(@CurrentUser() user: JwtPayload, @Body() dto: SyncBatchDto): Promise<SyncBatchResponseDto> {
    return this.syncService.processBatch(dto, user);
  }

  @Get('since')
  @ApiOperation({
    summary: 'Obtener cambios del servidor desde un timestamp',
    description:
      'Devuelve registros creados, actualizados y soft-deleted posteriores al timestamp para refrescar la cache SQLite local.',
  })
  @ApiResponse({ status: 200 })
  since(@CurrentUser() user: JwtPayload, @Query() query: SyncSinceQueryDto) {
    return this.syncService.getChangesSince(query.timestamp, user);
  }

  @Get('validate-token')
  @ApiOperation({
    summary: 'Validar sesion actual para clientes offline-first',
    description:
      'Confirma que el access token sigue vigente y devuelve datos minimos del usuario y expiracion del token.',
  })
  @ApiResponse({ status: 200, type: SyncValidateTokenResponseDto })
  validateToken(@CurrentUser() user: JwtPayload): SyncValidateTokenResponseDto {
    return this.syncService.validateToken(user);
  }
}
