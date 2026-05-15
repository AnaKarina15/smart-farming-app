import { ValidationPipe, VersioningType } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { NestFactory } from '@nestjs/core';
import { NestExpressApplication } from '@nestjs/platform-express';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import compression from 'compression';
import helmet from 'helmet';
import { WINSTON_MODULE_NEST_PROVIDER } from 'nest-winston';

import { AppModule } from './app.module';
import { HttpExceptionFilter } from './common/filters/http-exception.filter';
import { TransformInterceptor } from './common/interceptors/transform.interceptor';

/**
 * Bootstrap de la aplicacion AgroField API.
 *
 * Configura:
 * - Logger estructurado (Winston)
 * - Validacion global (class-validator)
 * - Filtros y transformadores globales
 * - Seguridad (Helmet, CORS, compresion)
 * - Documentacion Swagger
 * - Versionado de API (URI: /api/v1)
 */
async function bootstrap(): Promise<void> {
  const app = await NestFactory.create<NestExpressApplication>(AppModule, {
    bufferLogs: true,
  });

  // Logger
  app.useLogger(app.get(WINSTON_MODULE_NEST_PROVIDER));

  // Configuracion
  const configService = app.get(ConfigService);
  const port = configService.get<number>('app.port', 3000);
  const apiPrefix = configService.get<string>('app.apiPrefix', 'api/v1');
  const corsOrigins = configService.get<string[]>('app.corsOrigins', []);
  const swaggerEnabled = configService.get<boolean>('swagger.enabled', true);
  const swaggerPath = configService.get<string>('swagger.path', 'api/docs');
  const appName = configService.get<string>('app.name', 'AgroField API');
  const appVersion = configService.get<string>('app.version', '0.1.0');

  // Prefijo global y versionado
  app.setGlobalPrefix(apiPrefix);
  // Versionado deshabilitado - el prefijo /api/v1 ya esta en setGlobalPrefix
  // app.enableVersioning({
  //   type: VersioningType.URI,
  //   defaultVersion: '1',
  // });

  // Seguridad
  app.use(helmet());
  app.use(compression());
  app.enableCors({
    origin: (origin, callback) => {
      // Permite cualquier origen localhost (cualquier puerto) para desarrollo
      if (!origin || origin.match(/^https?:\/\/(localhost|127\.0\.0\.1):\d+$/)) {
        return callback(null, true);
      }
      // Permite tambien los origenes configurados en .env
      if (corsOrigins.length === 0 || corsOrigins.includes(origin)) {
        return callback(null, true);
      }
      callback(new Error('CORS bloqueado'));
    },
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  });

  // Validacion global - rechaza propiedades no declaradas en DTOs (seguridad)
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: { enableImplicitConversion: false },
    }),
  );

  // Filtros e interceptores globales
  app.useGlobalFilters(new HttpExceptionFilter());
  app.useGlobalInterceptors(new TransformInterceptor());

  // Swagger / OpenAPI
  if (swaggerEnabled) {
    const config = new DocumentBuilder()
      .setTitle(appName)
      .setDescription(
        'AgroField - Plataforma Digital de Agricultura Inteligente para Pequenos ' +
          'Productores del Magdalena. API REST que soporta operacion offline-first, ' +
          'sincronizacion automatica, y los procesos de Plantacion, Monitoreo y Riego, ' +
          'Fertilizacion y Manejo Fitosanitario.',
      )
      .setVersion(appVersion)
      .addBearerAuth(
        {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
          name: 'JWT',
          description: 'Ingresa el token JWT de acceso',
          in: 'header',
        },
        'JWT-auth',
      )
      .addTag('Auth', 'Autenticacion: registro, login, refresh de tokens')
      .addTag('Users', 'Gestion de usuarios (Pequeno Productor, Trabajador, Gestor)')
      .addTag('Lotes', 'Gestion de lotes/parcelas del productor (RF02, RF04)')
      .addTag('Health', 'Estado de salud de la aplicacion')
      .build();

    const document = SwaggerModule.createDocument(app, config);
    SwaggerModule.setup(swaggerPath, app, document, {
      swaggerOptions: {
        persistAuthorization: true,
        tagsSorter: 'alpha',
        operationsSorter: 'alpha',
      },
    });
  }

  await app.listen(port, '0.0.0.0');

  const url = await app.getUrl();
  const logger = app.get(WINSTON_MODULE_NEST_PROVIDER);
  logger.log(`AgroField API escuchando en ${url}/${apiPrefix}`);
  if (swaggerEnabled) {
    logger.log(`Swagger UI disponible en ${url}/${swaggerPath}`);
  }
}

bootstrap().catch((err) => {
  // eslint-disable-next-line no-console
  console.error('Error fatal al iniciar la aplicacion:', err);
  process.exit(1);
});
