import { DataSource } from 'typeorm';

import { Plaga } from '../../../modules/catalogos/entities/plaga.entity';

/**
 * Seed de plagas y enfermedades de mayor incidencia en el Magdalena.
 *
 * Fuentes:
 * - ICA - Boletines fitosanitarios 2023-2024
 * - Asbama (Asociacion de Bananeros del Magdalena)
 * - Cenicafe
 * - Corpoica/AGROSAVIA
 *
 * Cubre las amenazas mas reportadas en los principales cultivos:
 * banano (Sigatoka, Fusarium), maiz (Gusano cogollero, Mosca blanca),
 * yuca (Mosca blanca, Trips), frutales (Antracnosis, Picudo).
 */
export async function seedPlagas(dataSource: DataSource): Promise<void> {
  const repo = dataSource.getRepository(Plaga);

  const plagas: Array<Partial<Plaga>> = [
    // ─── INSECTOS ──────────────────────────────────────────
    {
      nombre: 'Gusano cogollero',
      nombreCientifico: 'Spodoptera frugiperda',
      tipo: 'insecto',
      severidadTipica: 'alta',
      sintomas:
        'Hojas con perforaciones irregulares, presencia de excrementos en el cogollo, larvas verdes con cabeza oscura. Puede destruir plantulas en pocos dias.',
      cultivosAfectados: 'maiz, sorgo, arroz, pasto',
    },
    {
      nombre: 'Mosca blanca',
      nombreCientifico: 'Bemisia tabaci',
      tipo: 'insecto',
      severidadTipica: 'alta',
      sintomas:
        'Adultos blancos volando al sacudir la planta, hojas amarillentas, fumagina (hongo negro) por melaza. Transmite virus.',
      cultivosAfectados: 'yuca, frijol, ahuyama, patilla, tomate',
    },
    {
      nombre: 'Picudo del banano',
      nombreCientifico: 'Cosmopolites sordidus',
      tipo: 'insecto',
      severidadTipica: 'alta',
      sintomas:
        'Galerias en el corm/rizoma, plantas debiles que se voltean por viento. Adulto: cucarron negro de 1 cm.',
      cultivosAfectados: 'banano, platano',
    },
    {
      nombre: 'Trips',
      nombreCientifico: 'Frankliniella occidentalis',
      tipo: 'insecto',
      severidadTipica: 'media',
      sintomas:
        'Manchas plateadas en hojas y frutos, puntos negros (excrementos), deformacion de frutos jovenes.',
      cultivosAfectados: 'aguacate, mango, patilla, frijol',
    },
    {
      nombre: 'Pulgones',
      nombreCientifico: 'Aphis gossypii',
      tipo: 'insecto',
      severidadTipica: 'media',
      sintomas:
        'Colonias en envés de hojas y brotes nuevos, hojas enrolladas, presencia de melaza y hormigas.',
      cultivosAfectados: 'maiz, frijol, hortalizas',
    },
    {
      nombre: 'Broca del café',
      nombreCientifico: 'Hypothenemus hampei',
      tipo: 'insecto',
      severidadTipica: 'critica',
      sintomas:
        'Perforacion circular en cereza/grano de cafe, granos vanos o dañados. Reduce calidad y peso.',
      cultivosAfectados: 'cafe',
    },

    // ─── HONGOS ────────────────────────────────────────────
    {
      nombre: 'Sigatoka negra',
      nombreCientifico: 'Mycosphaerella fijiensis',
      tipo: 'hongo',
      severidadTipica: 'critica',
      sintomas:
        'Manchas alargadas color cafe oscuro a negro en hojas, defoliacion progresiva, racimos pequeños y maduracion prematura.',
      cultivosAfectados: 'banano, platano',
    },
    {
      nombre: 'Fusarium R4T',
      nombreCientifico: 'Fusarium oxysporum f. sp. cubense raza 4',
      tipo: 'hongo',
      severidadTipica: 'critica',
      sintomas:
        'Amarillamiento de hojas viejas, marchitamiento, pudricion vascular oscura en el rizoma. Enfermedad de cuarentena en Colombia.',
      cultivosAfectados: 'banano, platano',
    },
    {
      nombre: 'Antracnosis',
      nombreCientifico: 'Colletotrichum gloeosporioides',
      tipo: 'hongo',
      severidadTipica: 'alta',
      sintomas:
        'Manchas circulares hundidas en frutos, hojas con lesiones cafe. Frecuente en epoca lluviosa.',
      cultivosAfectados: 'mango, aguacate, banano, platano',
    },
    {
      nombre: 'Roya del café',
      nombreCientifico: 'Hemileia vastatrix',
      tipo: 'hongo',
      severidadTipica: 'alta',
      sintomas:
        'Manchas amarillo-naranja con polvo en el envés de las hojas, defoliacion severa, perdida de produccion.',
      cultivosAfectados: 'cafe',
    },
    {
      nombre: 'Tizón temprano',
      nombreCientifico: 'Alternaria solani',
      tipo: 'hongo',
      severidadTipica: 'media',
      sintomas:
        'Manchas circulares con anillos concentricos en hojas viejas, defoliacion ascendente.',
      cultivosAfectados: 'tomate, papa, patilla',
    },

    // ─── BACTERIAS ─────────────────────────────────────────
    {
      nombre: 'Moko del plátano',
      nombreCientifico: 'Ralstonia solanacearum raza 2',
      tipo: 'bacteria',
      severidadTipica: 'critica',
      sintomas:
        'Marchitamiento subito de plantas adultas, pudricion vascular con exudado bacteriano, fruto con pudricion seca interna.',
      cultivosAfectados: 'platano, banano',
    },

    // ─── VIRUS ─────────────────────────────────────────────
    {
      nombre: 'Virus del mosaico de la yuca',
      nombreCientifico: 'Cassava mosaic virus',
      tipo: 'virus',
      severidadTipica: 'alta',
      sintomas:
        'Mosaico amarillo y verde en hojas, deformacion del follaje, reduccion de tamaño de raices.',
      cultivosAfectados: 'yuca',
    },

    // ─── MALEZAS ───────────────────────────────────────────
    {
      nombre: 'Coquito',
      nombreCientifico: 'Cyperus rotundus',
      tipo: 'maleza',
      severidadTipica: 'alta',
      sintomas:
        'Maleza perenne de hoja angosta, propagacion por tuberculos subterraneos, competencia agresiva.',
      cultivosAfectados: 'todos los cultivos',
    },
    {
      nombre: 'Bledo',
      nombreCientifico: 'Amaranthus spinosus',
      tipo: 'maleza',
      severidadTipica: 'media',
      sintomas: 'Maleza anual de hoja ancha con espinas, crecimiento rapido, hospedera de plagas.',
      cultivosAfectados: 'maiz, frijol, hortalizas',
    },

    // ─── NEMATODOS ─────────────────────────────────────────
    {
      nombre: 'Nematodo del nudo',
      nombreCientifico: 'Meloidogyne incognita',
      tipo: 'nematodo',
      severidadTipica: 'alta',
      sintomas:
        'Agallas/nudos en raices, plantas raquiticas, marchitamiento aun con suelo humedo, amarillamiento.',
      cultivosAfectados: 'tomate, ahuyama, patilla, frijol, banano',
    },
  ];

  let creados = 0;
  let omitidos = 0;

  for (const data of plagas) {
    const existe = await repo.findOne({ where: { nombre: data.nombre } });
    if (existe) {
      omitidos++;
      continue;
    }
    await repo.save(repo.create(data));
    creados++;
  }

  console.log(`  Plagas: ${creados} creadas, ${omitidos} ya existian`);
}
