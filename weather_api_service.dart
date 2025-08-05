// lib/services/weather_api_service.dart (REPLACE WITH THIS - VERCEL VERSION)

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class WeatherApiService {
  // ======== THIS IS YOUR LIVE, PUBLIC VERCEL SERVER URL ========
  final String _serverUrl = 'https://smart-farming-api-weld.vercel.app';
  // =============================================================

  Future<Map<String, dynamic>> fetchWeather(String city) async {
    // Construct the full URL with the city query parameter
    final Uri url = Uri.parse('$_serverUrl/weather?city=$city');
    debugPrint("Calling our Vercel server at: $url");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to load weather data');
      }
    } catch (e) {
      debugPrint("Weather API Service General Error: $e");
      throw Exception('Failed to connect to the server.');
    }
  }
}