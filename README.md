# Atmosphere — Flutter Weather App

A responsive Flutter Web weather application for the CM506 UI Design–Flutter laboratory.

## Included
- Seasonal landing page and animated weather scene
- City search using Open-Meteo Geocoding
- Interactive world map using OpenStreetMap
- Manual latitude/longitude selection and validation
- Live current weather, hourly forecast and 7-day forecast
- Weather metric cards, temperature chart and simple recommendations
- Favourite locations saved with SharedPreferences
- Two-city temperature comparison
- Responsive navigation rail (wide screens) and bottom navigation (small screens)
- Provider state management and reusable widgets

## Requirements
- Flutter SDK (stable channel)
- VS Code with Flutter and Dart extensions
- Internet connection

## Run
1. Extract the ZIP.
2. Open the `atmosphere_weather_app` folder in VS Code.
3. Run `flutter doctor` in the terminal and resolve any required setup.
4. Run `flutter pub get`.
5. Run `flutter run -d chrome`.

To build the web release:
```bash
flutter build web
```
The generated site will be in `build/web`.

## Notes
- Open-Meteo provides weather forecasts and geocoding. Its free API is intended for non-commercial use; review its current terms before public/commercial deployment.
- OpenStreetMap tiles require attribution. The map screen displays attribution.
- The app starts with Hyderabad as a demo location. The user can search another city, tap anywhere on the map, or enter coordinates.
- The map tap stores coordinates as a selected point. It does not reverse-geocode a tapped point into a street/city name.
- The recommendation engine is intentionally rule-based and educational, not medical advice.
- Air quality, severe-alert feeds, GPS auto-location and seasonal tree/snowman illustrations are not included in this starter version.

## Suggested practical demonstration
1. Open Discover and explain the responsive layout.
2. Open Explore location and search for Tokyo.
3. Select a result, then show the marker and coordinates on the map.
4. Enter coordinates manually and demonstrate validation with an invalid latitude.
5. Load the weather report and explain the weather cards, hourly list, 7-day list and graph.
6. Save the location, open My places, then remove it.
7. Open Compare and compare the current place with another city.
8. Resize the browser to demonstrate the responsive navigation and grids.

## Syllabus mapping
- Widgets/layouts: Container, Row, Column, Stack, ListView, GridView, Card, buttons
- Responsive UI: MediaQuery and LayoutBuilder
- Navigation: Navigator and MaterialPageRoute
- Animation: AnimationController, AnimatedBuilder and CustomPainter
- State: StatefulWidget, setState and Provider
- Reusable UI: MetricCard and WeatherScene
- Theme: ThemeData and ColorScheme
- Forms: TextFields and coordinate range validation
- REST API: HTTP requests to Open-Meteo
- Persistence: SharedPreferences

## Before submission
Run:
```bash
flutter analyze
flutter test
```
Take screenshots at desktop, tablet and mobile widths. Add your own widget tests before final submission.
