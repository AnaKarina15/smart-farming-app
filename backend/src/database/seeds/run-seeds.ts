import 'reflect-metadata';
import { AppDataSource } from '../data-source';
import { seedAdmin } from './admin.seed';

/**
 * Orquesta la ejecucion de todos los seeds.
 *
 * Uso: npm run seed
 */
async function main(): Promise<void> {
  console.log('Iniciando seeds de AgroField...\n');

  await AppDataSource.initialize();
  console.log('Conexion a BD establecida\n');

  console.log('-> Seed: Administrador inicial');
  await seedAdmin(AppDataSource);

  // Aqui se agregaran mas seeds en proximos sprints:
  //   await seedMunicipios(AppDataSource);
  //   await seedCultivos(AppDataSource);
  //   await seedReglasAgricolas(AppDataSource);

  await AppDataSource.destroy();
  console.log('\nTodos los seeds completados exitosamente.');
}

main().catch((error: unknown) => {
  console.error('\nError en seeds:', error);
  process.exit(1);
});
