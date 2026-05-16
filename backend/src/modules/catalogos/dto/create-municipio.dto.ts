import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsLatitude,
  IsLongitude,
  IsOptional,
  IsString,
  Length,
  Matches,
  MaxLength,
} from 'class-validator';

export class CreateMunicipioDto {
  @ApiProperty({ example: '47001', description: 'Codigo DANE de 5 digitos' })
  @IsString()
  @Length(5, 5)
  @Matches(/^\d{5}$/, { message: 'codigoDane debe ser de 5 digitos numericos' })
  codigoDane!: string;

  @ApiProperty({ example: 'Santa Marta' })
  @IsString()
  @MaxLength(100)
  nombre!: string;

  @ApiPropertyOptional({ example: 'Norte' })
  @IsOptional()
  @IsString()
  @MaxLength(50)
  subregion?: string;

  @ApiPropertyOptional({ example: 11.2408 })
  @IsOptional()
  @IsLatitude()
  latitud?: number;

  @ApiPropertyOptional({ example: -74.199 })
  @IsOptional()
  @IsLongitude()
  longitud?: number;
}
