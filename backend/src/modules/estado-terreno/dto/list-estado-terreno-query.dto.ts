import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsInt, IsOptional, IsUUID, Min } from 'class-validator';

export class ListEstadoTerrenoQueryDto {
  @ApiProperty({ required: false, description: 'Filtrar por lote' })
  @IsUUID()
  @IsOptional()
  loteId?: string;

  @ApiProperty({ required: false, description: 'Filtrar por siembra' })
  @IsUUID()
  @IsOptional()
  siembraId?: string;

  @ApiProperty({ required: false, minimum: 1, default: 1 })
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @IsOptional()
  page?: number;

  @ApiProperty({ required: false, minimum: 1, default: 20 })
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @IsOptional()
  limit?: number;
}
