/**
 * Fases agronomicas del ciclo de un cultivo.
 *
 * Usadas para activar reglas en momentos especificos del ciclo.
 * El motor calcula la fase actual del lote en base a la fecha
 * de la ultima siembra y los rangos definidos por cultivo.
 */
export enum FaseAgronomica {
  PREPARACION = 'preparacion',
  SIEMBRA = 'siembra',
  GERMINACION = 'germinacion',
  CRECIMIENTO_VEGETATIVO = 'crecimiento_vegetativo',
  PRE_FLORACION = 'pre_floracion',
  FLORACION = 'floracion',
  FRUCTIFICACION = 'fructificacion',
  MADURACION = 'maduracion',
  COSECHA = 'cosecha',
  POST_COSECHA = 'post_cosecha',
}
