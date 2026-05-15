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
 *
 * - ADMINISTRADOR: Super-usuario del sistema. Gestiona usuarios, recupera
 *   cuentas, supervisa el sistema, gestiona catalogos y configuraciones.
 *   Acceso completo de lectura/escritura sobre todos los recursos.
 */
export enum UserRole {
  PEQUENO_PRODUCTOR = 'pequeno_productor',
  TRABAJADOR = 'trabajador',
  GESTOR = 'gestor',
  ADMINISTRADOR = 'administrador',
}
