import { ApiProperty } from '@nestjs/swagger';
import { IsEmail } from 'class-validator';

export class ForgotPasswordDto {
  @ApiProperty({ example: 'juan.perez@ejemplo.com' })
  @IsEmail({}, { message: 'El correo electronico no tiene formato valido' })
  email!: string;
}
