import { DataSource } from 'typeorm';

import { Regla } from '../../../modules/recomendaciones/entities/regla.entity';

import { reglasEnfermedades } from './reglas-enfermedades.seed';
import { reglasFertilizacion } from './reglas-fertilizacion.seed';
import { reglasManejo } from './reglas-manejo.seed';
import { reglasPlagas } from './reglas-plagas.seed';
import { reglasRiego } from './reglas-riego.seed';
import { reglasTransversales } from './reglas-transversales.seed';
// ─── Ampliación Sprint 4 ─────────────────────────────────
import { reglasName } from './reglas-name.seed';
import { reglasCacao } from './reglas-cacao.seed';
import { reglasFrijol } from './reglas-frijol.seed';
import { reglasAguacate } from './reglas-aguacate.seed';
import { reglasCucurbitaceas } from './reglas-cucurbitaceas.seed';
import { reglasOtrosFrutales } from './reglas-otros-frutales.seed';
import { reglasSorgoPastosHortalizas } from './reglas-sorgo-pastos-hortalizas.seed';
import { reglasClimaCuarentena } from './reglas-clima-cuarentena.seed';
import { reglasPostcosechaTrazabilidad } from './reglas-postcosecha-trazabilidad.seed';
import { reglasSuelos } from './reglas-suelos.seed';
import { reglasArrozAdicional } from './reglas-arroz-adicional.seed';

/**
 * Tipo del registro de regla a seedear.
 * Igual que Regla pero sin id/timestamps (se autogeneran).
 * Los campos FK se resuelven en runtime: en lugar de pasar UUIDs,
 * se pasa el "nombre" del cultivo/plaga/etc. y aqui lo resolvemos.
 */
export type ReglaSeed = {
  codigo: string;
  nombre: string;
  descripcion?: string | null;
  tipoRecomendacion: string;

  // FK lookups por nombre
  cultivoNombre?: string;
  plagaNombre?: string;
  tipoSueloNombre?: string;
  fertilizanteNombre?: string;

  // Condiciones IF
  faseAgronomica?: string | null;
  severidadMinima?: string | null;
  estacion?: string | null;
  diasSinRiegoMinimo?: number | null;
  diasDesdeSiembraMinimo?: number | null;
  diasDesdeSiembraMaximo?: number | null;
  humedadMaxima?: number | null;
  humedadMinima?: number | null;

  // Accion THEN
  accionSugerida: string;
  productoSugerido?: string | null;
  dosisRecomendada?: number | null;
  unidadRecomendada?: string | null;
  metodoAplicacion?: string | null;
  frecuenciaDias?: number | null;

  // Metadatos
  prioridad: number;
  fuenteCientifica: string;
  notas?: string | null;
};

/**
 * Seed maestro de reglas agronomicas del Magdalena (Sprint 4).
 *
 * Carga 80 reglas reales con fuentes oficiales:
 * - ICA, AGROSAVIA, FAO, CENICAFE, CENIPALMA, CIAT
 * - Casas comerciales con Reg. ICA (ADAMA, BASF, Bayer)
 *
 * Idempotente: si una regla con el mismo codigo ya existe, no se duplica.
 * Resuelve FKs por nombre (cultivo, plaga, etc.) consultando los catalogos.
 */
export async function seedReglasAgricolas(dataSource: DataSource): Promise<void> {
  const reglaRepo = dataSource.getRepository(Regla);

  // Concatenar todas las reglas
  const todasLasReglas: ReglaSeed[] = [
    // Iniciales (70)
    ...reglasRiego,
    ...reglasFertilizacion,
    ...reglasPlagas,
    ...reglasEnfermedades,
    ...reglasManejo,
    ...reglasTransversales,
    // Ampliación Sprint 4 (117)
    ...reglasName,
    ...reglasCacao,
    ...reglasFrijol,
    ...reglasAguacate,
    ...reglasCucurbitaceas,
    ...reglasOtrosFrutales,
    ...reglasSorgoPastosHortalizas,
    ...reglasClimaCuarentena,
    ...reglasPostcosechaTrazabilidad,
    ...reglasSuelos,
    ...reglasArrozAdicional,
  ];

  console.log(`  Total reglas a procesar: ${todasLasReglas.length}`);

  // Cargar catalogos en memoria (lookup rapido por nombre)
  const cultivos = await dataSource.query(
    `SELECT id, nombre FROM cultivos WHERE "deletedAt" IS NULL`,
  );
  const plagas = await dataSource.query(`SELECT id, nombre FROM plagas WHERE "deletedAt" IS NULL`);
  const tiposSuelo = await dataSource.query(
    `SELECT id, nombre FROM tipos_suelo WHERE "deletedAt" IS NULL`,
  );
  const fertilizantes = await dataSource.query(
    `SELECT id, nombre FROM fertilizantes WHERE "deletedAt" IS NULL`,
  );

  const buscarId = (
    lista: Array<{ id: string; nombre: string }>,
    nombre?: string,
  ): string | null => {
    if (!nombre) return null;
    // Match flexible: insensible a mayusculas/acentos basicos
    const norm = (s: string) =>
      s
        .toLowerCase()
        .normalize('NFD')
        .replace(/[\u0300-\u036f]/g, '');
    const target = norm(nombre);
    const found = lista.find((item) => norm(item.nombre) === target);
    return found?.id ?? null;
  };

  let creadas = 0;
  let actualizadas = 0;
  let conAdvertencia = 0;

  for (const seed of todasLasReglas) {
    // Resolver FKs por nombre
    const cultivoId = buscarId(cultivos, seed.cultivoNombre);
    const plagaId = buscarId(plagas, seed.plagaNombre);
    const tipoSueloId = buscarId(tiposSuelo, seed.tipoSueloNombre);
    const fertilizanteSugeridoId = buscarId(fertilizantes, seed.fertilizanteNombre);

    // Advertencias si se pidio FK pero no se encontro
    if (seed.cultivoNombre && !cultivoId) {
      console.warn(`  [${seed.codigo}] Cultivo "${seed.cultivoNombre}" no encontrado`);
      conAdvertencia++;
    }
    if (seed.plagaNombre && !plagaId) {
      console.warn(`  [${seed.codigo}] Plaga "${seed.plagaNombre}" no encontrada`);
      conAdvertencia++;
    }

    const existente = await reglaRepo.findOne({ where: { codigo: seed.codigo } });

    const datos = {
      codigo: seed.codigo,
      nombre: seed.nombre,
      descripcion: seed.descripcion ?? null,
      tipoRecomendacion: seed.tipoRecomendacion as any,
      cultivoId,
      plagaId,
      tipoSueloId,
      fertilizanteSugeridoId,
      faseAgronomica: (seed.faseAgronomica ?? null) as any,
      severidadMinima: seed.severidadMinima ?? null,
      estacion: (seed.estacion ?? null) as any,
      diasSinRiegoMinimo: seed.diasSinRiegoMinimo ?? null,
      diasDesdeSiembraMinimo: seed.diasDesdeSiembraMinimo ?? null,
      diasDesdeSiembraMaximo: seed.diasDesdeSiembraMaximo ?? null,
      humedadMaxima: seed.humedadMaxima ?? null,
      humedadMinima: seed.humedadMinima ?? null,
      accionSugerida: seed.accionSugerida,
      productoSugerido: seed.productoSugerido ?? null,
      dosisRecomendada: seed.dosisRecomendada ?? null,
      unidadRecomendada: seed.unidadRecomendada ?? null,
      metodoAplicacion: seed.metodoAplicacion ?? null,
      frecuenciaDias: seed.frecuenciaDias ?? null,
      prioridad: seed.prioridad,
      fuenteCientifica: seed.fuenteCientifica,
      activa: true,
      notas: seed.notas ?? null,
    };

    if (existente) {
      // Actualizar campos por si la regla cambio (sin tocar createdAt)
      Object.assign(existente, datos);
      await reglaRepo.save(existente);
      actualizadas++;
    } else {
      const nueva = reglaRepo.create(datos);
      await reglaRepo.save(nueva);
      creadas++;
    }
  }

  console.log(`  -> ${creadas} reglas creadas`);
  console.log(`  -> ${actualizadas} reglas actualizadas`);
  if (conAdvertencia > 0) {
    console.log(`  -> ${conAdvertencia} advertencias (FKs no resueltas)`);
  }
}
