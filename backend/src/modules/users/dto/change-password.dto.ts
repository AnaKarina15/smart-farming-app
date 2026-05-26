import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString, Matches, MinLength } from 'class-validator';

export class ChangePasswordDto {
  @ApiPropertyOptional({
    example: 'Pass1234',
    description:
      'Password actual. Requerida para cambios desde perfil; opcional cuando el usuario esta en cambio forzado.',
  })
  @IsOptional()
  @IsString()
  currentPassword?: string;

  @ApiProperty({ example: 'NuevaPass2026', minLength: 8 })
  @IsString()
  @MinLength(8)
  @Matches(/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*#?&._-]{8,}$/, {
    message: 'La contrasena debe incluir al menos una letra y un numero',
  })
  newPassword!: string;

  @ApiProperty({ example: 'NuevaPass2026', minLength: 8 })
  @IsString()
  confirmPassword!: string;
}
