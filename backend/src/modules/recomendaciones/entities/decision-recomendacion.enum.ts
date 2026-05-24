/**
 * Decision del productor cuando se le muestra una recomendacion.
 *
 * Marco etico AgroField: el sistema sugiere, el productor decide.
 * Cada decision queda registrada en recomendaciones_aplicadas
 * para auditoria y mejora del sistema experto.
 */
export enum DecisionRecomendacion {
  APLICADA = 'aplicada', // El productor aplico la recomendacion como se sugiere
  IGNORADA = 'ignorada', // El productor decidio no aplicarla
  APLICADA_DIFERENTE = 'aplicada_diferente', // Aplico algo similar pero no exacto
}
