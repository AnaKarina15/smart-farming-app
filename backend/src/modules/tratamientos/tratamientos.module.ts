import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { Hallazgo } from '../hallazgos/entities/hallazgo.entity';
import { Lote } from '../lotes/entities/lote.entity';
import { Tratamiento } from './entities/tratamiento.entity';
import { TratamientosController } from './tratamientos.controller';
import { TratamientosRepository } from './tratamientos.repository';
import { TratamientosService } from './tratamientos.service';

@Module({
  imports: [TypeOrmModule.forFeature([Tratamiento, Lote, Hallazgo])],
  controllers: [TratamientosController],
  providers: [TratamientosService, TratamientosRepository],
  exports: [TratamientosService],
})
export class TratamientosModule {}
