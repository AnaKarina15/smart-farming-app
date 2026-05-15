import 'dart:convert';
import 'package:http/http.dart' as http;
import '../network/api_endpoints.dart';

class WeatherService {
  /// Fetches the current temperature for the given latitude and longitude via the backend.
  /// Returns the temperature as a formatted string (e.g., "24°C").
  /// If the request fails, it returns a fallback value or an error string.
  Future<String> getCurrentTemperature(double lat, double lon) async {
    try {
      final url = Uri.parse(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.weather}?lat=$lat&lon=$lon',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // The backend returns { "data": { "temperature": "28°C" } } because of TransformInterceptor
        if (data['data'] != null && data['data']['temperature'] != null) {
          return data['data']['temperature'];
        }
        return '--°C';
      } else {
        return '--°C';
      }
    } catch (e) {
      // In case of any error (e.g. no internet), return a placeholder
      return '--°C';
    }
  }
}

