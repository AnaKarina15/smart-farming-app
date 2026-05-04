import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsNotEmpty, IsString } from 'class-validator';

export class LoginDto {
  @ApiProperty({ example: 'juan.perez@ejemplo.com' })
  @IsEmail({}, { message: 'El correo electronico no tiene formato valido' })
  email!: string;

  @ApiProperty({ example: 'Pass1234' })
  @IsString()
  @IsNotEmpty()
  password!: string;
}
