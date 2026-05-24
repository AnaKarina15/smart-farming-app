import { ReglaSeed } from './index';

/**
 * 10 reglas de MANEJO CULTURAL - Sprint 4 AgroField
 * Fuentes: ICA, AGROSAVIA, CENICAFE, CENIBANANO, MAG Costa Rica
 */
export const reglasManejo: ReglaSeed[] = [
  {
    codigo: 'R-MANEJO-001',
    nombre: 'Rotacion de cultivos para sanidad',
    descripcion: 'Despues de 2 ciclos consecutivos rotar con leguminosa.',
    tipoRecomendacion: 'manejo_cultural',
    cultivoNombre: 'Maíz',
    faseAgronomica: 'post_cosecha',
    accionSugerida:
      'Rotar con leguminosa (frijol, soya) para reducir Spodoptera y fijar nitrogeno. Despues de 2 ciclos del mismo cultivo.',
    prioridad: 3,
    fuenteCientifica: 'ICA - Manejo Integrado de Plagas (MIP).',
  },
  {
    codigo: 'R-MANEJO-002',
    nombre: 'Eliminacion malezas hospederas pre-siembra',
    tipoRecomendacion: 'manejo_cultural',
    cultivoNombre: 'Maíz',
    faseAgronomica: 'preparacion',
    accionSugerida:
      'Eliminar malezas hospederas de gusano cogollero al menos 30 dias antes de siembra.',
    prioridad: 4,
    fuenteCientifica: 'ICA-CIMMYT - Control gusano cogollero.',
  },
  {
    codigo: 'R-MANEJO-003',
    nombre: 'Densidad de siembra banano',
    tipoRecomendacion: 'manejo_cultural',
    cultivoNombre: 'Banano',
    faseAgronomica: 'preparacion',
    accionSugerida:
      'Densidad de 1500-1700 plantas/ha. Cuadro 2x3 m o triangulo para optimo desarrollo.',
    dosisRecomendada: 1600,
    unidadRecomendada: 'plantas/ha',
    prioridad: 3,
    fuenteCientifica: 'MAG Costa Rica - Ficha tecnica banano. Cenibanano.',
  },
  {
    codigo: 'R-MANEJO-004',
    nombre: 'Densidad de siembra maiz Magdalena',
    tipoRecomendacion: 'manejo_cultural',
    cultivoNombre: 'Maíz',
    faseAgronomica: 'preparacion',
    accionSugerida:
      'Densidad de 50000-60000 plantas/ha en clima calido del Magdalena. Distancia: 0.80 m entre surcos, 0.20 m entre plantas.',
    dosisRecomendada: 55000,
    unidadRecomendada: 'plantas/ha',
    prioridad: 3,
    fuenteCientifica: 'AGROSAVIA - Manual maiz Caribe colombiano.',
  },
  {
    codigo: 'R-MANEJO-005',
    nombre: 'Encalado suelos acidos',
    descripcion: 'Aplicar cal agricola si pH < 5.5.',
    tipoRecomendacion: 'manejo_cultural',
    accionSugerida:
      'Aplicar cal agricola (calcita o dolomita) 1-2 ton/ha 1-2 meses antes de fertilizacion en suelos con pH < 5.5.',
    productoSugerido: 'Cal agricola (calcita o dolomita)',
    dosisRecomendada: 1.5,
    unidadRecomendada: 'ton/ha',
    metodoAplicacion: 'edafica_incorporada',
    prioridad: 3,
    fuenteCientifica: 'ICA - Encalado suelos acidos cartilla.',
  },
  {
    codigo: 'R-MANEJO-006',
    nombre: 'Mulching para conservar humedad',
    tipoRecomendacion: 'manejo_cultural',
    estacion: 'seca',
    accionSugerida:
      'Aplicar mulching (cobertura vegetal) para conservar humedad y reducir evaporacion.',
    prioridad: 3,
    fuenteCientifica: 'ICA-SAC - Cartilla buenas practicas agricolas.',
  },
  {
    codigo: 'R-MANEJO-007',
    nombre: 'Regulacion del sombrio cafe (30-40%)',
    tipoRecomendacion: 'manejo_cultural',
    cultivoNombre: 'Café',
    accionSugerida:
      'Regular sombrio entre 30-40% para reducir enfermedades foliares y mejorar productividad.',
    prioridad: 3,
    fuenteCientifica: 'CENICAFE - Manejo sombrio cafe.',
  },
  {
    codigo: 'R-MANEJO-008',
    nombre: 'Drenaje banano en zona inundable',
    descripcion: 'El banano no tolera encharcamiento >48h.',
    tipoRecomendacion: 'manejo_cultural',
    cultivoNombre: 'Banano',
    estacion: 'lluviosa',
    accionSugerida:
      'Construir canales de drenaje cada 30-50 m. El banano no tolera encharcamiento >48h.',
    prioridad: 4,
    fuenteCientifica: 'ICA - Manejo banano temporada invernal.',
  },
  {
    codigo: 'R-MANEJO-009',
    nombre: 'Deshije banano (3 plantas/sitio)',
    tipoRecomendacion: 'manejo_cultural',
    cultivoNombre: 'Banano',
    accionSugerida: 'Deshije manteniendo solo 3 plantas/sitio (madre + hijo + nieto).',
    prioridad: 3,
    fuenteCientifica: 'CENIBANANO - Practicas deshije.',
  },
  {
    codigo: 'R-MANEJO-010',
    nombre: 'Desbasure de hojas con sigatoka',
    descripcion: 'Eliminar hojas con sigatoka avanzada para reducir inoculo.',
    tipoRecomendacion: 'manejo_cultural',
    cultivoNombre: 'Banano',
    accionSugerida:
      'Eliminar hojas con sigatoka avanzada (>50% area). Reduce inoculo y mejora aireacion. Llevar fuera del lote.',
    prioridad: 4,
    fuenteCientifica: 'AGROSAVIA - Manejo cultural sigatoka.',
  },
];
