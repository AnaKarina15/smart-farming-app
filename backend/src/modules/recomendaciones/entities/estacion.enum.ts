/**
 * Estaciones climaticas relevantes para el Magdalena.
 *
 * No usamos primavera/verano/otono/invierno porque en la zona Caribe
 * colombiana no aplican. Lo que importa es seca vs lluviosa.
 */
export enum Estacion {
  SECA = 'seca', // Diciembre-Abril aprox en Magdalena
  LLUVIOSA = 'lluviosa', // Mayo-Noviembre aprox en Magdalena
  TRANSICION = 'transicion', // Periodos de cambio entre las dos
}
