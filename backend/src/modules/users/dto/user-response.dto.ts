import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

import { User } from '../entities/user.entity';
import { UserRole } from '../entities/user-role.enum';

/**
 * DTO de respuesta para User.
 *
 * Excluye campos sensibles (password, refreshTokenHash) por construccion explicita.
 */
export class UserResponseDto {
  @ApiProperty({ format: 'uuid' })
  id!: string;

  @ApiProperty()
  nombreCompleto!: string;

  @ApiProperty({ format: 'email' })
  email!: string;

  @ApiPropertyOptional({ nullable: true })
  telefono!: string | null;

  @ApiPropertyOptional({ nullable: true })
  fotoPerfilUrl!: string | null;

  @ApiProperty({ enum: UserRole })
  role!: UserRole;

  @ApiProperty()
  activo!: boolean;

  @ApiProperty()
  mustChangePassword!: boolean;

  @ApiPropertyOptional({ nullable: true })
  ultimoAcceso!: Date | null;

  @ApiPropertyOptional({ nullable: true, description: 'Quien creo este usuario' })
  createdBy!: string | null;

  @ApiPropertyOptional({ nullable: true, description: 'Si esta soft-deleted' })
  deletedAt!: Date | null;

  @ApiProperty()
  createdAt!: Date;

  @ApiProperty()
  updatedAt!: Date;

  static fromEntity(user: User): UserResponseDto {
    const dto = new UserResponseDto();
    dto.id = user.id;
    dto.nombreCompleto = user.nombreCompleto;
    dto.email = user.email;
    dto.telefono = user.telefono;
    dto.fotoPerfilUrl = user.fotoPerfilUrl;
    dto.role = user.role;
    dto.activo = user.activo;
    dto.mustChangePassword = user.mustChangePassword;
    dto.ultimoAcceso = user.ultimoAcceso;
    dto.createdBy = user.createdBy;
    dto.deletedAt = user.deletedAt;
    dto.createdAt = user.createdAt;
    dto.updatedAt = user.updatedAt;
    return dto;
  }
}
