import 'package:flutter_test/flutter_test.dart';
import 'package:smart_farming/core/network/api_endpoints.dart';

void main() {
  test('uses API_BASE_URL from dart define when provided', () {
    const configuredBaseUrl = String.fromEnvironment('API_BASE_URL');

    if (configuredBaseUrl.isNotEmpty) {
      expect(ApiEndpoints.baseUrl, configuredBaseUrl);
    }

    expect(ApiEndpoints.baseUrl, endsWith('/api/v1'));
  });
}
