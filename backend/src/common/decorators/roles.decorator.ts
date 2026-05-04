import { SetMetadata } from '@nestjs/common';

import { UserRole } from '@/modules/users/entities/user-role.enum';

export const ROLES_KEY = 'roles';

/**
 * Decorador que restringe el acceso a un endpoint a roles especificos.
 *
 * Uso:
 *   @Roles(UserRole.GESTOR)
 *   @Get('reportes-comunidad')
 *   async getReportesComunidad() { ... }
 *
 *   // Multiples roles:
 *   @Roles(UserRole.PEQUENO_PRODUCTOR, UserRole.TRABAJADOR)
 */
export const Roles = (...roles: UserRole[]): MethodDecorator & ClassDecorator =>
  SetMetadata(ROLES_KEY, roles);
