import { ApiProperty } from '@nestjs/swagger';

import { User } from '../entities/user.entity';
import { UserRole } from '../entities/user-role.enum';

/**
 * DTO de respuesta para User.
 *
 * Excluye campos sensibles (password, refreshTokenHash) por construccion explicita,
 * en lugar de depender de class-transformer (mas seguro).
 */
export class UserResponseDto {
  @ApiProperty({ format: 'uuid' })
  id!: string;

  @ApiProperty()
  nombreCompleto!: string;

  @ApiProperty({ format: 'email' })
  email!: string;

  @ApiProperty({ required: false, nullable: true })
  telefono!: string | null;

  @ApiProperty({ enum: UserRole })
  role!: UserRole;

  @ApiProperty()
  activo!: boolean;

  @ApiProperty({ required: false, nullable: true })
  ultimoAcceso!: Date | null;

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
    dto.role = user.role;
    dto.activo = user.activo;
    dto.ultimoAcceso = user.ultimoAcceso;
    dto.createdAt = user.createdAt;
    dto.updatedAt = user.updatedAt;
    return dto;
  }
}
