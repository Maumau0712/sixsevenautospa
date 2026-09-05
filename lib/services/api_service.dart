import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  static const String vehicleRegistrationUrl =
      'https://api.data.gov.my/data-catalogue'
      '?id=registrations_type_fuel'
      '&limit=20';

  static Future<List<dynamic>> getVehicleRegistrations() async {
    final response = await http.get(
      Uri.parse(vehicleRegistrationUrl),
    );

    if (response.statusCode == 200) {
      final dynamic data = jsonDecode(response.body);

      if (data is List) {
        return data;
      }

      return [];
    } else {
      throw Exception(
        'Failed to load government data.',
      );
    }
  }
}