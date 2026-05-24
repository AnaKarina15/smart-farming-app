import { ReglaSeed } from './index';

/**
 * 15 reglas Postcosecha + Trazabilidad - Sprint 4 AgroField
 * Fuentes: ICA Resolución BPA, FAO, UC Davis, CENICAFE, FEDEARROZ
 */
export const reglasPostcosechaTrazabilidad: ReglaSeed[] = [
  // ─── COSECHA Y POSTCOSECHA ─────────
  {
    codigo: 'R-POST-001',
    nombre: 'Cosecha banano verde-maduro',
    tipoRecomendacion: 'manejo_cultural',
    cultivoNombre: 'Banano',
    faseAgronomica: 'cosecha',
    accionSugerida:
      'Cosechar verde-maduro (piel verde pero fisiológicamente maduro). NO cosechar maduro en planta. 10-12 semanas post-embolsado.',
    prioridad: 4,
    fuenteCientifica: 'Wikifarmer - Cosecha banano. UC Davis Postcosecha.',
  },
  {
    codigo: 'R-POST-002',
    nombre: 'Pre-enfriamiento banano <12h',
    tipoRecomendacion: 'manejo_cultural',
    cultivoNombre: 'Banano',
    faseAgronomica: 'post_cosecha',
    accionSugerida:
      'Pre-enfriar dentro de 10-12h post-cosecha. Temperatura óptima 13.7°C. HR 90-95%. Alarga vida útil 2-6 semanas.',
    prioridad: 3,
    fuenteCientifica: 'UC Davis Postharvest - Banano.',
  },
  {
    codigo: 'R-POST-003',
    nombre: 'Almacenamiento plátano 12-16°C',
    tipoRecomendacion: 'manejo_cultural',
    cultivoNombre: 'Plátano',
    faseAgronomica: 'post_cosecha',
    accionSugerida:
      'Almacenar entre 12-16°C, HR 90-95%. Eliminar etileno del ambiente. Atmósferas modificadas prolongan vida útil.',
    prioridad: 3,
    fuenteCientifica: 'AGROSAVIA - Postcosecha plátano. Kader 2002.',
  },
  {
    codigo: 'R-POST-004',
    nombre: 'Cosecha maíz humedad 20-25%',
    tipoRecomendacion: 'manejo_cultural',
    cultivoNombre: 'Maíz',
    faseAgronomica: 'cosecha',
    accionSugerida:
      'Cosechar cuando humedad grano sea 20-25%. Para almacenamiento prolongado secar a 14.5%.',
    prioridad: 4,
    fuenteCientifica: 'Bioproi - Etapas maíz.',
  },
  {
    codigo: 'R-POST-005',
    nombre: 'Cosecha café por color (solo maduros)',
    tipoRecomendacion: 'manejo_cultural',
    cultivoNombre: 'Café',
    faseAgronomica: 'cosecha',
    accionSugerida:
      'Recolectar SOLO frutos maduros (rojo o amarillo según variedad). NO cosechar verdes ni sobremaduros. Pase cada 8-15 días.',
    frecuenciaDias: 12,
    prioridad: 5,
    fuenteCientifica: 'CENICAFE - Cosecha y beneficio del café.',
  },
  {
    codigo: 'R-POST-006',
    nombre: 'Arroz almacenamiento humedad <13%',
    tipoRecomendacion: 'manejo_cultural',
    cultivoNombre: 'Arroz',
    faseAgronomica: 'post_cosecha',
    accionSugerida:
      'Almacenar arroz con humedad <13%. Silo o saco ventilado. T<25°C. Fumigación preventiva contra gorgojo.',
    prioridad: 4,
    fuenteCientifica: 'FEDEARROZ - Almacenamiento arroz.',
  },
  {
    codigo: 'R-POST-007',
    nombre: 'Frutas HR almacenamiento 85-95%',
    tipoRecomendacion: 'manejo_cultural',
    faseAgronomica: 'post_cosecha',
    accionSugerida:
      'Almacenar frutas con HR 85-95%. Bajo de eso, deshidratación irreversible. Por encima, favorece hongos.',
    prioridad: 3,
    fuenteCientifica: 'FAO - Manual postcosecha frutas tropicales.',
  },
  {
    codigo: 'R-POST-008',
    nombre: 'Triple lavado producto fresco',
    tipoRecomendacion: 'manejo_cultural',
    faseAgronomica: 'post_cosecha',
    accionSugerida:
      'Lavar producto fresco con agua potable antes de empaque. Para exportación, segundo lavado con hipoclorito 50ppm.',
    prioridad: 4,
    fuenteCientifica: 'ICA - Resolución BPA frutas hortalizas frescas.',
  },
  // ─── TRAZABILIDAD Y SEGURIDAD ─────────
  {
    codigo: 'R-TRZ-001',
    nombre: 'Registro obligatorio aplicaciones (BPA)',
    tipoRecomendacion: 'transversal',
    accionSugerida:
      'Registrar TODA aplicación: producto, dosis, fecha, hora, operador, condiciones climáticas. Conservar 2 años. Obligatorio BPA.',
    prioridad: 5,
    fuenteCientifica: 'ICA - Resolución 30021/2017 BPA. GlobalGAP.',
  },
  {
    codigo: 'R-TRZ-002',
    nombre: 'Período de carencia obligatorio (PHI)',
    tipoRecomendacion: 'transversal',
    accionSugerida:
      'Respetar PHI de cada producto antes de cosecha. Cosechar antes del PHI deja residuos sobre LMR = producto NO comercializable.',
    prioridad: 5,
    fuenteCientifica: 'ICA - Resoluciones LMR Colombia.',
  },
  {
    codigo: 'R-TRZ-003',
    nombre: 'Análisis de residuos pre-exportación',
    tipoRecomendacion: 'transversal',
    faseAgronomica: 'cosecha',
    accionSugerida:
      'Para exportación, análisis de residuos en lab acreditado. LMR debe cumplir norma país destino (UE más estricta).',
    prioridad: 4,
    fuenteCientifica: 'ICA - Exportación frutas hortalizas.',
  },
  {
    codigo: 'R-TRZ-004',
    nombre: 'Prueba de compatibilidad en mezcla',
    tipoRecomendacion: 'transversal',
    accionSugerida:
      'Antes de mezclar 2 productos en tanque, prueba de miscibilidad. Mezclas incompatibles son fitotóxicas o anulan eficacia.',
    prioridad: 5,
    fuenteCientifica: 'CropLife Latam - Compatibilidad agroquímicos.',
  },
  {
    codigo: 'R-TRZ-005',
    nombre: 'Disposición envases (CampoLimpio)',
    tipoRecomendacion: 'transversal',
    accionSugerida:
      'Triple lavado del envase. NO reutilizar para agua/alimentos. Entregar al programa CampoLimpio del gremio.',
    prioridad: 5,
    fuenteCientifica: 'Programa CampoLimpio - ANDI/ICA.',
  },
  {
    codigo: 'R-TRZ-006',
    nombre: 'Granizo: mallas protección frutales',
    tipoRecomendacion: 'transversal',
    accionSugerida:
      'En zonas con histórico de granizo, instalar mallas anti-granizo en cultivos alto valor (mango, aguacate, hortalizas). Daño granizo puede ser total.',
    prioridad: 3,
    fuenteCientifica: 'FAO - Manejo riesgos climáticos.',
  },
  {
    codigo: 'R-TRZ-007',
    nombre: 'Análisis de suelo cada 2 años',
    tipoRecomendacion: 'transversal',
    accionSugerida:
      'Programar análisis de suelo cada 730 días. Ajustar plan de fertilización a condiciones reales del lote.',
    frecuenciaDias: 730,
    prioridad: 3,
    fuenteCientifica: 'Buenas prácticas agronómicas - AGROSAVIA/ICA.',
  },
];
