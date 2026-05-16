import { DataSource } from 'typeorm';

import { Municipio } from '../../../modules/catalogos/entities/municipio.entity';

/**
 * Seed de los municipios oficiales del departamento del Magdalena, Colombia.
 *
 * Fuente: DANE - Division Politico-Administrativa de Colombia (DIVIPOLA).
 * Codigos de 5 digitos: 47 (departamento) + 3 (municipio).
 *
 * Subregiones segun la Gobernacion del Magdalena:
 * - Norte: zona costera, Sierra Nevada y zona bananera
 * - Centro: tierra adentro, ganaderia
 * - Sur: zona del rio Magdalena (depresion momposina)
 * - Rio: ribera del rio Magdalena
 *
 * Coordenadas: centro de la cabecera municipal (precision 7 decimales).
 *
 * Idempotente: si el municipio ya existe (por codigoDane), se omite.
 */
export async function seedMunicipios(dataSource: DataSource): Promise<void> {
  const repo = dataSource.getRepository(Municipio);

  const municipios: Array<Partial<Municipio>> = [
    // ─── Subregion NORTE ─────────────────────────────────────
    {
      codigoDane: '47001',
      nombre: 'Santa Marta',
      subregion: 'Norte',
      latitud: 11.2408,
      longitud: -74.199,
    },
    {
      codigoDane: '47053',
      nombre: 'Aracataca',
      subregion: 'Norte',
      latitud: 10.5917,
      longitud: -74.1881,
    },
    {
      codigoDane: '47189',
      nombre: 'Ciénaga',
      subregion: 'Norte',
      latitud: 11.0093,
      longitud: -74.2462,
    },
    {
      codigoDane: '47245',
      nombre: 'El Retén',
      subregion: 'Norte',
      latitud: 10.6086,
      longitud: -74.2664,
    },
    {
      codigoDane: '47258',
      nombre: 'Fundación',
      subregion: 'Norte',
      latitud: 10.5167,
      longitud: -74.1872,
    },
    {
      codigoDane: '47798',
      nombre: 'Pueblo Viejo',
      subregion: 'Norte',
      latitud: 10.9939,
      longitud: -74.2837,
    },
    {
      codigoDane: '47707',
      nombre: 'Sitionuevo',
      subregion: 'Norte',
      latitud: 10.7758,
      longitud: -74.7222,
    },
    {
      codigoDane: '47980',
      nombre: 'Zona Bananera',
      subregion: 'Norte',
      latitud: 10.7619,
      longitud: -74.1583,
    },

    // ─── Subregion CENTRO ────────────────────────────────────
    {
      codigoDane: '47030',
      nombre: 'Algarrobo',
      subregion: 'Centro',
      latitud: 10.19,
      longitud: -74.0608,
    },
    {
      codigoDane: '47170',
      nombre: 'Chibolo',
      subregion: 'Centro',
      latitud: 10.0211,
      longitud: -74.63,
    },
    {
      codigoDane: '47268',
      nombre: 'El Piñón',
      subregion: 'Centro',
      latitud: 10.4017,
      longitud: -74.8228,
    },
    {
      codigoDane: '47660',
      nombre: 'Sabanas de San Ángel',
      subregion: 'Centro',
      latitud: 10.0319,
      longitud: -74.2189,
    },
    {
      codigoDane: '47692',
      nombre: 'San Zenón',
      subregion: 'Centro',
      latitud: 9.2447,
      longitud: -74.4994,
    },
    {
      codigoDane: '47703',
      nombre: 'Santa Bárbara de Pinto',
      subregion: 'Centro',
      latitud: 9.4339,
      longitud: -74.7053,
    },
    {
      codigoDane: '47745',
      nombre: 'Tenerife',
      subregion: 'Centro',
      latitud: 9.8961,
      longitud: -74.8581,
    },

    // ─── Subregion SUR ───────────────────────────────────────
    {
      codigoDane: '47077',
      nombre: 'Ariguaní',
      subregion: 'Sur',
      latitud: 9.8467,
      longitud: -74.2381,
    },
    {
      codigoDane: '47161',
      nombre: 'Cerro de San Antonio',
      subregion: 'Sur',
      latitud: 10.3261,
      longitud: -74.8669,
    },
    {
      codigoDane: '47205',
      nombre: 'Concordia',
      subregion: 'Sur',
      latitud: 10.2575,
      longitud: -74.8336,
    },
    { codigoDane: '47318', nombre: 'Guamal', subregion: 'Sur', latitud: 9.145, longitud: -74.2244 },
    {
      codigoDane: '47545',
      nombre: 'Pijiño del Carmen',
      subregion: 'Sur',
      latitud: 9.3306,
      longitud: -74.4517,
    },
    {
      codigoDane: '47551',
      nombre: 'Pivijay',
      subregion: 'Sur',
      latitud: 10.4625,
      longitud: -74.6158,
    },
    { codigoDane: '47555', nombre: 'Plato', subregion: 'Sur', latitud: 9.795, longitud: -74.7833 },
    { codigoDane: '47675', nombre: 'Salamina', subregion: 'Sur', latitud: 10.49, longitud: -74.79 },

    // ─── Subregion RIO ───────────────────────────────────────
    {
      codigoDane: '47058',
      nombre: 'El Banco',
      subregion: 'Rio',
      latitud: 9.0061,
      longitud: -73.9722,
    },
    {
      codigoDane: '47460',
      nombre: 'Nueva Granada',
      subregion: 'Rio',
      latitud: 9.8019,
      longitud: -74.3917,
    },
    {
      codigoDane: '47541',
      nombre: 'Pedraza',
      subregion: 'Rio',
      latitud: 10.1881,
      longitud: -74.9181,
    },
    {
      codigoDane: '47570',
      nombre: 'Remolino',
      subregion: 'Rio',
      latitud: 10.7019,
      longitud: -74.7164,
    },
    {
      codigoDane: '47720',
      nombre: 'San Sebastián de Buenavista',
      subregion: 'Rio',
      latitud: 9.24,
      longitud: -74.35,
    },
    {
      codigoDane: '47960',
      nombre: 'Zapayán',
      subregion: 'Rio',
      latitud: 10.1697,
      longitud: -74.7211,
    },
  ];

  let creados = 0;
  let omitidos = 0;

  for (const data of municipios) {
    // Verificar por codigoDane Y por nombre (proteccion doble)
    const existePorCodigo = await repo.findOne({
      where: { codigoDane: data.codigoDane },
    });
    if (existePorCodigo) {
      omitidos++;
      continue;
    }
    const existePorNombre = await repo.findOne({
      where: { nombre: data.nombre },
    });
    if (existePorNombre) {
      omitidos++;
      continue;
    }
    await repo.save(repo.create(data));
    creados++;
  }

  console.log(`  Municipios: ${creados} creados, ${omitidos} ya existian`);
}
