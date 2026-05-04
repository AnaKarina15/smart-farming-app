/**
 * Roles definidos en la Fase 1 - Identificacion de Stakeholders.
 *
 * - PEQUENO_PRODUCTOR: Usuario principal, agricultor con parcelas <5ha.
 *   Tiene un alto conocimiento empirico pero baja alfabetizacion digital.
 *   Tomador de decisiones final.
 *
 * - TRABAJADOR: Usuario secundario (jornalero). Confirma tareas operativas
 *   sugeridas por la plataforma (riego, fumigacion, fertilizacion).
 *
 * - GESTOR: Usuario administrativo (representante de asociaciones rurales).
 *   Accede a datos agregados y anonimizados para planificar apoyos.
 */
export enum UserRole {
  PEQUENO_PRODUCTOR = 'pequeno_productor',
  TRABAJADOR = 'trabajador',
  GESTOR = 'gestor',
}
