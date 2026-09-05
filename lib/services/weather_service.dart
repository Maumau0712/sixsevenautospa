import 'dart:convert';

import 'package:http/http.dart' as http;

class WeatherService {
  static Future<Map<String, dynamic>> getWeather({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.https(
      'api.open-meteo.com',
      '/v1/forecast',
      {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'current':
        'temperature_2m,apparent_temperature,relative_humidity_2m,precipitation,weather_code,wind_speed_10m',
        'hourly':
        'temperature_2m,weather_code,precipitation_probability',
        'daily':
        'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max',
        'timezone': 'auto',
        'forecast_days': '5',
      },
    );

    final response = await http
        .get(uri)
        .timeout(
      const Duration(seconds: 10),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load weather data.',
      );
    }

    final data =
    jsonDecode(response.body);

    if (data is Map<String, dynamic>) {
      return data;
    }

    throw Exception(
      'Invalid weather data received.',
    );
  }
}