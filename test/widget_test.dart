import 'package:flutter_test/flutter_test.dart';
import 'package:atmosphere_weather/models/place.dart';
import 'package:atmosphere_weather/models/weather.dart';

void main() {
  test('Place display name includes city and country', () {
    const place = Place(
      name: 'Hyderabad',
      admin1: 'Telangana',
      country: 'India',
      latitude: 17.385,
      longitude: 78.4867,
    );
    expect(place.displayName, 'Hyderabad, Telangana, India');
  });

  test('Weather code is converted to a readable condition', () {
    expect(WeatherData.conditionForCode(0), 'Clear sky');
    expect(WeatherData.conditionForCode(61), 'Rainy');
    expect(WeatherData.conditionForCode(71), 'Snowy');
  });
}


// A small widget test verifies that a reusable UI component renders correctly.
