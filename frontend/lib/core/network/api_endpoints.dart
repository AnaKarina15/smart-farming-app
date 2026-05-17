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
      // Si usas el EMULADOR, descomenta la línea de abajo:
      // return 'http://10.0.2.2:3000/api/v1';

      // Si usas el CELULAR FÍSICO, usa la IP local de tu PC (Wi-Fi: 192.168.0.14):
      return 'http://192.168.0.14:3000/api/v1';
    } else {
      // iOS, macOS o Windows Desktop
      return 'http://192.168.0.14:3000/api/v1';
    }
  }

  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/users/me';
  static const String avatar = '/users/me/avatar';
  static const String lotes = '/lotes';
  static String loteById(String id) => '/lotes/$id';
  static const String health = '/health';
  static const String weather = '/weather/current';

  // Sprint 3
  static const String siembras = '/siembras';
  static const String riego = '/riego';
  static const String fertilizacion = '/fertilizacion';
  static const String hallazgos = '/hallazgos';
  static const String tratamientos = '/tratamientos';
  static const String observaciones = '/observaciones';
}
