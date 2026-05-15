import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Brackets, Repository } from 'typeorm';

import { User } from './entities/user.entity';
import { UserRole } from './entities/user-role.enum';

export interface ListUsersFilters {
  role?: UserRole;
  activo?: boolean;
  search?: string;
  includeDeleted?: boolean;
  limit?: number;
  offset?: number;
}

@Injectable()
export class UsersRepository {
  constructor(
    @InjectRepository(User)
    private readonly repo: Repository<User>,
  ) {}

  async findById(id: string, includeDeleted = false): Promise<User | null> {
    return this.repo.findOne({
      where: { id },
      withDeleted: includeDeleted,
    });
  }

  async findByEmail(email: string): Promise<User | null> {
    return this.repo.findOne({ where: { email: email.toLowerCase() } });
  }

  async findByEmailWithPassword(email: string): Promise<User | null> {
    return this.repo
      .createQueryBuilder('user')
      .addSelect('user.password')
      .where('user.email = :email', { email: email.toLowerCase() })
      .andWhere('user.deletedAt IS NULL')
      .getOne();
  }

  async findByIdWithRefreshToken(id: string): Promise<User | null> {
    return this.repo
      .createQueryBuilder('user')
      .addSelect('user.refreshTokenHash')
      .where('user.id = :id', { id })
      .andWhere('user.deletedAt IS NULL')
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

  async save(user: User): Promise<User> {
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

  async softDelete(id: string): Promise<void> {
    await this.repo.softDelete(id);
  }

  async restore(id: string): Promise<void> {
    await this.repo.restore(id);
  }

  /**
   * Lista usuarios con filtros y paginacion.
   */
  async findAll(filters: ListUsersFilters): Promise<{ data: User[]; total: number }> {
    const query = this.repo.createQueryBuilder('user').orderBy('user.createdAt', 'DESC');

    if (filters.includeDeleted) {
      query.withDeleted();
    } else {
      query.andWhere('user.deletedAt IS NULL');
    }

    if (filters.role) {
      query.andWhere('user.role = :role', { role: filters.role });
    }

    if (filters.activo !== undefined) {
      query.andWhere('user.activo = :activo', { activo: filters.activo });
    }

    if (filters.search) {
      query.andWhere(
        new Brackets((qb) => {
          qb.where('user.nombreCompleto ILIKE :search', {
            search: `%${filters.search}%`,
          }).orWhere('user.email ILIKE :search', { search: `%${filters.search}%` });
        }),
      );
    }

    const limit = filters.limit ?? 20;
    const offset = filters.offset ?? 0;
    query.take(limit).skip(offset);

    const [data, total] = await query.getManyAndCount();
    return { data, total };
  }

  /**
   * Cuenta usuarios por rol (para reportes admin).
   */
  async countByRole(): Promise<Record<UserRole, number>> {
    const rows = await this.repo
      .createQueryBuilder('user')
      .select('user.role', 'role')
      .addSelect('COUNT(*)::int', 'count')
      .groupBy('user.role')
      .getRawMany<{ role: UserRole; count: number }>();

    const result: Record<string, number> = {
      [UserRole.PEQUENO_PRODUCTOR]: 0,
      [UserRole.TRABAJADOR]: 0,
      [UserRole.GESTOR]: 0,
      [UserRole.ADMINISTRADOR]: 0,
    };

    for (const row of rows) {
      result[row.role] = row.count;
    }

    return result as Record<UserRole, number>;
  }
}
