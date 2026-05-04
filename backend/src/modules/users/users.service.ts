import {
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import * as argon2 from 'argon2';

import { CreateUserDto } from './dto/create-user.dto';
import { UserResponseDto } from './dto/user-response.dto';
import { User } from './entities/user.entity';
import { UsersRepository } from './users.repository';

@Injectable()
export class UsersService {
  constructor(private readonly usersRepo: UsersRepository) {}

  /**
   * Crea un nuevo usuario.
   *
   * Hashea la contrasena con Argon2id (estandar OWASP 2026).
   * Lanza ConflictException si el email ya existe.
   */
  async create(dto: CreateUserDto): Promise<User> {
    const exists = await this.usersRepo.existsByEmail(dto.email);
    if (exists) {
      throw new ConflictException('Ya existe un usuario con ese correo electronico');
    }

    const passwordHash = await argon2.hash(dto.password, {
      type: argon2.argon2id,
      memoryCost: 19456, // 19 MB
      timeCost: 2,
      parallelism: 1,
    });

    return this.usersRepo.create({
      nombreCompleto: dto.nombreCompleto,
      email: dto.email,
      telefono: dto.telefono ?? null,
      password: passwordHash,
      role: dto.role,
    });
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

  toResponseDto(user: User): UserResponseDto {
    return UserResponseDto.fromEntity(user);
  }
}
