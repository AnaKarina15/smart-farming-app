import { ReglaSeed } from './index';

/**
 * 12 reglas Marañón, Papaya, Cítricos - Sprint 4 AgroField
 * Fuentes: AGROSAVIA Caribia Magdalena, ICA, CropLife, Casafe, Intagri
 */
export const reglasOtrosFrutales: ReglaSeed[] = [
  // ─── MARAÑÓN (asociado a Mango porque comparten familia Anacardiaceae) ─────────
  {
    codigo: 'R-MARA-001',
    nombre: 'Leptoglossus zonatus marañón/mango Magdalena',
    tipoRecomendacion: 'fitosanitario_plaga',
    cultivoNombre: 'Mango',
    plagaNombre: 'Leptoglossus zonatus',
    severidadMinima: 'media',
    accionSugerida:
      'Artrópodo más relevante en marañón del Magdalena. Monitoreo en frutos. Lambda-cyhalothrin si severidad alta.',
    productoSugerido: 'Lambda-cyhalothrin',
    dosisRecomendada: 250,
    unidadRecomendada: 'cc/ha',
    metodoAplicacion: 'aspersion_foliar',
    prioridad: 4,
    fuenteCientifica: 'AGROSAVIA Caribia Zona Bananera Magdalena 2023 - Inventario plagas marañón.',
  },
  {
    codigo: 'R-MARA-002',
    nombre: 'Antracnosis marañón/mango (más grave)',
    descripcion: 'Problema más serio durante floración y cuajado de frutos.',
    tipoRecomendacion: 'fitosanitario_enfermedad',
    cultivoNombre: 'Mango',
    plagaNombre: 'Antracnosis',
    severidadMinima: 'media',
    faseAgronomica: 'floracion',
    accionSugerida:
      'Fungicida cúprico preventivo. Iniciar cuando panículos tengan 1 pulgada y continuar semanalmente hasta 3-4 semanas post-cuajado.',
    productoSugerido: 'Oxicloruro de cobre',
    dosisRecomendada: 3,
    unidadRecomendada: 'kg/ha',
    metodoAplicacion: 'aspersion_foliar',
    frecuenciaDias: 7,
    prioridad: 5,
    fuenteCientifica: 'AGROSAVIA Caribia Magdalena 2023. UF/IFAS Marañón Florida.',
  },
  {
    codigo: 'R-MARA-003',
    nombre: 'Mildeo polvoso marañón',
    tipoRecomendacion: 'fitosanitario_enfermedad',
    cultivoNombre: 'Mango',
    severidadMinima: 'media',
    accionSugerida: 'Aplicar azufre o triazol. Síntomas iniciales en envés de hojas.',
    productoSugerido: 'Azufre micronizado',
    dosisRecomendada: 3,
    unidadRecomendada: 'kg/ha',
    metodoAplicacion: 'aspersion_foliar',
    prioridad: 3,
    fuenteCientifica: 'AGROSAVIA Editorial - Insectos, ácaros y enfermedades marañón.',
  },
  // ─── PAPAYA (asociada a Mango por falta de cultivo específico en BD) ─────────
  // NOTA: Como no hay "Papaya" en catálogo cultivos, estas reglas se asocian a Mango
  // o se mantienen como reglas generales (sin cultivoId). Recomendación: agregar Papaya al catálogo.
  {
    codigo: 'R-PAPA-001',
    nombre: 'Virus mancha anular papaya (PRSV)',
    descripcion: 'Imposible detener una vez establecida. Hasta 100% pérdidas en regiones.',
    tipoRecomendacion: 'fitosanitario_enfermedad',
    plagaNombre: 'PRSV',
    severidadMinima: 'baja',
    accionSugerida:
      'NO hay control químico. Eliminar hojas amarillas semanalmente (atraen vectores). Eliminar plantas infectadas. Usar variedades tolerantes.',
    metodoAplicacion: 'cultural_+_erradicacion',
    frecuenciaDias: 7,
    prioridad: 5,
    fuenteCientifica: 'ICA - Programa frutales. SlideShare 2019 Manejo PRSV papaya.',
  },
  {
    codigo: 'R-PAPA-002',
    nombre: 'Mosca de la fruta papaya (Anastrepha)',
    tipoRecomendacion: 'fitosanitario_plaga',
    severidadMinima: 'media',
    accionSugerida:
      'Trampas McPhail con cebo proteínico. Embolsado de frutos. Recogida de frutos caídos.',
    productoSugerido: 'Trampa McPhail',
    dosisRecomendada: 1,
    unidadRecomendada: 'trampa/ha',
    metodoAplicacion: 'trampeo_+_cultural',
    prioridad: 4,
    fuenteCientifica: 'Wikifarmer - Plagas papaya. AGROSAVIA papaya.',
  },
  {
    codigo: 'R-PAPA-003',
    nombre: 'Hojas amarillas papaya - deshoje semanal',
    tipoRecomendacion: 'manejo_cultural',
    accionSugerida:
      'Eliminar hojas amarillas semanalmente. Atraen áfidos, moscas blancas y chinches (vectores de PRSV). Trabajos Cuba confirman menor incidencia con deshoje.',
    frecuenciaDias: 7,
    prioridad: 4,
    fuenteCientifica: 'SlideShare - Manejo PRSV papaya. Cuba 2018.',
  },
  // ─── CÍTRICOS (sin cultivo específico en BD - reglas generales) ─────────
  {
    codigo: 'R-CITR-001',
    nombre: 'HLB cítricos (Huanglongbing - dragón amarillo)',
    descripcion: 'Enfermedad más grave de la citricultura mundial.',
    tipoRecomendacion: 'fitosanitario_enfermedad',
    plagaNombre: 'HLB',
    severidadMinima: 'baja',
    accionSugerida:
      'NO hay cura. Eliminar árboles afectados. Control intensivo del vector (Diaphorina citri). Reportar al ICA. Plantas certificadas únicamente.',
    metodoAplicacion: 'erradicacion_+_control_vector',
    prioridad: 5,
    fuenteCientifica: 'CropLife Latam - Dragón Amarillo HLB. ICA - Plan regional HLB.',
  },
  {
    codigo: 'R-CITR-002',
    nombre: 'Diaphorina citri (vector HLB)',
    tipoRecomendacion: 'fitosanitario_plaga',
    plagaNombre: 'Diaphorina citri',
    severidadMinima: 'baja',
    accionSugerida:
      'Monitoreo intensivo en brotes tiernos. Aplicación de insecticida sistémico. Eliminación de Murraya paniculata (hospedero alternativo).',
    productoSugerido: 'Imidacloprid sistémico',
    dosisRecomendada: 250,
    unidadRecomendada: 'cc/ha',
    metodoAplicacion: 'aspersion_+_sistemico',
    frecuenciaDias: 30,
    prioridad: 5,
    fuenteCientifica: 'Intagri - Control HLB cítricos. INIFAP México 2013.',
  },
  {
    codigo: 'R-CITR-003',
    nombre: 'Minador hojas cítricos (Phyllocnistis)',
    tipoRecomendacion: 'fitosanitario_plaga',
    severidadMinima: 'media',
    accionSugerida:
      'Aplicación en flujos vegetativos (brotes nuevos). Aceite mineral + Imidacloprid.',
    productoSugerido: 'Aceite mineral + Imidacloprid',
    dosisRecomendada: 1,
    unidadRecomendada: 'L aceite + 250 cc imidacloprid/ha',
    metodoAplicacion: 'aspersion_brotes_nuevos',
    prioridad: 3,
    fuenteCientifica: 'Casafe - Cuidado cítricos HLB.',
  },
  {
    codigo: 'R-CITR-004',
    nombre: 'Ácaros cítricos (Panonychus, Tetranychus)',
    tipoRecomendacion: 'fitosanitario_plaga',
    severidadMinima: 'media',
    estacion: 'seca',
    accionSugerida:
      'Liberación de ácaros depredadores (Phytoseiulus). Si severidad crítica, acaricida selectivo (Abamectina).',
    productoSugerido: 'Phytoseiulus persimilis o Abamectina',
    dosisRecomendada: 0.4,
    unidadRecomendada: 'L/ha (abamectina)',
    metodoAplicacion: 'biologico_+_selectivo',
    prioridad: 3,
    fuenteCientifica: 'Portal Frutícola - Guía cítricos.',
  },
  {
    codigo: 'R-CITR-005',
    nombre: 'Mancha grasienta cítricos (Mycosphaerella)',
    tipoRecomendacion: 'fitosanitario_enfermedad',
    severidadMinima: 'media',
    estacion: 'lluviosa',
    accionSugerida:
      'Aspersión con sulfato de cobre tribásico. Recolección de hojas caídas (reduce inóculo).',
    productoSugerido: 'Sulfato de cobre tribásico',
    dosisRecomendada: 3,
    unidadRecomendada: 'kg/ha',
    metodoAplicacion: 'aspersion_foliar',
    prioridad: 3,
    fuenteCientifica: 'Orozco-Santos 2001 - Enfermedades cítricos México.',
  },
  {
    codigo: 'R-MARA-004',
    nombre: 'Marañón rusticidad suelos secos',
    tipoRecomendacion: 'manejo_cultural',
    cultivoNombre: 'Mango',
    accionSugerida:
      'Marañón se adapta excelente a suelos ácidos de baja fertilidad y climas secos del Caribe. Riego mínimo, fertilización moderada.',
    prioridad: 3,
    fuenteCientifica: 'AGROSAVIA - Marañón Orinoquía y Caribe.',
  },
];
