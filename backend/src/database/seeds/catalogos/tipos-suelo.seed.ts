import { DataSource } from 'typeorm';

import { TipoSuelo } from '../../../modules/catalogos/entities/tipo-suelo.entity';

/**
 * Seed de tipos de suelo segun clasificacion textural FAO/USDA.
 *
 * Fuentes:
 * - IGAC - Estudio general de suelos del Magdalena
 * - FAO - Soil Texture Classification
 * - AGROSAVIA - Caracterizacion de suelos del Caribe colombiano
 *
 * Cubre las 6 clases texturales basicas mas frecuentes en el departamento.
 * Cada tipo incluye sus propiedades clave (drenaje, retencion de humedad, pH)
 * y los cultivos mejor adaptados.
 */
export async function seedTiposSuelo(dataSource: DataSource): Promise<void> {
  const repo = dataSource.getRepository(TipoSuelo);

  const tipos: Array<Partial<TipoSuelo>> = [
    {
      nombre: 'Arenoso',
      clase: 'arenoso',
      drenaje: 'rapido',
      retencionHumedadPct: 10.0,
      phTipico: 6.0,
      cultivosRecomendados: 'patilla, ahuyama, maní, yuca',
      descripcion:
        'Suelo de particulas grandes, drena muy rapido y retiene poca humedad. Bajo en nutrientes. Comun en la costa norte. Requiere riego frecuente y materia organica abundante.',
    },
    {
      nombre: 'Franco Arenoso',
      clase: 'franco_arenoso',
      drenaje: 'moderado',
      retencionHumedadPct: 20.0,
      phTipico: 6.3,
      cultivosRecomendados: 'maiz, yuca, patilla, ñame, frijol',
      descripcion:
        'Suelo bien balanceado con predominio de arena. Buen drenaje y aireacion, retencion media de agua. Ideal para la mayoria de cultivos de pequeño productor.',
    },
    {
      nombre: 'Franco',
      clase: 'franco',
      drenaje: 'moderado',
      retencionHumedadPct: 30.0,
      phTipico: 6.5,
      cultivosRecomendados: 'banano, platano, maiz, hortalizas, cacao',
      descripcion:
        'Suelo ideal: mezcla equilibrada de arena, limo y arcilla. Drenaje adecuado, alta retencion de humedad y nutrientes. Excelente para casi todos los cultivos.',
    },
    {
      nombre: 'Franco Arcilloso',
      clase: 'franco_arcilloso',
      drenaje: 'lento',
      retencionHumedadPct: 38.0,
      phTipico: 6.7,
      cultivosRecomendados: 'arroz, banano, platano, cacao, palma',
      descripcion:
        'Suelo pesado con predominio de arcilla. Alta retencion de humedad y nutrientes pero drenaje limitado. Comun en la zona bananera y zonas de inundacion.',
    },
    {
      nombre: 'Arcilloso',
      clase: 'arcilloso',
      drenaje: 'lento',
      retencionHumedadPct: 45.0,
      phTipico: 6.8,
      cultivosRecomendados: 'arroz, caña de azucar, palma de aceite',
      descripcion:
        'Suelo muy fino y pegajoso cuando humedo, duro cuando seco. Excelente retencion de agua pero mal drenaje. Riesgo de encharcamiento. Apto para arroz inundado.',
    },
    {
      nombre: 'Limoso',
      clase: 'limoso',
      drenaje: 'moderado',
      retencionHumedadPct: 35.0,
      phTipico: 6.6,
      cultivosRecomendados: 'hortalizas, maiz, frijol, frutales',
      descripcion:
        'Suelo de particulas medias, sensacion sedosa. Alta retencion de humedad y fertilidad. Comun en zonas aluviales del rio Magdalena. Susceptible a compactacion.',
    },
  ];

  let creados = 0;
  let omitidos = 0;

  for (const data of tipos) {
    const existe = await repo.findOne({ where: { nombre: data.nombre } });
    if (existe) {
      omitidos++;
      continue;
    }
    await repo.save(repo.create(data));
    creados++;
  }

  console.log(`  Tipos de suelo: ${creados} creados, ${omitidos} ya existian`);
}
