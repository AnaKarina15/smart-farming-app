import { DataSource } from 'typeorm';

import { Plaga } from '../../../modules/catalogos/entities/plaga.entity';

/**
 * Seed de plagas y enfermedades del Magdalena alimentado con el catálogo agrícola completo.
 */
export async function seedPlagas(dataSource: DataSource): Promise<void> {
  const repo = dataSource.getRepository(Plaga);

  const plagas: Array<Partial<Plaga>> = [
    // ─── INSECTOS ──────────────────────────────────────────
    {
      nombre: 'Broca del café',
      nombreCientifico: 'Hypothenemus hampei',
      tipo: 'insecto',
      severidadTipica: 'critica',
      sintomas:
        'Perforacion circular en cereza/grano de cafe, granos vanos o dañados. Reduce calidad y peso.',
      cultivosAfectados: 'cafe',
    },
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
      nombre: 'Minador de hojas',
      nombreCientifico: 'Liriomyza spp.',
      tipo: 'insecto',
      severidadTipica: 'media',
      sintomas:
        'Galerias o canales serpenteantes y blanquecinos en las hojas por alimentacion de las larvas.',
      cultivosAfectados: 'tomate, papa, frijol, hortalizas',
    },
    {
      nombre: 'Áfidos (pulgones)',
      nombreCientifico: 'Aphis spp.',
      tipo: 'insecto',
      severidadTipica: 'media',
      sintomas:
        'Colonias en enves de hojas y brotes nuevos, hojas enrolladas, presencia de melaza y hormigas.',
      cultivosAfectados: 'maiz, frijol, hortalizas, citricos',
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
      nombre: 'Trips',
      nombreCientifico: 'Frankliniella occidentalis',
      tipo: 'insecto',
      severidadTipica: 'media',
      sintomas:
        'Manchas plateadas en hojas y frutos, puntos negros (excrementos), deformacion de frutos jovenes.',
      cultivosAfectados: 'aguacate, mango, patilla, frijol',
    },
    {
      nombre: 'Hormiga arriera',
      nombreCientifico: 'Atta spp.',
      tipo: 'insecto',
      severidadTipica: 'media',
      sintomas:
        'Corte semicircular de hojas y defoliacion rapida de ramas completas.',
      cultivosAfectados: 'yuca, citricos, cacao, cafe, frutales',
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

    // ─── HONGOS ────────────────────────────────────────────
    {
      nombre: 'Antracnosis',
      nombreCientifico: 'Colletotrichum spp.',
      tipo: 'hongo',
      severidadTipica: 'alta',
      sintomas:
        'Manchas circulares hundidas y oscuras en frutos, hojas con lesiones cafe de aspecto quemado. Frecuente en epoca lluviosa.',
      cultivosAfectados: 'mango, aguacate, banano, platano, cacao',
    },
    {
      nombre: 'Roya del café',
      nombreCientifico: 'Hemileia vastatrix',
      tipo: 'hongo',
      severidadTipica: 'alta',
      sintomas:
        'Manchas amarillo-naranja con polvo en el enves de las hojas, defoliacion severa, perdida de produccion.',
      cultivosAfectados: 'cafe',
    },
    {
      nombre: 'Mildiu',
      nombreCientifico: 'Peronospora spp.',
      tipo: 'hongo',
      severidadTipica: 'media',
      sintomas:
        'Manchas amarillentas en el haz de las hojas y moho grisaceo o blanquecino en el enves en condiciones de alta humedad.',
      cultivosAfectados: 'hortalizas, papa, frutales',
    },
    {
      nombre: 'Tizón tardío (papa/tomate)',
      nombreCientifico: 'Phytophthora infestans',
      tipo: 'hongo',
      severidadTipica: 'alta',
      sintomas:
        'Manchas necroticas cafe-negras de aspecto humedo en hojas y tallos, pudricion humeda del fruto y tuberculos.',
      cultivosAfectados: 'tomate, papa',
    },
    {
      nombre: 'Fusariosis',
      nombreCientifico: 'Fusarium oxysporum',
      tipo: 'hongo',
      severidadTipica: 'alta',
      sintomas:
        'Marchitamiento progresivo, amarillamiento foliar unilateral y oscurecimiento de los vasos conductores.',
      cultivosAfectados: 'tomate, banano, platano, flores, frijol',
    },
    {
      nombre: 'Botrytis (moho gris)',
      nombreCientifico: 'Botrytis cinerea',
      tipo: 'hongo',
      severidadTipica: 'media',
      sintomas:
        'Moho gris velloso sobre flores, hojas y frutos, provocando pudricion blanda.',
      cultivosAfectados: 'tomate, frutales, hortalizas',
    },
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
      nombre: 'Marchitez bacteriana',
      nombreCientifico: 'Ralstonia solanacearum',
      tipo: 'bacteria',
      severidadTipica: 'alta',
      sintomas:
        'Marchitez repentina del follaje durante las horas mas calurosas del dia sin amarillamiento previo, pudricion vascular.',
      cultivosAfectados: 'tomate, papa, berenjena, platano',
    },
    {
      nombre: 'Mancha bacteriana',
      nombreCientifico: 'Xanthomonas spp.',
      tipo: 'bacteria',
      severidadTipica: 'media',
      sintomas:
        'Pequeñas manchas oscuras y acuosas en hojas y frutos, a menudo rodeadas de un halo amarillento.',
      cultivosAfectados: 'tomate, pimenton, citricos',
    },
    {
      nombre: 'Necrosis foliar',
      nombreCientifico: 'Pseudomonas syringae',
      tipo: 'bacteria',
      severidadTipica: 'media',
      sintomas:
        'Manchas foliares necroticas oscuras, a menudo rodeadas de un halo amarillo, muerte regresiva de brotes.',
      cultivosAfectados: 'hortalizas, frutales',
    },
    {
      nombre: 'Fuego bacteriano',
      nombreCientifico: 'Erwinia amylovora',
      tipo: 'bacteria',
      severidadTipica: 'alta',
      sintomas:
        'Flores, hojas y ramas que se marchitan rapidamente, se tornan negras y toman aspecto de quemadas por fuego.',
      cultivosAfectados: 'frutales',
    },
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

    // ─── NEMATODOS ─────────────────────────────────────────
    {
      nombre: 'Nematodo agallador',
      nombreCientifico: 'Meloidogyne spp.',
      tipo: 'nematodo',
      severidadTipica: 'alta',
      sintomas:
        'Agallas/nudos en raices, plantas raquiticas, marchitamiento aun con suelo humedo, amarillamiento general.',
      cultivosAfectados: 'tomate, ahuyama, patilla, frijol, banano',
    },
    {
      nombre: 'Nematodo lesionador',
      nombreCientifico: 'Pratylenchus spp.',
      tipo: 'nematodo',
      severidadTipica: 'media',
      sintomas:
        'Lesiones necroticas oscuras en las raices secundarias, reduccion del sistema radicular y retraso en el crecimiento.',
      cultivosAfectados: 'maiz, platano, cafe, papa',
    },

    // ─── MALEZAS ───────────────────────────────────────────
    {
      nombre: 'Grama',
      nombreCientifico: 'Cynodon dactylon',
      tipo: 'maleza',
      severidadTipica: 'media',
      sintomas:
        'Maleza perenne de cobertura densa y rapida expansion por estolones, compite agresivamente por agua y nutrientes.',
      cultivosAfectados: 'todos los cultivos',
    },
    {
      nombre: 'Kikuyo',
      nombreCientifico: 'Pennisetum clandestinum',
      tipo: 'maleza',
      severidadTipica: 'media',
      sintomas:
        'Pasto rastrero sumamente invasivo con estolones fuertes que ahoga otros cultivos.',
      cultivosAfectados: 'todos los cultivos',
    },
    {
      nombre: 'Parietaria',
      nombreCientifico: 'Parietaria officinalis',
      tipo: 'maleza',
      severidadTipica: 'baja',
      sintomas:
        'Hierba de crecimiento rapido en zonas humedas y sombreadas, compite con plantulas de hortalizas.',
      cultivosAfectados: 'hortalizas, frutales',
    },
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

    // ─── OTROS ─────────────────────────────────────────────
    {
      nombre: 'Ratón de campo',
      nombreCientifico: 'Mus musculus',
      tipo: 'otro',
      severidadTipica: 'media',
      sintomas:
        'Daño por roedura en tallos, raices y frutos, perdida de grano almacenado o en campo.',
      cultivosAfectados: 'maiz, arroz, hortalizas, cacao',
    },
    {
      nombre: 'Paloma común',
      nombreCientifico: 'Columba livia',
      tipo: 'otro',
      severidadTipica: 'baja',
      sintomas:
        'Consumo de semillas recien sembradas y frutos maduros, contaminacion foliar con excrementos.',
      cultivosAfectados: 'maiz, sorgo, arroz, frutas',
    },
  ];

  let creados = 0;
  let actualizados = 0;

  for (const data of plagas) {
    const existe = await repo.findOne({ where: { nombre: data.nombre } });
    if (existe) {
      Object.assign(existe, data);
      await repo.save(existe);
      actualizados++;
    } else {
      await repo.save(repo.create(data));
      creados++;
    }
  }

  console.log(`  Plagas: ${creados} creadas, ${actualizados} actualizadas`);
}
