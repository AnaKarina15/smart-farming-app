import { ApiProperty } from '@nestjs/swagger';
import { IsString, Matches, MinLength } from 'class-validator';

/**
 * DTO para que el ADMIN resetee la password de un usuario.
 *
 * Cuando se resetea, el campo mustChangePassword del usuario se pone en TRUE,
 * forzando que cambie su password en el siguiente login.
 */
export class ResetPasswordDto {
  @ApiProperty({
    example: 'TempPass2026',
    description: 'Password temporal que el admin asigna. El usuario debera cambiarla.',
    minLength: 8,
  })
  @IsString()
  @MinLength(8)
  @Matches(/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*#?&._-]{8,}$/, {
    message: 'La contrasena debe incluir al menos una letra y un numero',
  })
  newPassword!: string;
}
