import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/weather_provider.dart';
import '../widgets/metric_card.dart';
import '../widgets/weather_scene.dart';

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  String _time(String value) {
    final date = DateTime.tryParse(value);
    return date == null ? value : DateFormat('h:mm a').format(date);
  }

  String _advice(double temp, int rain, int uv) {
    final tips = <String>[];

    if (temp >= 32) {
      tips.add('Choose light clothing and drink water regularly.');
    }
    if (temp <= 12) {
      tips.add('A warm layer or jacket may make you more comfortable.');
    }
    if (rain >= 45) {
      tips.add('Rain is possible. Keep an umbrella handy.');
    }
    if (uv >= 6) {
      tips.add('UV levels are high. Use sunscreen and seek shade.');
    }
    if (tips.isEmpty) {
      tips.add('Conditions look comfortable for normal outdoor plans.');
    }

    return tips.join(' ');
  }

  // Automatically calculate season for Southern Hemisphere.
  String _southernSeason() {
    final month = DateTime.now().month;

    if (month == 12 || month <= 2) return 'Summer';
    if (month <= 5) return 'Autumn';
    if (month <= 8) return 'Winter';
    return 'Spring';
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<WeatherProvider>();
    final w = p.weather;
    final wide = MediaQuery.sizeOf(context).width > 850;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather report'),
        actions: [
          if (w != null)
            IconButton(
              tooltip: 'Save location',
              onPressed: () => p.addFavorite(p.selectedPlace),
              icon: Icon(
                p.isFavorite(p.selectedPlace)
                    ? Icons.bookmark
                    : Icons.bookmark_border,
              ),
            ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => p.loadWeather(p.selectedPlace),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: p.isLoading
          ? const Center(child: CircularProgressIndicator())
          : w == null
          ? Center(child: Text(p.error ?? 'No weather data available'))
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      p.selectedPlace.displayName,
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${p.selectedPlace.latitude.toStringAsFixed(3)}°, '
                      '${p.selectedPlace.longitude.toStringAsFixed(3)}°',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 16),

                    // Dynamic seasonal animated weather scene.
                    WeatherScene(
                      condition: w.condition,
                      isDay: w.isDay,
                      season: p.selectedPlace.latitude < 0
                          ? _southernSeason()
                          : w.season,
                      height: 225,
                    ),

                    const SizedBox(height: 14),

                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    w.condition,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text('Feels like ${w.feelsLike.round()}°C'),
                                ],
                              ),
                            ),
                            Text(
                              '${w.temperature.round()}°',
                              style: const TextStyle(
                                fontSize: 58,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      'Weather at a glance',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),

                    GridView.count(
                      crossAxisCount: wide ? 4 : 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: wide ? 1.45 : 1.55,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      children: [
                        MetricCard(
                          icon: Icons.water_drop_outlined,
                          label: 'Humidity',
                          value: '${w.humidity}%',
                          tint: Colors.blue,
                        ),
                        MetricCard(
                          icon: Icons.air,
                          label: 'Wind',
                          value: '${w.windSpeed.round()} km/h',
                          tint: Colors.teal,
                        ),
                        MetricCard(
                          icon: Icons.speed,
                          label: 'Pressure',
                          value: '${w.pressure.round()} hPa',
                          tint: Colors.deepPurple,
                        ),
                        MetricCard(
                          icon: Icons.explore_outlined,
                          label: 'Wind direction',
                          value: '${w.windDirection}°',
                          tint: Colors.orange,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      'Next 24 hours',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      height: 150,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: w.hourlyTimes.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, i) {
                          final time = DateTime.tryParse(w.hourlyTimes[i]);

                          return Container(
                            width: 88,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  time == null
                                      ? '--'
                                      : DateFormat('ha').format(time),
                                ),
                                const SizedBox(height: 10),
                                const Icon(
                                  Icons.wb_cloudy_outlined,
                                  color: Color(0xFF397D83),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${w.hourlyTemperatures[i].round()}°',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  '${w.hourlyRainChance[i]}% rain',
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      '7-day outlook',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: List.generate(w.dailyTimes.length, (i) {
                            final date = DateTime.tryParse(w.dailyTimes[i]);
                            final day = date == null
                                ? 'Day ${i + 1}'
                                : DateFormat('EEE, d MMM').format(date);

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              child: Row(
                                children: [
                                  Expanded(child: Text(day)),
                                  const Icon(
                                    Icons.cloud_outlined,
                                    color: Color(0xFF397D83),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '${w.dailyMin[i].round()}°',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '${w.dailyMax[i].round()}°',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Text('${w.dailyRainChance[i]}%'),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      'Temperature trend',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      height: 220,
                      padding: const EdgeInsets.fromLTRB(12, 18, 18, 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: true),
                          borderData: FlBorderData(show: false),
                          titlesData: const FlTitlesData(
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              isCurved: true,
                              color: const Color(0xFF397D83),
                              barWidth: 3,
                              dotData: const FlDotData(show: false),
                              spots: List.generate(
                                w.dailyMax.length,
                                (i) => FlSpot(i.toDouble(), w.dailyMax[i]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      'A little advice for your day',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5F0EB),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.tips_and_updates_outlined,
                            color: Color(0xFF397D83),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _advice(
                                w.temperature,
                                w.dailyRainChance.first,
                                0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),
                    Text(
                      'Sunrise ${_time(w.sunrise)} • '
                      'Sunset ${_time(w.sunset)}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Weather data: Open-Meteo. '
                      'Map data: © OpenStreetMap contributors.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
