import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:atmosphere_weather/widgets/metric_card.dart';

void main() {
  testWidgets('MetricCard displays its label and value', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MetricCard(
            icon: Icons.water_drop,
            label: 'Humidity',
            value: '68%',
            tint: Colors.blue,
          ),
        ),
      ),
    );

    expect(find.text('Humidity'), findsOneWidget);
    expect(find.text('68%'), findsOneWidget);
  });
}
