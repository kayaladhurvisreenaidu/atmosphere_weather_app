import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../models/place.dart';

class CompareScreen extends StatefulWidget {
  const CompareScreen({super.key});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  Place? secondPlace;
  bool loading = false;
  String? result;
  final cityController = TextEditingController();

  static const Color accent = Color(0xFF397D83);

  @override
  void dispose() {
    cityController.dispose();
    super.dispose();
  }

  Widget glassCard(
      {required Widget child, EdgeInsets padding = const EdgeInsets.all(18)}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<WeatherProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Compare weather',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/seasons/spring.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: const Color(0xCFF4F7F5),
            ),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 30),
                  children: [
                    const Text(
                      'Two places.\nOne forecast.',
                      style: TextStyle(
                        fontSize: 30,
                        height: 1.15,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF244D50),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Discover how the weather differs between two locations.',
                      style: TextStyle(
                        color: Colors.blueGrey.shade700,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Current location
                    glassCard(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.13),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.location_on_rounded,
                              color: accent,
                              size: 27,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.selectedPlace.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF244D50),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Your current report location',
                                  style: TextStyle(
                                    color: Colors.blueGrey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            p.weather == null
                                ? '--'
                                : '${p.weather!.temperature.round()}°',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: accent,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    const Text(
                      'Choose another location',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF244D50),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Search field
                    glassCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      child: TextField(
                        controller: cityController,
                        onChanged: (value) => p.search(value),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Search a city, e.g. London',
                          prefixIcon: Icon(Icons.search, color: accent),
                        ),
                      ),
                    ),

                    if (p.searchResults.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      glassCard(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Column(
                          children: p.searchResults.take(5).map((place) {
                            return ListTile(
                              title: Text(
                                place.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              subtitle: Text(place.displayName),
                              trailing: const Icon(
                                Icons.add_circle_outline,
                                color: accent,
                              ),
                              onTap: () {
                                setState(() {
                                  secondPlace = place;
                                  result = null;
                                  cityController.clear();
                                });
                                FocusScope.of(context).unfocus();
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ],

                    if (secondPlace != null) ...[
                      const SizedBox(height: 16),
                      glassCard(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.place_rounded,
                              color: accent,
                              size: 27,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    secondPlace!.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      color: Color(0xFF244D50),
                                    ),
                                  ),
                                  Text(
                                    secondPlace!.displayName,
                                    style: const TextStyle(
                                      color: Colors.blueGrey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  secondPlace = null;
                                  result = null;
                                });
                              },
                              icon: const Icon(
                                Icons.close_rounded,
                                color: Colors.blueGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 22),

                    // Compare button
                    SizedBox(
                      height: 54,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17),
                          ),
                        ),
                        onPressed: secondPlace == null || loading
                            ? null
                            : () async {
                                setState(() {
                                  loading = true;
                                  result = null;
                                });

                                try {
                                  final data = await context
                                      .read<WeatherProvider>()
                                      .weatherForComparison(secondPlace!);

                                  if (!mounted) return;

                                  final difference = (data.temperature -
                                          (p.weather?.temperature ??
                                              data.temperature))
                                      .abs();

                                  setState(() {
                                    result = '${secondPlace!.name}: '
                                        '${data.temperature.round()}°C · '
                                        '${data.condition}\n\n'
                                        'Temperature difference: '
                                        '${difference.toStringAsFixed(1)}°C';
                                  });
                                } catch (e) {
                                  if (mounted) {
                                    setState(() {
                                      result =
                                          'Could not load comparison weather.';
                                    });
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() => loading = false);
                                  }
                                }
                              },
                        icon: loading
                            ? const SizedBox(
                                width: 19,
                                height: 19,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.compare_arrows_rounded),
                        label: Text(
                          loading ? 'Comparing...' : 'Compare locations',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),

                    if (result != null) ...[
                      const SizedBox(height: 20),
                      glassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.analytics_outlined,
                                  color: accent,
                                ),
                                SizedBox(width: 9),
                                Text(
                                  'Comparison result',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF244D50),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              result!,
                              style: const TextStyle(
                                height: 1.6,
                                fontSize: 15,
                                color: Color(0xFF34585A),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
