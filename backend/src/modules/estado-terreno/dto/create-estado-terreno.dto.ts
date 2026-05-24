import { ApiProperty } from '@nestjs/swagger';
import { IsDateString, IsNotEmpty, IsOptional, IsString, IsUUID, MaxLength } from 'class-validator';

export class CreateEstadoTerrenoDto {
  @ApiProperty({ format: 'uuid', description: 'ID del lote al que pertenece la caracterización' })
  @IsUUID()
  @IsNotEmpty()
  loteId!: string;

  @ApiProperty({ format: 'uuid', required: false, nullable: true, description: 'ID de la siembra asociada si existe' })
  @IsUUID()
  @IsOptional()
  siembraId?: string | null;

  @ApiProperty({
    example: 'estable',
    description: 'Estado físico o de preparación del terreno (limpio, arado, maleza, estable, erosionado, etc.)',
    maxLength: 50,
  })
  @IsString()
  @IsNotEmpty()
  @MaxLength(50)
  estado!: string;

  @ApiProperty({ format: 'uuid', required: false, nullable: true, description: 'ID del tipo de suelo (catálogo)' })
  @IsUUID()
  @IsOptional()
  tipoSueloId?: string | null;

  @ApiProperty({
    example: 'Terreno listo con buena humedad.',
    required: false,
    nullable: true,
    description: 'Notas u observaciones del estado del terreno',
    maxLength: 1000,
  })
  @IsString()
  @IsOptional()
  @MaxLength(1000)
  notas?: string | null;

  @ApiProperty({
    example: '2026-05-17T14:00:00Z',
    required: false,
    description: 'Fecha de creación del registro (para sincronización offline)',
  })
  @IsOptional()
  @IsDateString()
  createdAt?: string;
}
