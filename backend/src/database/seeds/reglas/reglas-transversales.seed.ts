import { ReglaSeed } from './index';

/**
 * 10 reglas TRANSVERSALES (no atadas a un cultivo especifico) - Sprint 4 AgroField
 * Fuentes: ICA, FAO, CropLife, Programa CampoLimpio
 */
export const reglasTransversales: ReglaSeed[] = [
  {
    codigo: 'R-GEN-001',
    nombre: 'No regar foliar en mediodia solar',
    descripcion: 'Riego entre 11am-2pm causa quemado de hojas.',
    tipoRecomendacion: 'transversal',
    accionSugerida:
      'NO aplicar riego foliar entre 11am-2pm. Quemado de hojas y baja eficiencia. Regar temprano (5-8am) o tarde (4-6pm).',
    prioridad: 3,
    fuenteCientifica: 'FAO - Buenas practicas riego tropico.',
  },
  {
    codigo: 'R-GEN-002',
    nombre: 'No aplicar foliar antes de lluvia',
    descripcion: 'La lluvia lavara el producto, reduciendo eficacia >70%.',
    tipoRecomendacion: 'transversal',
    accionSugerida:
      'Posponer aplicacion de fungicida/insecticida foliar si hay pronostico de lluvia en proximas 4 horas. La lluvia lavara el producto, reduciendo eficacia >70%.',
    prioridad: 4,
    fuenteCientifica: 'ICA - Buenas practicas aplicacion agroquimicos.',
  },
  {
    codigo: 'R-GEN-003',
    nombre: 'Respetar periodo de carencia pre-cosecha',
    descripcion: 'Aplicar dentro del periodo de carencia deja residuos sobre LMR.',
    tipoRecomendacion: 'transversal',
    accionSugerida:
      'ALERTA: no aplicar este producto si los dias hasta cosecha esperada estan dentro del periodo de carencia. Dejara residuos sobre el LMR permitido.',
    prioridad: 5,
    fuenteCientifica: 'ICA - Resoluciones registros plaguicidas (LMR).',
  },
  {
    codigo: 'R-GEN-004',
    nombre: 'Rotacion de modos de accion (anti-resistencia)',
    tipoRecomendacion: 'transversal',
    accionSugerida:
      'Rotar modo de accion del producto. La aplicacion repetida del mismo ingrediente activo genera resistencia (caso documentado en Sigatoka triazoles y Spodoptera piretroides).',
    prioridad: 4,
    fuenteCientifica:
      'Manejo resistencia fungicidas zona bananera Magdalena (Musalit). CropLife - Manejo resistencia.',
  },
  {
    codigo: 'R-GEN-005',
    nombre: 'Categoria toxicologica I no recomendada',
    tipoRecomendacion: 'transversal',
    accionSugerida:
      'Buscar alternativa de menor toxicidad (categoria III-IV) o control biologico. Solo recomendar Cat I como ultima opcion y con EPI completo.',
    prioridad: 5,
    fuenteCientifica: 'ICA - Clasificacion toxicologica plaguicidas.',
  },
  {
    codigo: 'R-GEN-006',
    nombre: 'Usar EPI siempre al aplicar agroquimico',
    descripcion: 'Equipo de Proteccion Individual obligatorio.',
    tipoRecomendacion: 'transversal',
    accionSugerida:
      'Usar EPI: guantes nitrilo, gafas, mascara con filtro de vapores organicos, overol y botas. NO aplicar con viento fuerte ni en contra del viento.',
    prioridad: 5,
    fuenteCientifica: 'ICA-SAC - Cartilla seguridad en aplicacion agroquimicos.',
  },
  {
    codigo: 'R-GEN-007',
    nombre: 'Triple lavado de envases',
    tipoRecomendacion: 'transversal',
    accionSugerida:
      'Realizar triple lavado del envase. Disponer en programa CampoLimpio del gremio.',
    prioridad: 4,
    fuenteCientifica: 'Programa CampoLimpio - ANDI / ICA.',
  },
  {
    codigo: 'R-GEN-008',
    nombre: 'Analisis de suelo cada 2 anios',
    tipoRecomendacion: 'transversal',
    accionSugerida:
      'Programar analisis de suelo para ajustar plan de fertilizacion a las condiciones reales del lote.',
    frecuenciaDias: 730,
    prioridad: 3,
    fuenteCientifica: 'Buenas practicas agronomicas - AGROSAVIA / ICA.',
  },
  {
    codigo: 'R-GEN-009',
    nombre: 'Alerta de baja temperatura (zonas altas)',
    descripcion: 'Aplica solo en zonas altas del Magdalena, no en costa.',
    tipoRecomendacion: 'transversal',
    accionSugerida:
      'Riego nocturno preventivo si pronostico de temperatura < 5°C en proximas 12h. (Aplica solo en zonas altas del Magdalena, no en costa).',
    prioridad: 4,
    fuenteCientifica: 'FAO - Manejo de heladas tropico alto.',
  },
  {
    codigo: 'R-GEN-010',
    nombre: 'Documentar todas las labores en AgroField',
    descripcion: 'La trazabilidad es clave para certificaciones GAP.',
    tipoRecomendacion: 'transversal',
    accionSugerida:
      'Registrar en AgroField: fecha, producto, dosis, lote, condiciones. La trazabilidad es clave para certificaciones GAP y para detectar problemas a tiempo.',
    prioridad: 3,
    fuenteCientifica: 'ICA - Resolucion BPA. GlobalGAP - Trazabilidad.',
  },
];
