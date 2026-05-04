import { ExecutionContext, Injectable } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { AuthGuard } from '@nestjs/passport';

import { IS_PUBLIC_KEY } from '@/common/decorators/public.decorator';

/**
 * Guard JWT que protege todos los endpoints por defecto.
 *
 * Los endpoints marcados con @Public() son excluidos de la verificacion.
 *
 * Para activarlo globalmente, registrar en AppModule:
 *   { provide: APP_GUARD, useClass: JwtAuthGuard }
 */
@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  constructor(private readonly reflector: Reflector) {
    super();
  }

  canActivate(context: ExecutionContext) {
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);

    if (isPublic) {
      return true;
    }

    return super.canActivate(context);
  }
}
