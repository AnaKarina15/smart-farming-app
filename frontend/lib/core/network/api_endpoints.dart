import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiEndpoints {
  // Usamos un getter para que la URL se decida en tiempo de ejecución
  static String get baseUrl {
    if (kIsWeb) {
      // Si es navegador (Chrome/Edge)
      return 'http://localhost:3000/api/v1';
    } else if (Platform.isAndroid) {
      // --- CONFIGURACIÓN PARA ANDROID ---
      // Si usas el EMULADOR, descomenta la línea de abajo y comenta la otra.
      // return 'http://10.0.2.2:3000/api/v1';

      // Si usas el CELULAR FÍSICO (con la ip correcta), usa esta:
      return 'http://192.168.0.11:3000/api/v1';
    } else {
      // iOS, macOS o Windows Desktop
      return 'http://192.168.0.11:3000/api/v1';
    }
  }

  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/users/me';
  static const String lotes = '/lotes';
  static String loteById(String id) => '/lotes/$id';
  static const String health = '/health';
}
