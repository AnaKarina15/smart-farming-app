import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  ArrayMinSize,
  IsArray,
  IsDateString,
  IsIn,
  IsNotEmpty,
  IsObject,
  IsOptional,
  IsString,
  IsUUID,
  MaxLength,
  ValidateNested,
} from 'class-validator';

export const SYNC_RESOURCE_TYPES = [
  'siembras',
  'riego',
  'fertilizacion',
  'hallazgos',
  'tratamientos',
  'observaciones',
  'estado-terreno',
  'estado_terreno',
] as const;

export const SYNC_OPERATIONS = ['create', 'update', 'delete'] as const;
export const SYNC_METHODS = ['POST', 'PATCH', 'PUT', 'DELETE'] as const;

export type SyncResourceType = (typeof SYNC_RESOURCE_TYPES)[number];
export type SyncOperationType = (typeof SYNC_OPERATIONS)[number];

export class SyncBatchItemDto {
  @ApiProperty({
    example: 'siembras:local-42',
    description:
      'ID local estable del registro en SQLite. Debe repetirse igual en reintentos para idempotencia.',
    maxLength: 120,
  })
  @IsString()
  @IsNotEmpty()
  @MaxLength(120)
  localId!: string;

  @ApiPropertyOptional({
    enum: SYNC_RESOURCE_TYPES,
    example: 'siembras',
    description: 'Tipo de recurso. Si se omite, se intenta inferir desde endpoint.',
  })
  @IsOptional()
  @IsString()
  @IsIn([...SYNC_RESOURCE_TYPES])
  resourceType?: SyncResourceType;

  @ApiPropertyOptional({
    enum: SYNC_OPERATIONS,
    example: 'create',
    description: 'Operacion logica. Si se omite, se infiere desde method.',
  })
  @IsOptional()
  @IsString()
  @IsIn([...SYNC_OPERATIONS])
  operation?: SyncOperationType;

  @ApiPropertyOptional({
    enum: SYNC_METHODS,
    example: 'POST',
    description: 'Metodo original guardado en sync_queue del frontend.',
  })
  @IsOptional()
  @IsString()
  @IsIn([...SYNC_METHODS])
  method?: string;

  @ApiPropertyOptional({
    example: '/api/v1/siembras',
    description:
      'Endpoint original guardado en sync_queue; usado para inferir resourceType/serverId.',
    maxLength: 250,
  })
  @IsOptional()
  @IsString()
  @MaxLength(250)
  endpoint?: string;

  @ApiPropertyOptional({
    format: 'uuid',
    description: 'UUID del servidor para operaciones update/delete. Puede inferirse del endpoint.',
  })
  @IsOptional()
  @IsUUID()
  serverId?: string;

  @ApiPropertyOptional({
    example: '2026-05-17T14:00:00Z',
    description: 'Timestamp de ultima modificacion del registro en el dispositivo para LWW.',
  })
  @IsOptional()
  @IsDateString()
  clientUpdatedAt?: string;

  @ApiProperty({
    type: Object,
    description:
      'Payload de negocio equivalente al body que antes se enviaba al endpoint REST individual.',
    example: { loteId: 'uuid-del-lote', fecha: '2026-05-17T10:00:00Z' },
  })
  @IsObject()
  payload!: Record<string, unknown>;
}

export class SyncBatchDto {
  @ApiPropertyOptional({
    example: 'android-uuid-o-installation-id',
    description: 'Identificador opcional del dispositivo para trazabilidad.',
    maxLength: 120,
  })
  @IsOptional()
  @IsString()
  @MaxLength(120)
  deviceId?: string;

  @ApiPropertyOptional({
    example: '2026-05-17T00:00:00Z',
    description: 'Ultimo pull exitoso conocido por el cliente. Solo informativo en batch.',
  })
  @IsOptional()
  @IsDateString()
  lastPulledAt?: string;

  @ApiProperty({ type: [SyncBatchItemDto], minItems: 1, maxItems: 100 })
  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(100)
  @ValidateNested({ each: true })
  @Type(() => SyncBatchItemDto)
  items!: SyncBatchItemDto[];
}
