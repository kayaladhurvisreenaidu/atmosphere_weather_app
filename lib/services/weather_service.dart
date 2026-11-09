import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/place.dart';
import '../models/weather.dart';

class WeatherService {
  static const _geocoding = 'https://geocoding-api.open-meteo.com/v1/search';
  static const _forecast = 'https://api.open-meteo.com/v1/forecast';

  Future<List<Place>> searchPlaces(String query) async {
    if (query.trim().length < 2) return [];
    final uri = Uri.parse(_geocoding).replace(queryParameters: {
      'name': query.trim(),
      'count': '8',
      'language': 'en',
      'format': 'json',
    });
    final response = await http.get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw Exception('Could not search locations. Try again.');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final results = (body['results'] as List? ?? []);
    return results.map((item) => Place.fromJson(item)).toList();
  }

  Future<WeatherData> getWeather(Place place) async {
    final uri = Uri.parse(_forecast).replace(queryParameters: {
      'latitude': place.latitude.toString(),
      'longitude': place.longitude.toString(),
      'current': 'temperature_2m,relative_humidity_2m,apparent_temperature,'
          'is_day,weather_code,wind_speed_10m,wind_direction_10m,surface_pressure',
      'hourly': 'temperature_2m,precipitation_probability',
      'daily': 'weather_code,temperature_2m_max,temperature_2m_min,'
          'precipitation_probability_max,sunrise,sunset',
      'timezone': 'auto',
      'forecast_days': '7',
    });
    final response = await http.get(uri).timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw Exception('Weather service is unavailable. Please retry.');
    }
    return WeatherData.fromJson(jsonDecode(response.body));
  }
}
