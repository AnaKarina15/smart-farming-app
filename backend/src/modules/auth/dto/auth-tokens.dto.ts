import { ApiProperty } from '@nestjs/swagger';

import { UserResponseDto } from '@/modules/users/dto/user-response.dto';

export class AuthTokensDto {
  @ApiProperty({ description: 'JWT de acceso (usar en Authorization: Bearer ...)' })
  accessToken!: string;

  @ApiProperty({ description: 'JWT de refresh (usar para obtener nuevo accessToken)' })
  refreshToken!: string;

  @ApiProperty({ description: 'Tipo de token', example: 'Bearer' })
  tokenType!: string;

  @ApiProperty({ description: 'Datos del usuario autenticado', type: UserResponseDto })
  user!: UserResponseDto;
}
