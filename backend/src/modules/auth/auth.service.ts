import { Injectable, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import * as argon2 from 'argon2';

import { JwtPayload } from '@/common/decorators/current-user.decorator';
import { UserResponseDto } from '@/modules/users/dto/user-response.dto';
import { User } from '@/modules/users/entities/user.entity';
import { UsersService } from '@/modules/users/users.service';

import { AuthTokensDto } from './dto/auth-tokens.dto';
import { ForgotPasswordDto } from './dto/forgot-password.dto';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';

@Injectable()
export class AuthService {
  constructor(
    private readonly usersService: UsersService,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {}

  /**
   * Registra un nuevo usuario y devuelve los tokens de acceso.
   *
   * Flujo correspondiente al mockup "Crear Cuenta - AgroField" del Front.
   */
  async register(dto: RegisterDto): Promise<AuthTokensDto> {
    const user = await this.usersService.create({
      nombreCompleto: dto.nombreCompleto,
      email: dto.email,
      telefono: dto.telefono,
      password: dto.password,
    });

    return this.generateAuthResponse(user);
  }

  /**
   * Autentica al usuario por email/password y devuelve los tokens.
   *
   * Flujo correspondiente al mockup "Inicio de Sesion - AgroField".
   */
  async login(dto: LoginDto): Promise<AuthTokensDto> {
    const user = await this.usersService.findByEmailWithPassword(dto.email);

    if (!user || !user.activo) {
      throw new UnauthorizedException('Credenciales invalidas');
    }

    const passwordValid = await argon2.verify(user.password, dto.password);
    if (!passwordValid) {
      throw new UnauthorizedException('Credenciales invalidas');
    }

    await this.usersService.registrarAcceso(user.id);

    return this.generateAuthResponse(user);
  }

  async forgotPassword(
    dto: ForgotPasswordDto,
  ): Promise<{ message: string; temporaryPassword: string }> {
    return this.usersService.requestPasswordRecovery(dto.email);
  }

  /**
   * Genera un nuevo par de tokens a partir de un refresh token valido.
   *
   * El refresh token debe coincidir con el hash almacenado en BD,
   * implementando rotacion de tokens (cada refresh invalida el anterior).
   */
  async refresh(refreshToken: string): Promise<AuthTokensDto> {
    let payload: JwtPayload;
    try {
      payload = await this.jwtService.verifyAsync<JwtPayload>(refreshToken, {
        secret: this.configService.get<string>('jwt.refreshSecret'),
      });
    } catch {
      throw new UnauthorizedException('Refresh token invalido o expirado');
    }

    const user = await this.usersService.findByIdWithRefreshToken(payload.sub);
    if (!user || !user.activo || !user.refreshTokenHash) {
      throw new UnauthorizedException('Sesion no encontrada');
    }

    const tokenValid = await argon2.verify(user.refreshTokenHash, refreshToken);
    if (!tokenValid) {
      // Posible reutilizacion de token: invalidar la sesion completa por seguridad
      await this.usersService.setRefreshTokenHash(user.id, null);
      throw new UnauthorizedException('Refresh token invalido');
    }

    return this.generateAuthResponse(user);
  }

  /**
   * Cierra la sesion invalidando el refresh token almacenado.
   */
  async logout(userId: string): Promise<void> {
    await this.usersService.setRefreshTokenHash(userId, null);
  }

  /**
   * Genera el par de tokens (access + refresh) y persiste el hash del refresh.
   */
  private async generateAuthResponse(user: User): Promise<AuthTokensDto> {
    const payload: JwtPayload = {
      sub: user.id,
      email: user.email,
      role: user.role,
    };

    const [accessToken, refreshToken] = await Promise.all([
      this.jwtService.signAsync(payload, {
        secret: this.configService.get<string>('jwt.accessSecret'),
        expiresIn: (this.configService.get<string>('jwt.accessExpiresIn') ??
          '15m') as unknown as number,
      }),
      this.jwtService.signAsync(payload, {
        secret: this.configService.get<string>('jwt.refreshSecret'),
        expiresIn: (this.configService.get<string>('jwt.refreshExpiresIn') ??
          '7d') as unknown as number,
      }),
    ]);

    const refreshHash = await argon2.hash(refreshToken);
    await this.usersService.setRefreshTokenHash(user.id, refreshHash);

    return {
      accessToken,
      refreshToken,
      tokenType: 'Bearer',
      user: UserResponseDto.fromEntity(user),
    };
  }
}
