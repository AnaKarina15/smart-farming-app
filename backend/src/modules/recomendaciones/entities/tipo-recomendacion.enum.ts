/**
 * Categoria de la recomendacion generada por el motor.
 *
 * Coincide con las 6 categorias del catalogo de reglas agronomicas:
 * - riego: cuando regar y cuanto
 * - fertilizacion: cuando fertilizar y dosis
 * - fitosanitario_plaga: tratamiento contra insectos plaga
 * - fitosanitario_enfermedad: tratamiento contra hongos/bacterias/virus
 * - manejo_cultural: practicas culturales (rotacion, densidad, encalado)
 * - transversal: reglas generales aplicables a cualquier cultivo
 */
export enum TipoRecomendacion {
  RIEGO = 'riego',
  FERTILIZACION = 'fertilizacion',
  FITOSANITARIO_PLAGA = 'fitosanitario_plaga',
  FITOSANITARIO_ENFERMEDAD = 'fitosanitario_enfermedad',
  MANEJO_CULTURAL = 'manejo_cultural',
  TRANSVERSAL = 'transversal',
}
