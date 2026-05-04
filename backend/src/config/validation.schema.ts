import * as Joi from 'joi';

/**
 * Schema de validacion para variables de entorno.
 *
 * La aplicacion no inicia si alguna variable critica falta o tiene formato invalido.
 * Esto previene errores silenciosos en produccion.
 */
export const validationSchema = Joi.object({
  // Aplicacion
  NODE_ENV: Joi.string().valid('development', 'production', 'test').default('development'),
  APP_PORT: Joi.number().port().default(3000),
  APP_NAME: Joi.string().default('AgroField API'),
  APP_VERSION: Joi.string().default('0.1.0'),
  API_PREFIX: Joi.string().default('api/v1'),

  // Base de datos
  DB_HOST: Joi.string().required(),
  DB_PORT: Joi.number().port().required(),
  DB_USERNAME: Joi.string().required(),
  DB_PASSWORD: Joi.string().required(),
  DB_DATABASE: Joi.string().required(),
  DB_SYNCHRONIZE: Joi.boolean().default(false),
  DB_LOGGING: Joi.boolean().default(false),
  DB_SSL: Joi.boolean().default(false),

  // JWT
  JWT_ACCESS_SECRET: Joi.string().min(32).required(),
  JWT_ACCESS_EXPIRES_IN: Joi.string().default('15m'),
  JWT_REFRESH_SECRET: Joi.string().min(32).required(),
  JWT_REFRESH_EXPIRES_IN: Joi.string().default('7d'),

  // Seguridad
  CORS_ORIGINS: Joi.string().allow('').default(''),
  THROTTLE_TTL: Joi.number().default(60000),
  THROTTLE_LIMIT: Joi.number().default(100),

  // Logging
  LOG_LEVEL: Joi.string()
    .valid('error', 'warn', 'info', 'http', 'verbose', 'debug', 'silly')
    .default('info'),

  // Swagger
  SWAGGER_ENABLED: Joi.boolean().default(true),
  SWAGGER_PATH: Joi.string().default('api/docs'),
});
