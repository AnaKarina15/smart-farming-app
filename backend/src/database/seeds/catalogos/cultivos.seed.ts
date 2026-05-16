import { DataSource } from 'typeorm';

import { Cultivo } from '../../../modules/catalogos/entities/cultivo.entity';

/**
 * Seed de cultivos representativos del Magdalena.
 *
 * Fuentes:
 * - Federación Nacional de Productores de Panela (Fedepanela)
 * - Fenalce (cereales)
 * - Augura (banano)
 * - Cenicafé (café)
 * - ICA - Diagnóstico agricola Magdalena 2024
 *
 * Se incluyen los cultivos predominantes:
 *  - Banano y Palma (zona bananera y norte)
 *  - Maiz, Yuca, Platano (pequeños productores en todo el departamento)
 *  - Frutales (Mango, Aguacate, Patilla, Ahuyama)
 *  - Comerciales (Cacao, Cafe en Sierra Nevada)
 *  - Leguminosas (Frijol)
 *  - Forraje (Pasto Angleton, Brachiaria)
 */
export async function seedCultivos(dataSource: DataSource): Promise<void> {
  const repo = dataSource.getRepository(Cultivo);

  const cultivos: Array<Partial<Cultivo>> = [
    // ─── CEREALES ──────────────────────────────────────────
    {
      nombre: 'Maíz',
      nombreCientifico: 'Zea mays',
      categoria: 'cereal',
      cicloVegetativo: 'transitorio',
      diasCosecha: 120,
      densidadSiembraPorHa: 55000,
      descripcion:
        'Cereal de grano amarillo o blanco, base alimentaria del campesino. Adaptado a tierras calidas del Magdalena. Siembra en epoca de lluvias (abril-mayo y septiembre-octubre).',
    },
    {
      nombre: 'Arroz',
      nombreCientifico: 'Oryza sativa',
      categoria: 'cereal',
      cicloVegetativo: 'transitorio',
      diasCosecha: 130,
      densidadSiembraPorHa: 120,
      descripcion:
        'Cereal de inundacion. Importante en zonas del rio y Cienaga Grande. Densidad expresada en kg de semilla por hectarea.',
    },
    {
      nombre: 'Sorgo',
      nombreCientifico: 'Sorghum bicolor',
      categoria: 'cereal',
      cicloVegetativo: 'transitorio',
      diasCosecha: 110,
      densidadSiembraPorHa: 175000,
      descripcion:
        'Cereal resistente a sequia, ideal para zonas con periodos secos prolongados como el sur del Magdalena.',
    },

    // ─── FRUTALES ──────────────────────────────────────────
    {
      nombre: 'Banano',
      nombreCientifico: 'Musa acuminata',
      categoria: 'frutal',
      cicloVegetativo: 'permanente',
      diasCosecha: 270,
      densidadSiembraPorHa: 1700,
      descripcion:
        'Cultivo bandera del Magdalena en la zona bananera (Cienaga, Aracataca, Fundacion). Tipo Cavendish para exportacion.',
    },
    {
      nombre: 'Plátano',
      nombreCientifico: 'Musa paradisiaca',
      categoria: 'frutal',
      cicloVegetativo: 'permanente',
      diasCosecha: 300,
      densidadSiembraPorHa: 1100,
      descripcion:
        'Cultivo de pancoger del pequeño productor. Variedades Hartón y Dominico-Hartón predominan en la region.',
    },
    {
      nombre: 'Mango',
      nombreCientifico: 'Mangifera indica',
      categoria: 'frutal',
      cicloVegetativo: 'permanente',
      diasCosecha: 1095,
      densidadSiembraPorHa: 100,
      descripcion:
        'Frutal perenne tropical. Variedades Tommy Atkins, Keitt y comunes. Tiempo a primera produccion: 3 años.',
    },
    {
      nombre: 'Aguacate',
      nombreCientifico: 'Persea americana',
      categoria: 'frutal',
      cicloVegetativo: 'permanente',
      diasCosecha: 1460,
      densidadSiembraPorHa: 156,
      descripcion:
        'Frutal de gran valor comercial. Variedad Hass en zonas altas (Sierra Nevada), variedades comunes en tierras bajas.',
    },
    {
      nombre: 'Patilla',
      nombreCientifico: 'Citrullus lanatus',
      categoria: 'frutal',
      cicloVegetativo: 'transitorio',
      diasCosecha: 90,
      densidadSiembraPorHa: 1000,
      descripcion:
        'Cucurbitacea de ciclo corto. Alta demanda en mercados locales del Caribe colombiano.',
    },
    {
      nombre: 'Ahuyama',
      nombreCientifico: 'Cucurbita moschata',
      categoria: 'frutal',
      cicloVegetativo: 'transitorio',
      diasCosecha: 100,
      densidadSiembraPorHa: 1100,
      descripcion:
        'Calabaza criolla. Cultivo asociado tradicional con maiz y frijol (sistema "milpa").',
    },

    // ─── TUBERCULOS / HORTALIZAS ───────────────────────────
    {
      nombre: 'Yuca',
      nombreCientifico: 'Manihot esculenta',
      categoria: 'tuberculo',
      cicloVegetativo: 'transitorio',
      diasCosecha: 300,
      densidadSiembraPorHa: 10000,
      descripcion:
        'Tuberculo de seguridad alimentaria. Resistente a sequia, cultivado en todo el departamento por pequeños productores.',
    },
    {
      nombre: 'Ñame',
      nombreCientifico: 'Dioscorea alata',
      categoria: 'tuberculo',
      cicloVegetativo: 'transitorio',
      diasCosecha: 240,
      densidadSiembraPorHa: 8000,
      descripcion:
        'Tuberculo tropical, complemento de la yuca. Variedades Espino, Diamante y Blanco.',
    },

    // ─── LEGUMINOSAS ───────────────────────────────────────
    {
      nombre: 'Frijol',
      nombreCientifico: 'Phaseolus vulgaris',
      categoria: 'leguminosa',
      cicloVegetativo: 'transitorio',
      diasCosecha: 90,
      densidadSiembraPorHa: 200000,
      descripcion:
        'Leguminosa fijadora de nitrogeno. Variedad Cargamanto comun en sistemas asociados con maiz.',
    },

    // ─── COMERCIALES ───────────────────────────────────────
    {
      nombre: 'Cacao',
      nombreCientifico: 'Theobroma cacao',
      categoria: 'comercial',
      cicloVegetativo: 'permanente',
      diasCosecha: 1095,
      densidadSiembraPorHa: 1100,
      descripcion:
        'Cultivo de gran valor en zonas humedas del Magdalena. Modelo agroforestal recomendado.',
    },
    {
      nombre: 'Café',
      nombreCientifico: 'Coffea arabica',
      categoria: 'comercial',
      cicloVegetativo: 'permanente',
      diasCosecha: 1095,
      densidadSiembraPorHa: 5000,
      descripcion:
        'Cultivo de altura, predominante en la Sierra Nevada de Santa Marta. Variedades Castillo y Caturra.',
    },
    {
      nombre: 'Palma de aceite',
      nombreCientifico: 'Elaeis guineensis',
      categoria: 'comercial',
      cicloVegetativo: 'permanente',
      diasCosecha: 1095,
      densidadSiembraPorHa: 143,
      descripcion:
        'Cultivo industrial extendido en el sur del Magdalena. Inicio de produccion a los 3 años, vida util 25+ años.',
    },

    // ─── FORRAJES ──────────────────────────────────────────
    {
      nombre: 'Pasto Angleton',
      nombreCientifico: 'Dichanthium aristatum',
      categoria: 'forraje',
      cicloVegetativo: 'permanente',
      diasCosecha: 60,
      densidadSiembraPorHa: 12000,
      descripcion:
        'Forraje resistente al pisoteo y la sequia. Comun en la ganaderia extensiva del Magdalena.',
    },
  ];

  let creados = 0;
  let omitidos = 0;

  for (const data of cultivos) {
    const existe = await repo.findOne({ where: { nombre: data.nombre } });
    if (existe) {
      omitidos++;
      continue;
    }
    await repo.save(repo.create(data));
    creados++;
  }

  console.log(`  Cultivos: ${creados} creados, ${omitidos} ya existian`);
}
