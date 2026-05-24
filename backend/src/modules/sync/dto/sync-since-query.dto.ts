import { ApiProperty } from '@nestjs/swagger';
import { IsDateString, IsNotEmpty } from 'class-validator';

export class SyncSinceQueryDto {
  @ApiProperty({
    example: '2026-05-17T00:00:00Z',
    description: 'Timestamp ISO8601 desde el cual traer cambios del servidor.',
  })
  @IsDateString()
  @IsNotEmpty()
  timestamp!: string;
}
