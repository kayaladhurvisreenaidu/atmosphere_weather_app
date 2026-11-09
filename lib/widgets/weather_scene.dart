import 'dart:math' as math;
import 'package:flutter/material.dart';

class WeatherScene extends StatefulWidget {
  const WeatherScene({
    super.key,
    required this.condition,
    required this.isDay,
    this.season = 'Summer',
    this.height = 210,
  });

  final String condition;
  final bool isDay;
  final String season;
  final double height;

  @override
  State<WeatherScene> createState() => _WeatherSceneState();
}

class _WeatherSceneState extends State<WeatherScene>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final condition = widget.condition.toLowerCase();
    final season = widget.season.toLowerCase();

    final rainy = condition.contains('rain') ||
        condition.contains('drizzle') ||
        condition.contains('thunder');

    final snowy = condition.contains('snow') ||
        condition.contains('sleet') ||
        condition.contains('blizzard');

    final cloudy = condition.contains('cloud') ||
        condition.contains('fog') ||
        condition.contains('mist') ||
        condition.contains('overcast');

    final sunny = !rainy && !snowy && !cloudy;

    final colors = !widget.isDay
        ? [const Color(0xFF172B49), const Color(0xFF344B68)]
        : rainy
            ? [const Color(0xFF526D83), const Color(0xFF9BB4C0)]
            : snowy
                ? [const Color(0xFF91B8C9), const Color(0xFFDCE8EA)]
                : season == 'autumn'
                    ? [const Color(0xFF9D6249), const Color(0xFFE9B77C)]
                    : season == 'spring'
                        ? [const Color(0xFF79B9A1), const Color(0xFFE8D5B8)]
                        : season == 'winter'
                            ? [const Color(0xFF83AFC5), const Color(0xFFDCE8EA)]
                            : [
                                const Color(0xFF429BA9),
                                const Color(0xFFE7C99C)
                              ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final progress = controller.value;

            return Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                // BACKGROUND
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: colors,
                      ),
                    ),
                  ),
                ),

                // MOON AT NIGHT
                if (!widget.isDay)
                  Positioned(
                    right: 55,
                    top: 35,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFFFE8B0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: .35),
                            blurRadius: 40,
                            spreadRadius: 12,
                          ),
                        ],
                      ),
                    ),
                  ),

                // TWINKLING STARS
                if (!widget.isDay)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _StarPainter(progress: progress),
                    ),
                  ),

                // SUMMER SUN
                if (season == 'summer' && widget.isDay && sunny)
                  Positioned(
                    right: 55,
                    top: 35,
                    child: Container(
                      width: 75,
                      height: 75,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFFFE6A3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withValues(alpha: .45),
                            blurRadius: 40,
                            spreadRadius: 12,
                          ),
                        ],
                      ),
                    ),
                  ),

                // ROTATING SUN RAYS
                if (season == 'summer' && widget.isDay && sunny)
                  Positioned(
                    right: 30,
                    top: 10,
                    child: Transform.rotate(
                      angle: progress * 2 * math.pi,
                      child: CustomPaint(
                        size: const Size(125, 125),
                        painter: _SunPainter(),
                      ),
                    ),
                  ),

                // AUTUMN TREE
                if (season == 'autumn')
                  Positioned(
                    right: 20,
                    bottom: 12,
                    child: Icon(
                      Icons.park,
                      size: 155,
                      color: const Color(0xFF794A2D).withValues(alpha: .9),
                    ),
                  ),

                // FALLING AUTUMN LEAVES
                if (season == 'autumn')
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _SeasonParticlePainter(
                        progress: progress,
                        type: 'autumn',
                      ),
                    ),
                  ),

                // SPRING FLOWERS
                if (season == 'spring')
                  Positioned(
                    right: 30,
                    bottom: 12,
                    child: const Icon(
                      Icons.local_florist,
                      size: 130,
                      color: Color(0xFFFFD0E0),
                    ),
                  ),

                // FLOATING SPRING PETALS
                if (season == 'spring')
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _SeasonParticlePainter(
                        progress: progress,
                        type: 'spring',
                      ),
                    ),
                  ),

                // WINTER SNOWMAN
                if (season == 'winter' || snowy)
                  const Positioned(
                    right: 35,
                    bottom: 12,
                    child: _Snowman(),
                  ),

                // DRIFTING CLOUDS
                if (cloudy || rainy)
                  Positioned(
                    left: 25 + math.sin(progress * 2 * math.pi) * 15,
                    top: 35,
                    child: Icon(
                      Icons.cloud,
                      size: 105,
                      color: Colors.white.withValues(alpha: .8),
                    ),
                  ),

                if (cloudy || rainy)
                  Positioned(
                    right: 100 - math.sin(progress * 2 * math.pi) * 12,
                    top: 75,
                    child: Icon(
                      Icons.cloud,
                      size: 75,
                      color: Colors.white.withValues(alpha: .55),
                    ),
                  ),

                // RAIN
                if (rainy)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _SeasonParticlePainter(
                        progress: progress,
                        type: 'rain',
                      ),
                    ),
                  ),

                // SNOWFALL
                if (snowy)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _SeasonParticlePainter(
                        progress: progress,
                        type: 'snow',
                      ),
                    ),
                  ),

                // WEATHER CONDITION
                Positioned(
                  left: 22,
                  bottom: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.condition,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              blurRadius: 8,
                              color: Colors.black26,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.season.toUpperCase()} SEASON',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),

                // DAY / NIGHT LABEL
                Positioned(
                  right: 20,
                  bottom: 20,
                  child: Text(
                    widget.isDay ? 'DAYTIME' : 'NIGHT SKY',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// SUN RAYS
class _SunPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFE6A3).withValues(alpha: .6)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < 12; i++) {
      final angle = i * math.pi / 6;

      canvas.drawLine(
        Offset(
          center.dx + math.cos(angle) * 45,
          center.dy + math.sin(angle) * 45,
        ),
        Offset(
          center.dx + math.cos(angle) * 59,
          center.dy + math.sin(angle) * 59,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// NIGHT STARS
class _StarPainter extends CustomPainter {
  final double progress;

  _StarPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (int i = 0; i < 35; i++) {
      final x = (i * 83.0) % size.width;
      final y = (i * 47.0) % (size.height * .75);

      paint.color = Colors.white.withValues(
        alpha: .35 + (math.sin(progress * 2 * math.pi + i) + 1) * .3,
      );

      canvas.drawCircle(
        Offset(x, y),
        i % 4 == 0 ? 2 : 1,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StarPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// WEATHER AND SEASON PARTICLES
class _SeasonParticlePainter extends CustomPainter {
  _SeasonParticlePainter({
    required this.progress,
    required this.type,
  });

  final double progress;
  final String type;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final paint = Paint()..strokeCap = StrokeCap.round;

    for (int i = 0; i < 30; i++) {
      final x =
          (i * 47.0 + math.sin(progress * 2 * math.pi + i) * 25) % size.width;

      final y =
          (i * 31.0 + progress * size.height * (type == 'rain' ? 1.8 : .8)) %
              size.height;

      if (type == 'rain') {
        paint
          ..color = Colors.white.withValues(alpha: .55)
          ..strokeWidth = 1.8;

        canvas.drawLine(
          Offset(x, y),
          Offset(x - 5, y + 14),
          paint,
        );
      } else if (type == 'snow') {
        paint.color = Colors.white.withValues(alpha: .85);

        canvas.drawCircle(
          Offset(x, y),
          2.5 + (i % 3),
          paint,
        );
      } else if (type == 'autumn') {
        paint.color = [
          const Color(0xFFFFB347),
          const Color(0xFFE76F32),
          const Color(0xFFFFD166),
        ][i % 3];

        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(progress * 8 + i);

        canvas.drawOval(
          Rect.fromCenter(
            center: Offset.zero,
            width: 10,
            height: 6,
          ),
          paint,
        );

        canvas.restore();
      } else if (type == 'spring') {
        paint.color = [
          const Color(0xFFFFC1D6),
          const Color(0xFFFFE4A8),
          Colors.white,
        ][i % 3];

        canvas.drawCircle(
          Offset(x, y),
          3 + (i % 2),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SeasonParticlePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.type != type;
  }
}

// SNOWMAN
class _Snowman extends StatelessWidget {
  const _Snowman();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 85,
      height: 110,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          Positioned(
            bottom: 52,
            child: Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const Positioned(
            bottom: 77,
            child: Icon(
              Icons.face,
              size: 27,
              color: Color(0xFF34495E),
            ),
          ),
          Positioned(
            bottom: 100,
            child: Container(
              width: 38,
              height: 9,
              color: const Color(0xFF34495E),
            ),
          ),
        ],
      ),
    );
  }
}
