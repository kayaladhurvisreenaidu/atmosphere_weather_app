import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/weather_provider.dart';
import '../widgets/weather_scene.dart';
import 'location_screen.dart';
import 'weather_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width > 900 ? 42.0 : 20.0;
    final w = p.weather;

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/seasons/spring.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Soft overlay for readability
          Positioned.fill(
            child: Container(
              color: const Color(0xCFF4F7F5),
            ),
          ),

          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(horizontal, 24, horizontal, 30),
                  children: [
                    // Header
                    Row(
                      children: [
                        const Icon(
                          Icons.wb_twilight,
                          color: Color(0xFF397D83),
                          size: 30,
                        ),
                        const SizedBox(width: 9),
                        const Text(
                          'atmosphere',
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LocationScreen(),
                            ),
                          ),
                          icon: const Icon(Icons.public),
                          label: const Text('Explore location'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    Text(
                      'A little closer to the sky.',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Discover the weather, wherever your day takes you.',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Animated weather scene
                    if (w != null)
                      InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const WeatherScreen(),
                          ),
                        ),
                        child: WeatherScene(
                          condition: w.condition,
                          isDay: w.isDay,
                          season: p.selectedPlace.latitude < 0
                              ? _southernSeason()
                              : w.season,
                          height: 225,
                        ),
                      )
                    else
                      Container(
                        height: 225,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDDEAE6),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: p.isLoading
                            ? const CircularProgressIndicator()
                            : Text(
                                p.error ?? 'Weather is not available yet',
                              ),
                      ),

                    const SizedBox(height: 16),

                    // Location and temperature card
                    if (w != null)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.82),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: Color(0xFF397D83),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.selectedPlace.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 17,
                                    ),
                                  ),
                                  Text(
                                    p.selectedPlace.country,
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${w.temperature.round()}°',
                              style: const TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(w.condition),
                          ],
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Daily thought
                    const Text(
                      'A thought for today',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: const Color(0xDDE7EFEB),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      child: const Text(
                        '“Somewhere, the sun is always finding its way through.”',
                        style: TextStyle(
                          fontSize: 17,
                          height: 1.45,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF315F5C),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Seasonal cards heading
                    const Text(
                      'Explore the seasons',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 14),

                    LayoutBuilder(
                      builder: (context, constraints) {
                        final count = constraints.maxWidth > 700 ? 4 : 2;

                        final seasons = [
                          (
                            'Spring',
                            'Fresh beginnings',
                            Icons.local_florist,
                            'assets/images/seasons/spring.jpg'
                          ),
                          (
                            'Summer',
                            'Chase the sunshine',
                            Icons.wb_sunny,
                            'assets/images/seasons/summer.jpg'
                          ),
                          (
                            'Autumn',
                            'A beautiful change',
                            Icons.park,
                            'assets/images/seasons/autumn.jpg'
                          ),
                          (
                            'Winter',
                            'A quieter kind of magic',
                            Icons.ac_unit,
                            'assets/images/seasons/winter.jpg'
                          ),
                        ];

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: seasons.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: count,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 1.45,
                          ),
                          itemBuilder: (context, index) {
                            final s = seasons[index];

                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.12),
                                    blurRadius: 12,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(22),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.asset(
                                      s.$4,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                        color: const Color(0xFFDDEAE6),
                                        child: const Icon(
                                          Icons.image_not_supported,
                                          size: 35,
                                        ),
                                      ),
                                    ),
                                    DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black
                                                .withValues(alpha: 0.75),
                                          ],
                                          stops: const [0.25, 1.0],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Icon(
                                            s.$3,
                                            color: Colors.white,
                                            size: 27,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            s.$1,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          Text(
                                            s.$2,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Explore button
                    FilledButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LocationScreen(),
                        ),
                      ),
                      icon: const Icon(Icons.explore),
                      label: const Padding(
                        padding: EdgeInsets.all(13),
                        child: Text('Explore weather anywhere'),
                      ),
                    ),
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
