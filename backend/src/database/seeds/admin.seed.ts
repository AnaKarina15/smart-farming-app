import { DataSource } from 'typeorm';
import * as argon2 from 'argon2';

import { User } from '../../modules/users/entities/user.entity';
import { UserRole } from '../../modules/users/entities/user-role.enum';

/**
 * Seed: Crea el administrador inicial del sistema.
 *
 * Idempotente: si ya existe, no hace nada.
 *
 * Credenciales por defecto (CAMBIAR EN PRODUCCION):
 *   Email:    admin@agrofield.com
 *   Password: Admin1234
 */
export async function seedAdmin(dataSource: DataSource): Promise<void> {
  const userRepo = dataSource.getRepository(User);

  const adminEmail = 'admin@agrofield.com';
  const exists = await userRepo.findOne({ where: { email: adminEmail } });

  if (exists) {
    console.log('  ✓ El administrador ya existe (skip)');
    return;
  }

  const passwordHash = await argon2.hash('Admin1234', {
    type: argon2.argon2id,
    memoryCost: 19456,
    timeCost: 2,
    parallelism: 1,
  });

  const admin = userRepo.create({
    nombreCompleto: 'Administrador del Sistema',
    email: adminEmail,
    telefono: '+573000000000',
    password: passwordHash,
    role: UserRole.ADMINISTRADOR,
    activo: true,
    passwordChangedAt: new Date(),
    mustChangePassword: false,
  });

  await userRepo.save(admin);
  console.log('  ✓ Administrador creado:');
  console.log('    Email:    admin@agrofield.com');
  console.log('    Password: Admin1234');
  console.log('    ⚠️  CAMBIA esta password en produccion');
}
