class WeatherData {
  const WeatherData({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.pressure,
    required this.weatherCode,
    required this.isDay,
    required this.hourlyTimes,
    required this.hourlyTemperatures,
    required this.hourlyRainChance,
    required this.dailyTimes,
    required this.dailyMax,
    required this.dailyMin,
    required this.dailyCodes,
    required this.dailyRainChance,
    required this.sunrise,
    required this.sunset,
  });

  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int windDirection;
  final double pressure;
  final int weatherCode;
  final bool isDay;
  final List<String> hourlyTimes;
  final List<double> hourlyTemperatures;
  final List<int> hourlyRainChance;
  final List<String> dailyTimes;
  final List<double> dailyMax;
  final List<double> dailyMin;
  final List<int> dailyCodes;
  final List<int> dailyRainChance;
  final String sunrise;
  final String sunset;

  String get condition => conditionForCode(weatherCode);
  String get season {
    final month = DateTime.now().month;

    if (month == 12 || month <= 2) return 'Winter';
    if (month <= 5) return 'Spring';
    if (month <= 8) return 'Summer';
    return 'Autumn';
  }

  static String conditionForCode(int code) {
    if (code == 0) return 'Clear sky';
    if ([1, 2, 3].contains(code)) return 'Partly cloudy';
    if ([45, 48].contains(code)) return 'Foggy';
    if ([51, 53, 55, 56, 57].contains(code)) return 'Drizzle';
    if ([61, 63, 65, 66, 67, 80, 81, 82].contains(code)) return 'Rainy';
    if ([71, 73, 75, 77, 85, 86].contains(code)) return 'Snowy';
    if ([95, 96, 99].contains(code)) return 'Thunderstorm';
    return 'Changing conditions';
  }

  static WeatherData fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    final hourly = json['hourly'] as Map<String, dynamic>;
    final daily = json['daily'] as Map<String, dynamic>;

    List<double> doubles(String key) =>
        (hourly[key] as List).map((e) => (e as num).toDouble()).toList();
    List<int> ints(String key) =>
        (daily[key] as List).map((e) => (e as num).round()).toList();

    final times = (hourly['time'] as List).cast<String>();
    final now = DateTime.now();
    var start = times.indexWhere((t) {
      final d = DateTime.tryParse(t);
      return d != null && !d.isBefore(now.subtract(const Duration(hours: 1)));
    });
    if (start < 0) start = 0;
    final end = (start + 24).clamp(0, times.length).toInt();

    final dailyTimes = (daily['time'] as List).cast<String>();
    final dailyCodes =
        (daily['weather_code'] as List).map((e) => (e as num).round()).toList();

    return WeatherData(
      temperature: (current['temperature_2m'] as num).toDouble(),
      feelsLike: (current['apparent_temperature'] as num).toDouble(),
      humidity: (current['relative_humidity_2m'] as num).round(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      windDirection: (current['wind_direction_10m'] as num).round(),
      pressure: (current['surface_pressure'] as num).toDouble(),
      weatherCode: (current['weather_code'] as num).round(),
      isDay: (current['is_day'] as num).round() == 1,
      hourlyTimes: times.sublist(start, end),
      hourlyTemperatures: doubles('temperature_2m').sublist(start, end),
      hourlyRainChance: (hourly['precipitation_probability'] as List)
          .sublist(start, end)
          .map((e) => (e as num).round())
          .toList(),
      dailyTimes: dailyTimes,
      dailyMax: (daily['temperature_2m_max'] as List)
          .map((e) => (e as num).toDouble())
          .toList(),
      dailyMin: (daily['temperature_2m_min'] as List)
          .map((e) => (e as num).toDouble())
          .toList(),
      dailyCodes: dailyCodes,
      dailyRainChance: ints('precipitation_probability_max'),
      sunrise: (daily['sunrise'] as List).first as String,
      sunset: (daily['sunset'] as List).first as String,
    );
  }
}
