import { DataSource } from 'typeorm';

import { Fertilizante } from '../../../modules/catalogos/entities/fertilizante.entity';

/**
 * Seed de fertilizantes y enmiendas mas usados en el Magdalena.
 *
 * Fuentes:
 * - ICA - Listado de fertilizantes registrados en Colombia
 * - Monomeros, Yara, Abocol (principales proveedores)
 * - Agronet - Estadisticas de uso de fertilizantes
 *
 * Cubre las necesidades de los principales cultivos:
 * banano (alto requerimiento de K), maiz (N alto), cafe (mixto),
 * y enmiendas para suelos acidos comunes en el departamento.
 */
export async function seedFertilizantes(dataSource: DataSource): Promise<void> {
  const repo = dataSource.getRepository(Fertilizante);

  const fertilizantes: Array<Partial<Fertilizante>> = [
    // ─── NITROGENADOS ──────────────────────────────────────
    {
      nombre: 'Urea 46%',
      tipo: 'nitrogenado',
      composicionNpk: '46-0-0',
      presentacion: 'solido_granulado',
      dosisRecomendadaKgHa: 250,
      descripcion:
        'Fertilizante nitrogenado de mayor concentracion (46% N). Economico y de rapida liberacion. Aplicar en suelos humedos para evitar volatilizacion.',
    },
    {
      nombre: 'Sulfato de Amonio',
      tipo: 'nitrogenado',
      composicionNpk: '21-0-0',
      presentacion: 'solido_granulado',
      dosisRecomendadaKgHa: 350,
      descripcion:
        'Aporta nitrogeno (21%) y azufre (24%). Indicado para cultivos exigentes en azufre como brassicas y leguminosas. Acidifica el suelo.',
    },
    {
      nombre: 'Nitrato de Amonio',
      tipo: 'nitrogenado',
      composicionNpk: '33-0-0',
      presentacion: 'solido_granulado',
      dosisRecomendadaKgHa: 280,
      descripcion:
        'Doble forma de nitrogeno (nitrica y amoniacal), absorcion mas rapida que la urea. Util en cultivos de ciclo corto.',
    },

    // ─── FOSFATADOS ────────────────────────────────────────
    {
      nombre: 'DAP (Fosfato Diamonico)',
      tipo: 'fosfatado',
      composicionNpk: '18-46-0',
      presentacion: 'solido_granulado',
      dosisRecomendadaKgHa: 200,
      descripcion:
        'Fuente concentrada de fosforo (46% P2O5) y nitrogeno (18% N). Ideal al momento de la siembra para favorecer el desarrollo radicular.',
    },
    {
      nombre: 'Superfosfato Triple',
      tipo: 'fosfatado',
      composicionNpk: '0-46-0',
      presentacion: 'solido_granulado',
      dosisRecomendadaKgHa: 200,
      descripcion:
        'Fosforo puro (46% P2O5) de alta solubilidad. Indicado en suelos pobres en fosforo. Aplicar al fondo del surco.',
    },

    // ─── POTASICOS ─────────────────────────────────────────
    {
      nombre: 'KCl (Cloruro de Potasio)',
      tipo: 'potasico',
      composicionNpk: '0-0-60',
      presentacion: 'solido_granulado',
      dosisRecomendadaKgHa: 300,
      descripcion:
        'Fuente principal de potasio (60% K2O). Esencial para banano, platano y frutales en general. Mejora calidad y vida en anaquel.',
    },
    {
      nombre: 'Sulfato de Potasio',
      tipo: 'potasico',
      composicionNpk: '0-0-50',
      presentacion: 'solido_granulado',
      dosisRecomendadaKgHa: 320,
      descripcion:
        'Aporta potasio (50% K2O) y azufre (18%). Preferido en cultivos sensibles al cloruro como aguacate y cacao.',
    },

    // ─── COMPUESTOS ────────────────────────────────────────
    {
      nombre: 'Triple 15 (15-15-15)',
      tipo: 'compuesto',
      composicionNpk: '15-15-15',
      presentacion: 'solido_granulado',
      dosisRecomendadaKgHa: 400,
      descripcion:
        'Fertilizante completo balanceado para etapas de crecimiento. Uso general en maiz, frijol, hortalizas y frutales jovenes.',
    },
    {
      nombre: 'Abonamax 10-30-10',
      tipo: 'compuesto',
      composicionNpk: '10-30-10',
      presentacion: 'solido_granulado',
      dosisRecomendadaKgHa: 350,
      descripcion:
        'Alto en fosforo, ideal para siembra y desarrollo inicial de raices. Recomendado en cultivos de ciclo corto.',
    },
    {
      nombre: 'Abocol 17-6-18-2',
      tipo: 'compuesto',
      composicionNpk: '17-6-18',
      presentacion: 'solido_granulado',
      dosisRecomendadaKgHa: 450,
      descripcion:
        'Formula balanceada con magnesio (2%) para banano y platano en etapa productiva. Producto bandera en zona bananera.',
    },

    // ─── ORGANICOS ─────────────────────────────────────────
    {
      nombre: 'Gallinaza',
      tipo: 'organico',
      composicionNpk: '3-2-2',
      presentacion: 'solido_polvo',
      dosisRecomendadaKgHa: 3000,
      descripcion:
        'Estiercol avicola compostado. Mejora estructura del suelo y aporta materia organica. Aplicar con 2 semanas de anticipacion.',
    },
    {
      nombre: 'Compost',
      tipo: 'organico',
      composicionNpk: '1-1-1',
      presentacion: 'solido_polvo',
      dosisRecomendadaKgHa: 4000,
      descripcion:
        'Materia organica descompuesta. Mejora retencion de humedad y vida microbiana del suelo. Indispensable en agricultura sostenible.',
    },
    {
      nombre: 'Humus de lombriz',
      tipo: 'organico',
      composicionNpk: '2-1-1',
      presentacion: 'solido_polvo',
      dosisRecomendadaKgHa: 2500,
      descripcion:
        'Producto de la digestion de lombrices. Alta concentracion de microorganismos beneficos y nutrientes asimilables.',
    },

    // ─── ENMIENDAS ─────────────────────────────────────────
    {
      nombre: 'Cal Dolomita',
      tipo: 'enmienda',
      composicionNpk: '0-0-0',
      presentacion: 'solido_polvo',
      dosisRecomendadaKgHa: 1500,
      descripcion:
        'Enmienda calcica-magnesica para corregir acidez del suelo (sube pH). Aplicar 1-2 meses antes de la siembra.',
    },
    {
      nombre: 'Cal Agrícola',
      tipo: 'enmienda',
      composicionNpk: '0-0-0',
      presentacion: 'solido_polvo',
      dosisRecomendadaKgHa: 2000,
      descripcion:
        'Carbonato de calcio molido. Neutraliza acidez del suelo y mejora disponibilidad de fosforo.',
    },

    // ─── FOLIARES ──────────────────────────────────────────
    {
      nombre: 'Foliar NPK Premium',
      tipo: 'compuesto',
      composicionNpk: '20-20-20',
      presentacion: 'foliar',
      dosisRecomendadaKgHa: 3,
      descripcion:
        'Solucion foliar de aplicacion via aspersion. Rapida correccion de deficiencias. Dosis en kg/ha de producto comercial.',
    },
  ];

  let creados = 0;
  let omitidos = 0;

  for (const data of fertilizantes) {
    const existe = await repo.findOne({ where: { nombre: data.nombre } });
    if (existe) {
      omitidos++;
      continue;
    }
    await repo.save(repo.create(data));
    creados++;
  }

  console.log(`  Fertilizantes: ${creados} creados, ${omitidos} ya existian`);
}
