import 'reflect-metadata';

import { AppDataSource } from '../data-source';

import { seedCultivos } from './catalogos/cultivos.seed';
import { seedFertilizantes } from './catalogos/fertilizantes.seed';
import { seedMunicipios } from './catalogos/municipios.seed';
import { seedPlagas } from './catalogos/plagas.seed';
import { seedTiposSuelo } from './catalogos/tipos-suelo.seed';
import { seedAdmin } from './admin.seed';
import { seedReglasAgricolas } from './reglas';


/**
 * Orquesta la ejecucion de todos los seeds del proyecto AgroField.
 *
 * Uso: npm run seed
 *
 * Todos los seeds son idempotentes: si los datos ya existen, no los duplica.
 */
async function main(): Promise<void> {
  console.log('Iniciando seeds de AgroField...\n');

  await AppDataSource.initialize();
  console.log('Conexion a BD establecida\n');

  // ─── Usuarios del sistema ─────────────────────────────────
  console.log('-> Seed: Administrador inicial');
  await seedAdmin(AppDataSource);

  // ─── Catalogos del dominio agricola del Magdalena ─────────
  console.log('\n-> Seeds: Catalogos del Magdalena');
  await seedMunicipios(AppDataSource);
  await seedCultivos(AppDataSource);
  await seedPlagas(AppDataSource);
  await seedFertilizantes(AppDataSource);
  await seedTiposSuelo(AppDataSource);

  // ─── Sistema experto de recomendaciones (Sprint 4) ─────────
  console.log('\n-> Seed: Reglas agronomicas del Magdalena');
  await seedReglasAgricolas(AppDataSource);

  await AppDataSource.destroy();
  console.log('\nTodos los seeds completados exitosamente.');
}

main().catch((error: unknown) => {
  console.error('\nError en seeds:', error);
  process.exit(1);
});
