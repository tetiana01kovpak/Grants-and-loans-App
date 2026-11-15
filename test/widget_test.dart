import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:grant_compass/main.dart';

void main() {
  test('every opportunity has facts and every cutoff has a calendar date', () {
    for (final o in allOpportunities) {
      expect(facts.containsKey(o.title), isTrue);
    }
    for (final title in cutoffUtc.keys) {
      expect(allOpportunities.firstWhere((o) => o.title == title).calendarDate, isNotNull);
    }
  });

  test('opportunities past their cutoff are hidden', () {
    expect(opportunitiesAt(DateTime.utc(2026, 11, 14)).length, cutoffUtc.length);
    expect(opportunitiesAt(DateTime.utc(2026, 12, 3)).map((o) => o.title), isNot(contains('Baltic Marine Watchdog Challenge')));
    expect(opportunitiesAt(DateTime.utc(2028)), isEmpty);
  });

  testWidgets('app lists loans and opens a detail page', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 3000));
    await tester.pumpWidget(const GrantApp());
    expect(find.text('HBOR loan for inventions'), findsOneWidget);
    await tester.tap(find.text('EIC Accelerator'));
    await tester.pumpAndSettle();
    expect(find.text('Funding at a glance'), findsOneWidget);
  });
}
