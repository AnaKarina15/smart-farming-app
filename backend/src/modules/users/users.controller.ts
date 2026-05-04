import { Controller, Get, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';

import { CurrentUser, JwtPayload } from '@/common/decorators/current-user.decorator';
import { JwtAuthGuard } from '@/common/guards/jwt-auth.guard';

import { UserResponseDto } from './dto/user-response.dto';
import { UsersService } from './users.service';

@ApiTags('Users')
@Controller('users')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth('JWT-auth')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get('me')
  @ApiOperation({
    summary: 'Obtener perfil del usuario autenticado',
    description: 'Retorna los datos del usuario asociado al JWT enviado en el header.',
  })
  @ApiResponse({ status: 200, description: 'Perfil del usuario', type: UserResponseDto })
  @ApiResponse({ status: 401, description: 'No autenticado' })
  async getMe(@CurrentUser() jwtUser: JwtPayload): Promise<UserResponseDto> {
    const user = await this.usersService.findById(jwtUser.sub);
    return this.usersService.toResponseDto(user);
  }
}
