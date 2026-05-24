import { ReglaSeed } from './index';

/**
 * 6 reglas Tipos de Suelo - Sprint 4 AgroField
 * Fuentes: ICA cartillas, AGROSAVIA, Larrosa Arnal
 */
export const reglasSuelos: ReglaSeed[] = [
  {
    codigo: 'R-SUEL-001',
    nombre: 'Suelo arcilloso: drenaje obligatorio',
    tipoRecomendacion: 'manejo_cultural',
    tipoSueloNombre: 'Arcilloso',
    accionSugerida:
      'Suelo arcilloso retiene mucha agua, drenaje lento. Canales de drenaje obligatorios. Incorporar materia orgánica. Evitar laboreo húmedo.',
    prioridad: 4,
    fuenteCientifica: 'Larrosa Arnal - Suelos arcillosos. ICA cartilla suelos.',
  },
  {
    codigo: 'R-SUEL-002',
    nombre: 'Suelo arenoso: riego y fertilización frecuente',
    tipoRecomendacion: 'manejo_cultural',
    tipoSueloNombre: 'Arenoso',
    accionSugerida:
      'Suelo arenoso drena rápido, retiene poco. Riego más frecuente, menor volumen. Fertilización fraccionada. Mulching obligatorio.',
    prioridad: 4,
    fuenteCientifica: 'Bioactivador - Suelos agrícolas tipos.',
  },
  {
    codigo: 'R-SUEL-003',
    nombre: 'Suelo franco: el ideal (mantener)',
    tipoRecomendacion: 'manejo_cultural',
    tipoSueloNombre: 'Franco',
    accionSugerida:
      'Suelo franco (40% arena + 40% limo + 20% arcilla) es ideal. Mantener materia orgánica >3%. Rotación para preservar fertilidad.',
    prioridad: 2,
    fuenteCientifica: 'Hortalan - Suelos francos agrícolas.',
  },
  {
    codigo: 'R-SUEL-004',
    nombre: 'Suelo franco arcilloso: balance moderado',
    tipoRecomendacion: 'manejo_cultural',
    tipoSueloNombre: 'Franco Arcilloso',
    accionSugerida:
      'Franco arcilloso: buena retención de nutrientes, drenaje moderado. Manejar materia orgánica para mantener estructura.',
    prioridad: 3,
    fuenteCientifica: 'JardineriaOn - Subtipos suelos francos.',
  },
  {
    codigo: 'R-SUEL-005',
    nombre: 'Suelo franco arenoso: ideal para hortalizas',
    tipoRecomendacion: 'manejo_cultural',
    tipoSueloNombre: 'Franco Arenoso',
    accionSugerida:
      'Franco arenoso: drenaje rápido y buena aireación. Excelente para hortalizas, tomate, cucurbitáceas. Reponer materia orgánica regularmente.',
    prioridad: 2,
    fuenteCientifica: 'Larrosa Arnal - Suelos francos arenosos.',
  },
  {
    codigo: 'R-SUEL-006',
    nombre: 'Suelo limoso: evitar compactación',
    tipoRecomendacion: 'manejo_cultural',
    tipoSueloNombre: 'Limoso',
    accionSugerida:
      'Suelo limoso se compacta fácil. Evitar maquinaria pesada cuando húmedo. Materia orgánica abundante. Subsolar inicio de ciclo.',
    prioridad: 3,
    fuenteCientifica: 'JardineriaOn - Suelo franco-limoso.',
  },
];
