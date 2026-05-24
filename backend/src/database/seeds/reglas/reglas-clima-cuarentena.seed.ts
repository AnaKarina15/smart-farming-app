import { ReglaSeed } from './index';

/**
 * 10 reglas Clima + Cuarentena Fusarium R4T - Sprint 4 AgroField
 * Fuentes: ICA Resoluciones 11912/2019, IDEAM 2026
 */
export const reglasClimaCuarentena: ReglaSeed[] = [
  // ─── FUSARIUM R4T - CUARENTENA OFICIAL MAGDALENA ─────────
  {
    codigo: 'R-CUAR-001',
    nombre: 'Fusarium R4T musáceas - cuarentena oficial Magdalena',
    descripcion:
      'PLAGA CUARENTENARIA. Reportada en Zona Bananera Magdalena 2021. Reportar al ICA OBLIGATORIO.',
    tipoRecomendacion: 'fitosanitario_enfermedad',
    cultivoNombre: 'Banano',
    plagaNombre: 'Fusarium R4T',
    severidadMinima: 'baja',
    accionSugerida:
      'ALERTA MÁXIMA. Reportar INMEDIATAMENTE al ICA (Resolución 11912/2019 - Emergencia fitosanitaria nacional). Aislar plantas. NO movilizar material vegetal. Bioseguridad estricta.',
    metodoAplicacion: 'reporte_+_aislamiento_+_bioseguridad',
    prioridad: 5,
    fuenteCientifica:
      'ICA - Resolución 11912/2019 emergencia fitosanitaria Foc R4T. El Heraldo 2021 cuarentena Magdalena. ICA 17334/2019.',
  },
  {
    codigo: 'R-CUAR-002',
    nombre: 'Fusarium R4T plátano - mismas medidas',
    tipoRecomendacion: 'fitosanitario_enfermedad',
    cultivoNombre: 'Plátano',
    plagaNombre: 'Fusarium R4T',
    severidadMinima: 'baja',
    accionSugerida:
      'Plátano susceptible. Reportar al ICA. Mejorar manejo de suelos (materia orgánica, pH neutro, P-Ca-Mg adecuados reducen riesgo).',
    metodoAplicacion: 'reporte_+_manejo_suelos_supresivos',
    prioridad: 5,
    fuenteCientifica: 'ICA - Plan bioseguridad musáceas R4T. RedAgrícola 2025.',
  },
  {
    codigo: 'R-CUAR-003',
    nombre: 'Bioseguridad predios musáceas Magdalena',
    tipoRecomendacion: 'manejo_cultural',
    cultivoNombre: 'Banano',
    accionSugerida:
      'Pediluvios con amonio cuaternario o yodo. Desinfección de herramientas, vehículos y calzado entre lotes. Control de visitantes. Registros obligatorios ICA.',
    metodoAplicacion: 'desinfeccion_+_control_acceso',
    prioridad: 5,
    fuenteCientifica: 'ICA - Resolución 68180/2020 medidas fitosanitarias Foc R4T.',
  },
  // ─── REGLAS CLIMÁTICAS ─────────
  {
    codigo: 'R-CLIM-001',
    nombre: 'Alerta Fenómeno El Niño Caribe',
    descripcion: 'IDEAM 2026 confirma probabilidad 96% El Niño intenso.',
    tipoRecomendacion: 'transversal',
    estacion: 'seca',
    accionSugerida:
      'ALERTA NIÑO: Reducir áreas de cultivos sensibles a estrés hídrico. Priorizar yuca, sorgo, marañón. Almacenar agua. Mulching obligatorio. Variedades de ciclo corto.',
    prioridad: 5,
    fuenteCientifica: 'IDEAM 2026 - Pronóstico Fenómeno El Niño. Infobae marzo 2026.',
  },
  {
    codigo: 'R-CLIM-002',
    nombre: 'Alerta Fenómeno La Niña (inundaciones)',
    tipoRecomendacion: 'transversal',
    estacion: 'lluviosa',
    accionSugerida:
      'ALERTA NIÑA: Construir/mantener canales de drenaje. Sembrar en camas elevadas. Aplicar fungicidas preventivos. Suspender fertilización foliar.',
    prioridad: 5,
    fuenteCientifica:
      'IDEAM - Pronósticos La Niña Caribe. Semana - Colombia entre El Niño y La Niña.',
  },
  {
    codigo: 'R-CLIM-003',
    nombre: 'Suspender riego antes de lluvia',
    tipoRecomendacion: 'transversal',
    accionSugerida:
      'Si pronóstico >5mm próximas 24h, suspender riego programado. Ahorro hasta 30% de agua y evita encharcamiento.',
    prioridad: 3,
    fuenteCientifica: 'FAO - Eficiencia uso del agua.',
  },
  {
    codigo: 'R-CLIM-004',
    nombre: 'Cortinas rompevientos Caribe',
    tipoRecomendacion: 'manejo_cultural',
    accionSugerida:
      'En zonas con vientos >30 km/h frecuentes, establecer cortinas rompevientos con árboles forestales. Tutorear musáceas y frutales jóvenes.',
    prioridad: 4,
    fuenteCientifica: 'IDEAM - Vientos Alisios Caribe.',
  },
  {
    codigo: 'R-CLIM-005',
    nombre: 'Postergar fumigación con viento >10 km/h',
    tipoRecomendacion: 'transversal',
    accionSugerida:
      'Si viento >10 km/h, postergar aplicación foliar. Hay deriva (pérdida + contaminación cultivos vecinos). Aplicar al amanecer o atardecer.',
    prioridad: 4,
    fuenteCientifica: 'ICA - Buenas prácticas aplicación agroquímicos.',
  },
  {
    codigo: 'R-CLIM-006',
    nombre: 'Análisis pronóstico antes de siembra',
    tipoRecomendacion: 'transversal',
    faseAgronomica: 'preparacion',
    accionSugerida:
      'Consultar boletín agroclimático IDEAM antes de sembrar. Ajustar fecha a inicio de lluvias (abril-mayo o septiembre-octubre).',
    prioridad: 4,
    fuenteCientifica: 'IDEAM - Calendario agroclimático Caribe.',
  },
  {
    codigo: 'R-CLIM-007',
    nombre: 'Heladas Sierra Nevada Magdalena',
    tipoRecomendacion: 'transversal',
    accionSugerida:
      'En zonas altas del Magdalena (>1500 msnm), si pronóstico T<8°C: riego nocturno preventivo, cobertura plástica, hogueras controladas. Atención en café y frutales.',
    prioridad: 4,
    fuenteCientifica: 'FAO - Manejo heladas trópico alto.',
  },
];
