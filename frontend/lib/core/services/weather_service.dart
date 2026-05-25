import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../network/api_endpoints.dart';
import '../storage/token_storage.dart';

class WeatherService {
  final TokenStorage _tokenStorage = TokenStorage();

  /// Fetches weather data (temperature and rain probability) for the given coordinates via the backend.
  Future<Map<String, String>> getWeatherData(double lat, double lon) async {
    try {
      final token = await _tokenStorage.getAccessToken();
      final url = Uri.parse(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.weather}?lat=$lat&lon=$lon',
      );
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = json.decode(response.body) as Map<String, dynamic>;
        final data = body['data'] as Map<String, dynamic>?;
        final actual = data?['actual'] as Map<String, dynamic>?;
        if (actual != null) {
          final temperature = (actual['temperatura'] as num?)?.toDouble();
          final rainProbability =
              (actual['probabilidadLluvia'] as num?)?.toDouble();
          return {
            'temperature':
                temperature != null ? '${temperature.round()}°C' : '--°C',
            'rainProbability':
                rainProbability != null ? '${rainProbability.round()}%' : '--%',
          };
        }
      }
      if (kDebugMode) {
        debugPrint(
          '[WeatherService] Error ${response.statusCode}: ${response.body}',
        );
      }
      return {'temperature': '--°C', 'rainProbability': '--%'};
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[WeatherService] No se pudo obtener clima: $e');
      }
      return {'temperature': '--°C', 'rainProbability': '--%'};
    }
  }
}
