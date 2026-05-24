import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export type SyncItemStatus = 'created' | 'updated' | 'deleted' | 'duplicate' | 'error';

export class SyncBatchItemResultDto {
  @ApiProperty({ example: 'siembras:local-42' })
  localId!: string;

  @ApiProperty({ example: 'siembras' })
  resourceType!: string;

  @ApiPropertyOptional({ format: 'uuid' })
  serverId?: string;

  @ApiProperty({ enum: ['created', 'updated', 'deleted', 'duplicate', 'error'] })
  status!: SyncItemStatus;

  @ApiPropertyOptional({ example: 'Lote no encontrado' })
  error?: string;
}

export class SyncBatchResponseDto {
  @ApiProperty({ example: '2026-05-17T14:05:00.000Z' })
  serverTime!: string;

  @ApiProperty({ type: [SyncBatchItemResultDto] })
  results!: SyncBatchItemResultDto[];

  @ApiProperty({
    example: { total: 2, created: 1, updated: 0, deleted: 0, duplicate: 1, error: 0 },
  })
  summary!: Record<string, number>;
}

export class SyncValidateTokenResponseDto {
  @ApiProperty({ example: '2026-05-17T14:05:00.000Z' })
  serverTime!: string;

  @ApiProperty({
    example: {
      id: 'uuid-del-usuario',
      email: 'productor@agrofield.com',
      role: 'pequeno_productor',
    },
  })
  user!: {
    id: string;
    email: string;
    role: string;
  };

  @ApiProperty({
    example: {
      valid: true,
      expiresAt: '2026-05-17T14:20:00.000Z',
      expiresInSeconds: 900,
    },
  })
  token!: {
    valid: boolean;
    expiresAt: string | null;
    expiresInSeconds: number | null;
  };
}
