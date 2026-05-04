import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { User } from './entities/user.entity';

/**
 * Repositorio de Users.
 *
 * Encapsula el acceso a datos de la entidad User. Sigue el patron Repository de DDD.
 * Si en el futuro cambiamos el ORM o la fuente de datos, solo este archivo cambia.
 */
@Injectable()
export class UsersRepository {
  constructor(
    @InjectRepository(User)
    private readonly repo: Repository<User>,
  ) {}

  async findById(id: string): Promise<User | null> {
    return this.repo.findOne({ where: { id } });
  }

  async findByEmail(email: string): Promise<User | null> {
    return this.repo.findOne({ where: { email: email.toLowerCase() } });
  }

  /**
   * Busca por email incluyendo el campo password (excluido por defecto).
   * Solo usar en el flujo de autenticacion.
   */
  async findByEmailWithPassword(email: string): Promise<User | null> {
    return this.repo
      .createQueryBuilder('user')
      .addSelect('user.password')
      .where('user.email = :email', { email: email.toLowerCase() })
      .getOne();
  }

  async findByIdWithRefreshToken(id: string): Promise<User | null> {
    return this.repo
      .createQueryBuilder('user')
      .addSelect('user.refreshTokenHash')
      .where('user.id = :id', { id })
      .getOne();
  }

  async existsByEmail(email: string): Promise<boolean> {
    const count = await this.repo.count({ where: { email: email.toLowerCase() } });
    return count > 0;
  }

  async create(data: Partial<User>): Promise<User> {
    const user = this.repo.create({
      ...data,
      email: data.email?.toLowerCase(),
    });
    return this.repo.save(user);
  }

  async update(id: string, data: Partial<User>): Promise<void> {
    await this.repo.update(id, data);
  }

  async updateRefreshToken(id: string, refreshTokenHash: string | null): Promise<void> {
    await this.repo.update(id, { refreshTokenHash });
  }

  async updateUltimoAcceso(id: string): Promise<void> {
    await this.repo.update(id, { ultimoAcceso: new Date() });
  }
}
