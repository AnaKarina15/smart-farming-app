import { SetMetadata } from '@nestjs/common';

export const IS_PUBLIC_KEY = 'isPublic';

/**
 * Decorador que marca un endpoint como publico (no requiere JWT).
 *
 * Uso:
 *   @Public()
 *   @Post('login')
 *   async login() { ... }
 */
export const Public = (): MethodDecorator & ClassDecorator => SetMetadata(IS_PUBLIC_KEY, true);
