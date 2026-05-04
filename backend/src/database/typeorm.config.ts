import { ConfigService } from '@nestjs/config';
import { TypeOrmModuleOptions } from '@nestjs/typeorm';

/**
 * Factory de configuracion de TypeORM.
 *
 * Carga la configuracion desde ConfigService, que a su vez la lee de variables de entorno
 * validadas con Joi. Esto previene errores de configuracion en tiempo de arranque.
 */
export const typeOrmConfigFactory = (configService: ConfigService): TypeOrmModuleOptions => ({
  type: 'postgres',
  host: configService.get<string>('database.host'),
  port: configService.get<number>('database.port'),
  username: configService.get<string>('database.username'),
  password: configService.get<string>('database.password'),
  database: configService.get<string>('database.database'),
  entities: [__dirname + '/../**/*.entity{.ts,.js}'],
  migrations: [__dirname + '/migrations/*{.ts,.js}'],
  synchronize: configService.get<boolean>('database.synchronize'),
  logging: configService.get<boolean>('database.logging'),
  ssl: configService.get<boolean>('database.ssl') ? { rejectUnauthorized: false } : false,
  autoLoadEntities: true,
});
