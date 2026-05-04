import { ExecutionContext, createParamDecorator } from '@nestjs/common';

/**
 * Payload del JWT despues de validacion.
 */
export interface JwtPayload {
  sub: string; // user.id
  email: string;
  role: string;
  iat?: number;
  exp?: number;
}

/**
 * Decorador que extrae el usuario autenticado del request.
 *
 * Uso:
 *   @Get('me')
 *   getMe(@CurrentUser() user: JwtPayload) {
 *     return user;
 *   }
 *
 *   // Tambien puede extraer una propiedad especifica:
 *   @Get('lotes')
 *   getLotes(@CurrentUser('sub') userId: string) { ... }
 */
export const CurrentUser = createParamDecorator(
  (data: keyof JwtPayload | undefined, ctx: ExecutionContext) => {
    const request = ctx.switchToHttp().getRequest();
    const user = request.user as JwtPayload;

    if (!user) {
      return undefined;
    }

    return data ? user[data] : user;
  },
);
