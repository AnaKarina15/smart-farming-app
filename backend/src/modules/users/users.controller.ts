import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  UploadedFile,
  UseInterceptors,
  Query,
  UseGuards,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { extname } from 'path';
import {
  ApiBearerAuth,
  ApiBody,
  ApiOperation,
  ApiParam,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';

import { CurrentUser, JwtPayload } from '@/common/decorators/current-user.decorator';
import { Roles } from '@/common/decorators/roles.decorator';
import { JwtAuthGuard } from '@/common/guards/jwt-auth.guard';
import { RolesGuard } from '@/common/guards/roles.guard';

import { ChangePasswordDto } from './dto/change-password.dto';
import { CreateUserDto } from './dto/create-user.dto';
import { BadRequestException } from '@nestjs/common';
import { ListUsersQueryDto } from './dto/list-users-query.dto';
import { ResetPasswordDto } from './dto/reset-password.dto';
import { AdminUpdateUserDto } from './dto/update-user.dto';
import { UserResponseDto } from './dto/user-response.dto';
import { UserRole } from './entities/user-role.enum';
import { UsersService } from './users.service';

@ApiTags('Users')
@Controller('users')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth('JWT-auth')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  // ════════════════════════════════════════════════════════
  // ENDPOINTS PARA TODOS LOS USUARIOS AUTENTICADOS
  // ════════════════════════════════════════════════════════

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

  @Post('me/avatar')
  @ApiOperation({
    summary: 'Subir foto de perfil',
    description:
      'Permite al usuario subir una foto de perfil. Retorna la URL del archivo guardado.',
  })
  @UseInterceptors(
    FileInterceptor('file', {
      storage: diskStorage({
        destination: './public/uploads/avatars',
        filename: (req, file, callback) => {
          const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
          const ext = extname(file.originalname);
          const filename = `${uniqueSuffix}${ext}`;
          callback(null, filename);
        },
      }),
    }),
  )
  @ApiBody({
    description: 'Archivo de imagen a subir',
    required: true,
  })
  @ApiResponse({ status: 201, description: 'Foto de perfil actualizada', type: UserResponseDto })
  async uploadAvatar(
    @CurrentUser() jwtUser: JwtPayload,
    @UploadedFile() file: Express.Multer.File,
  ): Promise<UserResponseDto> {
    if (!file) {
      throw new BadRequestException('Archivo no subido');
    }
    return this.usersService.updateAvatar(jwtUser.sub, file);
  }

  @Patch('me/change-password')
  @ApiOperation({
    summary: 'Cambiar contraseña del usuario autenticado',
    description:
      'Permite cambiar la contraseña desde perfil. Si mustChangePassword=true, permite completar el cambio forzado despues de iniciar sesion con contraseña temporal.',
  })
  @ApiBody({ type: ChangePasswordDto })
  @ApiResponse({ status: 200, type: UserResponseDto })
  @ApiResponse({ status: 400, description: 'Datos invalidos' })
  @ApiResponse({ status: 401, description: 'Contraseña actual incorrecta' })
  async changePassword(
    @CurrentUser() jwtUser: JwtPayload,
    @Body() dto: ChangePasswordDto,
  ): Promise<UserResponseDto> {
    return this.usersService.changeOwnPassword(jwtUser.sub, dto);
  }

  // ════════════════════════════════════════════════════════
  // ENDPOINTS SOLO PARA ADMINISTRADOR
  // ════════════════════════════════════════════════════════

  @Get()
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMINISTRADOR)
  @ApiOperation({
    summary: '[ADMIN] Listar todos los usuarios con filtros',
    description: 'Solo accesible por administradores. Soporta paginacion y filtros.',
  })
  @ApiResponse({ status: 200, description: 'Lista paginada de usuarios' })
  @ApiResponse({ status: 403, description: 'Se requiere rol ADMINISTRADOR' })
  async findAll(@Query() query: ListUsersQueryDto) {
    return this.usersService.findAll(query);
  }

  @Get('stats')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMINISTRADOR)
  @ApiOperation({
    summary: '[ADMIN] Estadisticas globales de usuarios',
    description: 'Total, distribucion por rol, activos vs inactivos.',
  })
  @ApiResponse({ status: 200, description: 'Estadisticas del sistema' })
  async getStats() {
    return this.usersService.getStats();
  }

  @Get(':id')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMINISTRADOR)
  @ApiOperation({ summary: '[ADMIN] Ver detalle de un usuario por ID' })
  @ApiParam({ name: 'id', format: 'uuid' })
  @ApiResponse({ status: 200, type: UserResponseDto })
  @ApiResponse({ status: 404, description: 'Usuario no encontrado' })
  async findOne(@Param('id', ParseUUIDPipe) id: string): Promise<UserResponseDto> {
    const user = await this.usersService.findById(id);
    return this.usersService.toResponseDto(user);
  }

  @Post()
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMINISTRADOR)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: '[ADMIN] Crear un usuario con rol especifico',
    description:
      'Permite al admin crear usuarios manualmente. Util para registrar Gestores, ' +
      'Trabajadores u otros Admins. El productor estandar se auto-registra via /auth/register.',
  })
  @ApiBody({ type: CreateUserDto })
  @ApiResponse({ status: 201, type: UserResponseDto })
  @ApiResponse({ status: 409, description: 'Email ya registrado' })
  async create(
    @Body() dto: CreateUserDto,
    @CurrentUser() admin: JwtPayload,
  ): Promise<UserResponseDto> {
    const user = await this.usersService.create(dto, admin.sub);
    return this.usersService.toResponseDto(user);
  }

  @Patch(':id')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMINISTRADOR)
  @ApiOperation({ summary: '[ADMIN] Actualizar datos de un usuario' })
  @ApiParam({ name: 'id', format: 'uuid' })
  @ApiBody({ type: AdminUpdateUserDto })
  @ApiResponse({ status: 200, type: UserResponseDto })
  async update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: AdminUpdateUserDto,
    @CurrentUser() admin: JwtPayload,
  ): Promise<UserResponseDto> {
    return this.usersService.adminUpdate(id, dto, admin.sub);
  }

  @Post(':id/reset-password')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMINISTRADOR)
  @ApiOperation({
    summary: '[ADMIN] Recuperar cuenta - Resetear password de un usuario',
    description:
      'Asigna una password temporal a un usuario que perdio acceso. ' +
      'El usuario debera cambiarla en su proximo login (mustChangePassword = true). ' +
      'Util para recuperacion de cuenta de productores con baja alfabetizacion digital. ' +
      'Invalida tambien todas las sesiones activas (refreshToken).',
  })
  @ApiParam({ name: 'id', format: 'uuid' })
  @ApiBody({ type: ResetPasswordDto })
  @ApiResponse({ status: 200, description: 'Password reseteada' })
  async resetPassword(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: ResetPasswordDto,
    @CurrentUser() admin: JwtPayload,
  ) {
    return this.usersService.adminResetPassword(id, dto, admin.sub);
  }

  @Delete(':id')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMINISTRADOR)
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({
    summary: '[ADMIN] Eliminar usuario (soft-delete)',
    description:
      'Marca el usuario como eliminado. NO se borra fisicamente para mantener ' +
      'integridad de historial. Puede restaurarse con POST /users/:id/restore.',
  })
  @ApiParam({ name: 'id', format: 'uuid' })
  @ApiResponse({ status: 204, description: 'Usuario eliminado' })
  async remove(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() admin: JwtPayload,
  ): Promise<void> {
    await this.usersService.adminSoftDelete(id, admin.sub);
  }

  @Post(':id/restore')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMINISTRADOR)
  @ApiOperation({
    summary: '[ADMIN] Restaurar usuario eliminado',
    description: 'Reactiva un usuario que fue soft-deleted.',
  })
  @ApiParam({ name: 'id', format: 'uuid' })
  @ApiResponse({ status: 200, type: UserResponseDto })
  async restore(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() admin: JwtPayload,
  ): Promise<UserResponseDto> {
    return this.usersService.adminRestore(id, admin.sub);
  }
}
