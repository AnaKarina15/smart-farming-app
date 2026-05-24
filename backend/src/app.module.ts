import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { APP_GUARD } from '@nestjs/core';
import { ThrottlerGuard, ThrottlerModule } from '@nestjs/throttler';
import { TypeOrmModule } from '@nestjs/typeorm';
import { WinstonModule } from 'nest-winston';

import { winstonConfig } from './common/utils/winston.config';
import appConfig from './config/app.config';
import databaseConfig from './config/database.config';
import jwtConfig from './config/jwt.config';
import swaggerConfig from './config/swagger.config';
import { validationSchema } from './config/validation.schema';
import { typeOrmConfigFactory } from './database/typeorm.config';
import { AuditModule } from './modules/audit/audit.module';
import { AuthModule } from './modules/auth/auth.module';
import { CatalogosModule } from './modules/catalogos/catalogos.module';
import { HealthModule } from './modules/health/health.module';
import { LotesModule } from './modules/lotes/lotes.module';
import { FertilizacionModule } from './modules/fertilizacion/fertilizacion.module';
import { ObservacionesModule } from './modules/observaciones/observaciones.module';
import { RecomendacionesModule } from './modules/recomendaciones/recomendaciones.module';
import { HallazgosModule } from './modules/hallazgos/hallazgos.module';
import { RiegoModule } from './modules/riego/riego.module';
import { SiembrasModule } from './modules/siembras/siembras.module';
import { SyncModule } from './modules/sync/sync.module';
import { TratamientosModule } from './modules/tratamientos/tratamientos.module';
import { EstadoTerrenoModule } from './modules/estado-terreno/estado-terreno.module';
import { UsersModule } from './modules/users/users.module';
import { WeatherModule } from './modules/weather/weather.module';

/**
 * Modulo raiz de AgroField API.
 *
 * Configura:
 * - Configuracion tipada y validada (Joi)
 * - Conexion a PostgreSQL via TypeORM
 * - Logger estructurado (Winston)
 * - Rate limiting global (Throttler) - protege contra abuso de endpoints
 * - Modulos de negocio (Auth, Users, Lotes, Health, Audit, Weather)
 */
@Module({
  imports: [
    // Configuracion tipada y validada
    ConfigModule.forRoot({
      isGlobal: true,
      cache: true,
      load: [appConfig, databaseConfig, jwtConfig, swaggerConfig],
      validationSchema,
      validationOptions: {
        allowUnknown: true,
        abortEarly: false,
      },
    }),
    // Logger
    WinstonModule.forRootAsync({
      useFactory: () => winstonConfig(),
    }),
    // Base de datos
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: typeOrmConfigFactory,
      inject: [ConfigService],
    }),
    // Rate limiting global (proteccion contra abuso)
    ThrottlerModule.forRootAsync({
      useFactory: () => ({
        throttlers: [
          {
            ttl: parseInt(process.env.THROTTLE_TTL || '60000', 10),
            limit: parseInt(process.env.THROTTLE_LIMIT || '100', 10),
          },
        ],
      }),
    }),
    // Modulos de negocio
    AuditModule,
    AuthModule,
    UsersModule,
    LotesModule,
    CatalogosModule,
    FertilizacionModule,
    HallazgosModule,
    ObservacionesModule,
    RecomendacionesModule,
    RiegoModule,
    SiembrasModule,
    SyncModule,
    TratamientosModule,
    EstadoTerrenoModule,
    HealthModule,
    WeatherModule,
  ],
  providers: [
    {
      provide: APP_GUARD,
      useClass: ThrottlerGuard,
    },
  ],
})
export class AppModule {}
