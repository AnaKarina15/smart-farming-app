import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { EntityManager, Repository } from 'typeorm';

import { LecturaSensor } from './entities/lectura-sensor.entity';
import { Sensor } from './entities/sensor.entity';

@Injectable()
export class SensoresRepository {
  constructor(
    @InjectRepository(Sensor)
    public readonly sensores: Repository<Sensor>,

    @InjectRepository(LecturaSensor)
    public readonly lecturas: Repository<LecturaSensor>,
  ) {}

  sensorRepo(manager?: EntityManager): Repository<Sensor> {
    return manager ? manager.getRepository(Sensor) : this.sensores;
  }

  lecturaRepo(manager?: EntityManager): Repository<LecturaSensor> {
    return manager ? manager.getRepository(LecturaSensor) : this.lecturas;
  }

  findSensorById(id: string, manager?: EntityManager): Promise<Sensor | null> {
    return this.sensorRepo(manager).findOne({ where: { id } });
  }

  findLecturaByClientLocalId(
    userId: string,
    sensorId: string,
    clientLocalId: string,
    manager?: EntityManager,
  ): Promise<LecturaSensor | null> {
    return this.lecturaRepo(manager).findOne({
      where: { userId, sensorId, clientLocalId },
    });
  }
}
