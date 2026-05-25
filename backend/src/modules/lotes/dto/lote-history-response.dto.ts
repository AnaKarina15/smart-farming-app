import { ApiProperty } from '@nestjs/swagger';

export class LoteHistoryItemDto {
  @ApiProperty({ format: 'uuid' })
  id!: string;

  @ApiProperty({
    example: 'siembras',
    description: 'Tipo de recurso operacional que origino el evento.',
  })
  resourceType!: string;

  @ApiProperty({ format: 'uuid' })
  loteId!: string;

  @ApiProperty()
  loteNombre!: string;

  @ApiProperty()
  titulo!: string;

  @ApiProperty()
  fecha!: Date;

  @ApiProperty()
  createdAt!: Date;

  @ApiProperty()
  updatedAt!: Date;

  @ApiProperty({ type: Object })
  payload!: Record<string, unknown>;
}

export class LoteHistoryResponseDto {
  @ApiProperty({ example: 'lote', enum: ['lote', 'global'] })
  scope!: 'lote' | 'global';

  @ApiProperty({ format: 'uuid', required: false, nullable: true })
  loteId!: string | null;

  @ApiProperty()
  total!: number;

  @ApiProperty()
  generatedAt!: Date;

  @ApiProperty({ type: [LoteHistoryItemDto] })
  data!: LoteHistoryItemDto[];
}
