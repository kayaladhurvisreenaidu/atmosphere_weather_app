import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/place.dart';
import '../models/weather.dart';
import '../services/weather_service.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService _service = WeatherService();

  Place selectedPlace = const Place(
    name: 'Hyderabad',
    admin1: 'Telangana',
    country: 'India',
    latitude: 17.3850,
    longitude: 78.4867,
  );
  WeatherData? weather;
  List<Place> searchResults = [];
  List<Place> favorites = [];
  bool isLoading = false;
  bool isSearching = false;
  String? error;

  Future<void> initialize() async {
    await _loadFavorites();
    await loadWeather(selectedPlace);
  }

  Future<void> search(String query) async {
    isSearching = true;
    error = null;
    notifyListeners();
    try {
      searchResults = await _service.searchPlaces(query);
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      searchResults = [];
    } finally {
      isSearching = false;
      notifyListeners();
    }
  }

  Future<void> loadWeather(Place place) async {
    selectedPlace = place;
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      weather = await _service.getWeather(place);
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addFavorite(Place place) async {
    if (favorites.any((p) =>
        p.latitude == place.latitude && p.longitude == place.longitude)) {
      return;
    }
    favorites = [...favorites, place];
    await _saveFavorites();
    notifyListeners();
  }

  Future<void> removeFavorite(Place place) async {
    favorites = favorites.where((p) =>
        !(p.latitude == place.latitude && p.longitude == place.longitude)).toList();
    await _saveFavorites();
    notifyListeners();
  }

  bool isFavorite(Place place) => favorites.any((p) =>
      p.latitude == place.latitude && p.longitude == place.longitude);

  Future<WeatherData> weatherForComparison(Place place) =>
      _service.getWeather(place);

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('atmosphere_favorites') ?? [];
    favorites = saved.map((s) =>
        Place.fromJson(jsonDecode(s) as Map<String, dynamic>)).toList();
    notifyListeners();
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'atmosphere_favorites',
      favorites.map((p) => jsonEncode(p.toJson())).toList(),
    );
  }
}
