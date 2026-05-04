import { CallHandler, ExecutionContext, Injectable, NestInterceptor } from '@nestjs/common';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';

/**
 * Estructura estandar de respuesta exitosa.
 */
export interface ApiResponse<T> {
  statusCode: number;
  timestamp: string;
  data: T;
}

/**
 * Interceptor global que envuelve todas las respuestas exitosas en un formato consistente.
 *
 * Antes:  { "id": 1, "nombre": "Lote Norte" }
 * Despues: { "statusCode": 200, "timestamp": "...", "data": { "id": 1, "nombre": "Lote Norte" } }
 *
 * Esto facilita el manejo de respuestas en el cliente (Flutter) y la depuracion.
 */
@Injectable()
export class TransformInterceptor<T> implements NestInterceptor<T, ApiResponse<T>> {
  intercept(context: ExecutionContext, next: CallHandler): Observable<ApiResponse<T>> {
    const ctx = context.switchToHttp();
    const response = ctx.getResponse();

    return next.handle().pipe(
      map((data) => ({
        statusCode: response.statusCode,
        timestamp: new Date().toISOString(),
        data,
      })),
    );
  }
}
