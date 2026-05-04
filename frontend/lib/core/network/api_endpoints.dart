/// URLs centralizadas del backend AgroField.
///
/// IMPORTANTE: Cambia [baseUrl] segun donde corras la app:
/// - Chrome web: 'http://localhost:3000/api/v1'
/// - Emulador Android: 'http://10.0.2.2:3000/api/v1' (Android mapea localhost del PC)
/// - Celular fisico: 'http://TU_IP_LOCAL:3000/api/v1' (ej. http://192.168.1.10:3000/api/v1)
class ApiEndpoints {
  static const String baseUrl = 'http://localhost:3000/api/v1';

  // ==================== AUTH ====================
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';

  // ==================== USERS ====================
  static const String me = '/users/me';

  // ==================== LOTES ====================
  static const String lotes = '/lotes';
  static String loteById(String id) => '/lotes/$id';

  // ==================== HEALTH ====================
  static const String health = '/health';
}
