import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { Lote } from '../lotes/entities/lote.entity';
import { LecturaSensor } from './entities/lectura-sensor.entity';
import { Sensor } from './entities/sensor.entity';
import { SensoresController } from './sensores.controller';
import { SensoresRepository } from './sensores.repository';
import { SensoresService } from './sensores.service';

@Module({
  imports: [TypeOrmModule.forFeature([Sensor, LecturaSensor, Lote])],
  controllers: [SensoresController],
  providers: [SensoresService, SensoresRepository],
  exports: [SensoresService, SensoresRepository],
})
export class SensoresModule {}
