import { utilities as nestWinstonModuleUtilities } from 'nest-winston';
import * as winston from 'winston';

/**
 * Configuracion del logger Winston con formato estructurado.
 *
 * En desarrollo: formato legible con colores en consola.
 * En produccion: JSON estructurado para integracion con sistemas de logs (ELK, Datadog, etc).
 */
export const winstonConfig = (): winston.LoggerOptions => {
  const isProduction = process.env.NODE_ENV === 'production';
  const logLevel = process.env.LOG_LEVEL || 'info';

  return {
    level: logLevel,
    transports: [
      new winston.transports.Console({
        format: isProduction
          ? winston.format.combine(
              winston.format.timestamp(),
              winston.format.errors({ stack: true }),
              winston.format.json(),
            )
          : winston.format.combine(
              winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
              winston.format.ms(),
              winston.format.errors({ stack: true }),
              nestWinstonModuleUtilities.format.nestLike('AgroField', {
                colors: true,
                prettyPrint: true,
              }),
            ),
      }),
    ],
  };
};
