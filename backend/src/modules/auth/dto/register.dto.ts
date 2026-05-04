import { ApiProperty } from '@nestjs/swagger';
import {
  IsEmail,
  IsNotEmpty,
  IsOptional,
  IsString,
  Matches,
  MaxLength,
  MinLength,
} from 'class-validator';

export class RegisterDto {
  @ApiProperty({ example: 'Juan Perez', maxLength: 150 })
  @IsString()
  @IsNotEmpty()
  @MaxLength(150)
  nombreCompleto!: string;

  @ApiProperty({ example: 'juan.perez@ejemplo.com' })
  @IsEmail({}, { message: 'El correo electronico no tiene formato valido' })
  @MaxLength(150)
  email!: string;

  @ApiProperty({ example: '+573001234567', required: false })
  @IsOptional()
  @IsString()
  @Matches(/^\+?[0-9\s-]{7,20}$/)
  telefono?: string;

  @ApiProperty({ example: 'Pass1234', minLength: 8 })
  @IsString()
  @MinLength(8)
  @Matches(/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*#?&._-]{8,}$/, {
    message: 'La contrasena debe incluir al menos una letra y un numero',
  })
  password!: string;
}
