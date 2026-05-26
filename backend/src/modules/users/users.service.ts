import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import * as argon2 from 'argon2';
import { randomBytes } from 'crypto';

import { AuditService } from '../audit/audit.service';

import { ChangePasswordDto } from './dto/change-password.dto';
import { CreateUserDto } from './dto/create-user.dto';
import { ListUsersQueryDto } from './dto/list-users-query.dto';
import { ResetPasswordDto } from './dto/reset-password.dto';
import { AdminUpdateUserDto } from './dto/update-user.dto';
import { UserResponseDto } from './dto/user-response.dto';
import { User } from './entities/user.entity';
import { UserRole } from './entities/user-role.enum';
import { UsersRepository } from './users.repository';

@Injectable()
export class UsersService {
  constructor(
    private readonly usersRepo: UsersRepository,
    private readonly auditService: AuditService,
  ) {}

  // ──────────────────────────────────────────────────────────
  // OPERACIONES BASICAS (existentes - mantienen compatibilidad)
  // ──────────────────────────────────────────────────────────

  async create(dto: CreateUserDto, createdByUserId?: string): Promise<User> {
    const exists = await this.usersRepo.existsByEmail(dto.email);
    if (exists) {
      throw new ConflictException('Ya existe un usuario con ese correo electronico');
    }

    if (dto.telefono) {
      const phoneExists = await this.usersRepo.existsByTelefono(dto.telefono);
      if (phoneExists) {
        throw new ConflictException('Ese número de teléfono ya está registrado');
      }
    }

    const passwordHash = await this.hashPassword(dto.password);

    const user = await this.usersRepo.create({
      nombreCompleto: dto.nombreCompleto,
      email: dto.email,
      telefono: dto.telefono ?? null,
      password: passwordHash,
      role: dto.role ?? UserRole.PEQUENO_PRODUCTOR,
      createdBy: createdByUserId ?? null,
      passwordChangedAt: new Date(),
    });

    // Audit: registro o creacion por admin
    await this.auditService.log({
      actorId: createdByUserId ?? user.id,
      action: createdByUserId ? 'user.admin_create' : 'user.register',
      targetType: 'user',
      targetId: user.id,
      details: { role: user.role, email: user.email },
    });

    return user;
  }

  async findById(id: string): Promise<User> {
    const user = await this.usersRepo.findById(id);
    if (!user) {
      throw new NotFoundException(`Usuario con id ${id} no encontrado`);
    }
    return user;
  }

  async findByEmail(email: string): Promise<User | null> {
    return this.usersRepo.findByEmail(email);
  }

  async findByEmailWithPassword(email: string): Promise<User | null> {
    return this.usersRepo.findByEmailWithPassword(email);
  }

  async findByIdWithRefreshToken(id: string): Promise<User | null> {
    return this.usersRepo.findByIdWithRefreshToken(id);
  }

  async setRefreshTokenHash(id: string, refreshTokenHash: string | null): Promise<void> {
    await this.usersRepo.updateRefreshToken(id, refreshTokenHash);
  }

  async registrarAcceso(id: string): Promise<void> {
    await this.usersRepo.updateUltimoAcceso(id);
  }

  async requestPasswordRecovery(
    email: string,
  ): Promise<{ message: string; temporaryPassword: string }> {
    const user = await this.usersRepo.findByEmail(email);
    if (!user || !user.activo) {
      throw new NotFoundException('No existe una cuenta activa con ese correo electronico');
    }

    const temporaryPassword = this.generateTemporaryPassword();
    user.password = await this.hashPassword(temporaryPassword);
    user.passwordChangedAt = new Date();
    user.mustChangePassword = true;
    user.refreshTokenHash = null;

    await this.usersRepo.save(user);

    await this.auditService.log({
      actorId: user.id,
      action: 'user.password_recovery',
      targetType: 'user',
      targetId: user.id,
      details: { byUser: true },
    });

    return {
      message: 'Contraseña temporal generada. Inicia sesion con ella y cambia tu contraseña.',
      temporaryPassword,
    };
  }

  async changeOwnPassword(userId: string, dto: ChangePasswordDto): Promise<UserResponseDto> {
    if (dto.newPassword !== dto.confirmPassword) {
      throw new BadRequestException('Las contraseñas no coinciden');
    }

    const user = await this.usersRepo.findByIdWithPassword(userId);
    if (!user || !user.activo) {
      throw new NotFoundException('Usuario no encontrado');
    }

    if (!user.mustChangePassword) {
      if (!dto.currentPassword) {
        throw new BadRequestException('Debes ingresar tu contraseña actual');
      }

      const currentPasswordValid = await argon2.verify(user.password, dto.currentPassword);
      if (!currentPasswordValid) {
        throw new UnauthorizedException('La contraseña actual es incorrecta');
      }
    }

    const samePassword = await argon2.verify(user.password, dto.newPassword);
    if (samePassword) {
      throw new BadRequestException('La nueva contraseña debe ser diferente a la actual');
    }

    user.password = await this.hashPassword(dto.newPassword);
    user.passwordChangedAt = new Date();
    user.mustChangePassword = false;

    await this.usersRepo.save(user);

    await this.auditService.log({
      actorId: user.id,
      action: 'user.password_change',
      targetType: 'user',
      targetId: user.id,
      details: { byUser: true },
    });

    return UserResponseDto.fromEntity(user);
  }

  toResponseDto(user: User): UserResponseDto {
    return UserResponseDto.fromEntity(user);
  }

  async updateAvatar(id: string, file: Express.Multer.File): Promise<UserResponseDto> {
    const user = await this.findById(id);
    // In a real production app, we would upload to S3 or a CDN here.
    // For this prototype, we'll assume a local static directory or a base64 string.
    // Actually, we can just save the base64 string or a local path.
    // If we use local storage in Multer, `file.filename` is the name.
    const url = `/public/uploads/avatars/${file.filename}`;

    user.fotoPerfilUrl = url;
    await this.usersRepo.save(user);

    await this.auditService.log({
      actorId: id,
      action: 'user.update_avatar',
      targetType: 'user',
      targetId: id,
      details: { url },
    });

    return this.toResponseDto(user);
  }

  // ──────────────────────────────────────────────────────────
  // OPERACIONES ADMIN
  // ──────────────────────────────────────────────────────────

  /**
   * Lista usuarios con filtros y paginacion. Solo accesible por admin.
   */
  async findAll(query: ListUsersQueryDto): Promise<{
    data: UserResponseDto[];
    total: number;
    limit: number;
    offset: number;
  }> {
    const limit = query.limit ?? 20;
    const offset = query.offset ?? 0;

    const { data, total } = await this.usersRepo.findAll({
      role: query.role,
      activo: query.activo,
      search: query.search,
      includeDeleted: query.includeDeleted ?? false,
      limit,
      offset,
    });

    return {
      data: data.map((u) => UserResponseDto.fromEntity(u)),
      total,
      limit,
      offset,
    };
  }

  /**
   * Admin actualiza datos de un usuario (nombre, telefono, rol, activo).
   */
  async adminUpdate(
    targetUserId: string,
    dto: AdminUpdateUserDto,
    adminId: string,
  ): Promise<UserResponseDto> {
    const user = await this.usersRepo.findById(targetUserId);
    if (!user) {
      throw new NotFoundException('Usuario no encontrado');
    }

    // Proteccion: no se puede degradar al ultimo admin del sistema
    if (user.role === UserRole.ADMINISTRADOR && dto.role && dto.role !== UserRole.ADMINISTRADOR) {
      const counts = await this.usersRepo.countByRole();
      if (counts[UserRole.ADMINISTRADOR] <= 1) {
        throw new BadRequestException('No se puede degradar al ultimo administrador del sistema');
      }
    }

    const changes: Record<string, unknown> = {};
    if (dto.nombreCompleto !== undefined && dto.nombreCompleto !== user.nombreCompleto) {
      changes.nombreCompleto = { from: user.nombreCompleto, to: dto.nombreCompleto };
      user.nombreCompleto = dto.nombreCompleto;
    }
    if (dto.telefono !== undefined && dto.telefono !== user.telefono) {
      if (dto.telefono) {
        const phoneExists = await this.usersRepo.existsByTelefono(dto.telefono);
        if (phoneExists) {
          throw new ConflictException('Ese número de teléfono ya está registrado por otro usuario');
        }
      }
      changes.telefono = { from: user.telefono, to: dto.telefono };
      user.telefono = dto.telefono;
    }
    if (dto.role !== undefined && dto.role !== user.role) {
      changes.role = { from: user.role, to: dto.role };
      user.role = dto.role;
    }
    if (dto.activo !== undefined && dto.activo !== user.activo) {
      changes.activo = { from: user.activo, to: dto.activo };
      user.activo = dto.activo;
    }

    await this.usersRepo.save(user);

    if (Object.keys(changes).length > 0) {
      await this.auditService.log({
        actorId: adminId,
        action: 'user.admin_update',
        targetType: 'user',
        targetId: user.id,
        details: changes,
      });
    }

    return UserResponseDto.fromEntity(user);
  }

  /**
   * Admin resetea la password de un usuario. Util para recuperacion de cuenta
   * cuando el productor no puede acceder (bajo nivel de alfabetizacion digital).
   *
   * El usuario sera forzado a cambiar la password en su proximo login
   * (campo mustChangePassword = true).
   */
  async adminResetPassword(
    targetUserId: string,
    dto: ResetPasswordDto,
    adminId: string,
  ): Promise<{ message: string; temporaryPassword: string }> {
    const user = await this.usersRepo.findById(targetUserId);
    if (!user) {
      throw new NotFoundException('Usuario no encontrado');
    }

    const passwordHash = await this.hashPassword(dto.newPassword);

    user.password = passwordHash;
    user.passwordChangedAt = new Date();
    user.mustChangePassword = true;
    user.refreshTokenHash = null; // invalida sesiones existentes

    await this.usersRepo.save(user);

    await this.auditService.log({
      actorId: adminId,
      action: 'user.password_reset',
      targetType: 'user',
      targetId: user.id,
      details: { byAdmin: true },
    });

    return {
      message: 'Password reseteada exitosamente. El usuario debera cambiarla en su proximo login.',
      temporaryPassword: dto.newPassword,
    };
  }

  /**
   * Soft-delete: marca el usuario como eliminado pero conserva su historial.
   */
  async adminSoftDelete(targetUserId: string, adminId: string): Promise<void> {
    const user = await this.usersRepo.findById(targetUserId);
    if (!user) {
      throw new NotFoundException('Usuario no encontrado');
    }

    // Proteccion: no se puede eliminar al ultimo admin
    if (user.role === UserRole.ADMINISTRADOR) {
      const counts = await this.usersRepo.countByRole();
      if (counts[UserRole.ADMINISTRADOR] <= 1) {
        throw new BadRequestException('No se puede eliminar al ultimo administrador del sistema');
      }
    }

    // No se puede auto-eliminar
    if (user.id === adminId) {
      throw new ForbiddenException('No puedes eliminar tu propia cuenta de administrador');
    }

    await this.usersRepo.softDelete(targetUserId);

    await this.auditService.log({
      actorId: adminId,
      action: 'user.delete',
      targetType: 'user',
      targetId: user.id,
      details: { email: user.email, role: user.role },
    });
  }

  /**
   * Restaura un usuario previamente soft-deleted.
   */
  async adminRestore(targetUserId: string, adminId: string): Promise<UserResponseDto> {
    const user = await this.usersRepo.findById(targetUserId, true);
    if (!user) {
      throw new NotFoundException('Usuario no encontrado');
    }
    if (!user.deletedAt) {
      throw new BadRequestException('El usuario no esta eliminado');
    }

    await this.usersRepo.restore(targetUserId);

    await this.auditService.log({
      actorId: adminId,
      action: 'user.restore',
      targetType: 'user',
      targetId: user.id,
      details: { email: user.email },
    });

    const restored = await this.findById(targetUserId);
    return UserResponseDto.fromEntity(restored);
  }

  /**
   * Estadisticas para el dashboard del admin.
   */
  async getStats(): Promise<{
    totalUsuarios: number;
    porRol: Record<UserRole, number>;
    activos: number;
    inactivos: number;
  }> {
    const porRol = await this.usersRepo.countByRole();
    const totalUsuarios = Object.values(porRol).reduce((sum, n) => sum + n, 0);

    const { total: activos } = await this.usersRepo.findAll({
      activo: true,
      limit: 1,
      offset: 0,
    });
    const inactivos = totalUsuarios - activos;

    return { totalUsuarios, porRol, activos, inactivos };
  }

  // ──────────────────────────────────────────────────────────
  // UTILIDADES PRIVADAS
  // ──────────────────────────────────────────────────────────

  private async hashPassword(plain: string): Promise<string> {
    return argon2.hash(plain, {
      type: argon2.argon2id,
      memoryCost: 19456,
      timeCost: 2,
      parallelism: 1,
    });
  }

  private generateTemporaryPassword(): string {
    return `Agro${randomBytes(4).toString('hex')}1`;
  }
}
