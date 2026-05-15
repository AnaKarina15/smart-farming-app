import 'dart:convert';
import 'package:http/http.dart' as http;
import '../network/api_endpoints.dart';

class WeatherService {
  /// Fetches weather data (temperature and rain probability) for the given coordinates via the backend.
  Future<Map<String, String>> getWeatherData(double lat, double lon) async {
    try {
      final url = Uri.parse(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.weather}?lat=$lat&lon=$lon',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null) {
          return {
            'temperature': data['data']['temperature'] ?? '--°C',
            'rainProbability': data['data']['rainProbability'] ?? '--%',
          };
        }
      }
      return {'temperature': '--°C', 'rainProbability': '--%'};
    } catch (e) {
      return {'temperature': '--°C', 'rainProbability': '--%'};
    }
  }
}

