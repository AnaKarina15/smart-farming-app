import { ApiProperty } from '@nestjs/swagger';
import {
  IsEmail,
  IsEnum,
  IsNotEmpty,
  IsOptional,
  IsString,
  MaxLength,
  MinLength,
  Matches,
} from 'class-validator';

import { UserRole } from '../entities/user-role.enum';

export class CreateUserDto {
  @ApiProperty({
    description: 'Nombre completo del usuario',
    example: 'Juan Perez',
    maxLength: 150,
  })
  @IsString()
  @IsNotEmpty()
  @MaxLength(150)
  nombreCompleto!: string;

  @ApiProperty({
    description: 'Correo electronico (sera el identificador unico)',
    example: 'juan.perez@ejemplo.com',
  })
  @IsEmail({}, { message: 'El correo electronico no tiene formato valido' })
  @MaxLength(150)
  email!: string;

  @ApiProperty({
    description: 'Telefono celular (opcional)',
    example: '+573001234567',
    required: false,
  })
  @IsOptional()
  @IsString()
  @Matches(/^\+?[0-9\s-]{7,20}$/, {
    message: 'El telefono debe contener solo numeros, espacios o guiones',
  })
  telefono?: string;

  @ApiProperty({
    description: 'Contrasena (minimo 8 caracteres, debe incluir letras y numeros)',
    example: 'Pass1234',
    minLength: 8,
  })
  @IsString()
  @MinLength(8, { message: 'La contrasena debe tener al menos 8 caracteres' })
  @Matches(/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*#?&._-]{8,}$/, {
    message: 'La contrasena debe incluir al menos una letra y un numero',
  })
  password!: string;

  @ApiProperty({
    description: 'Rol del usuario en el sistema',
    enum: UserRole,
    default: UserRole.PEQUENO_PRODUCTOR,
    required: false,
  })
  @IsOptional()
  @IsEnum(UserRole)
  role?: UserRole;
}
