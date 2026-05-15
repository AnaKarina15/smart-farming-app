import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsBoolean, IsEnum, IsOptional, IsString, Matches, MaxLength } from 'class-validator';

import { UserRole } from '../entities/user-role.enum';

/**
 * DTO para que el ADMIN actualice campos de un usuario.
 *
 * No incluye email ni password por seguridad.
 * Email se cambia por proceso separado, password con reset-password.
 */
export class AdminUpdateUserDto {
  @ApiPropertyOptional({ example: 'Juan Perez Actualizado', maxLength: 150 })
  @IsOptional()
  @IsString()
  @MaxLength(150)
  nombreCompleto?: string;

  @ApiPropertyOptional({ example: '+573001234567' })
  @IsOptional()
  @IsString()
  @Matches(/^\+?[0-9\s-]{7,20}$/)
  telefono?: string;

  @ApiPropertyOptional({ enum: UserRole })
  @IsOptional()
  @IsEnum(UserRole)
  role?: UserRole;

  @ApiPropertyOptional({ example: true, description: 'Activar/desactivar usuario' })
  @IsOptional()
  @IsBoolean()
  activo?: boolean;
}
