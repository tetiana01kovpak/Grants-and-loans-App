import 'dart:ui';
import 'package:flutter/material.dart';
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
    expect(find.text('HBOR loan for digital transition'), findsOneWidget);
    await tester.tap(find.text('EIC Accelerator'));
    await tester.pumpAndSettle();
    expect(find.text('Funding at a glance'), findsOneWidget);
  });

  test('listed grants have documents, stages, rules and a valid funding split', () {
    for (final title in cutoffUtc.keys) {
      final f = facts[title]!;
      expect(f.documentList, isNotEmpty, reason: title);
      expect(f.stages, isNotEmpty, reason: title);
      expect(f.rules, isNotEmpty, reason: title);
      if (f.fundedPercent != null || f.ownPercent != null) {
        expect(f.fundedPercent! + f.ownPercent!, 100, reason: title);
      } else {
        expect(f.splitNote, isNotEmpty, reason: title);
      }
    }
  });

  testWidgets('detail page shows split, stages, rules and document checklist', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 6000));
    await tester.pumpWidget(MaterialApp(home: Detail(allOpportunities.firstWhere((o) => o.title == 'EIC Accelerator'))));
    expect(find.text('Who pays what'), findsOneWidget);
    expect(find.text('Grant covers: 70%'), findsOneWidget);
    expect(find.text('Your own budget: 30%'), findsOneWidget);
    expect(find.text('Stages'), findsOneWidget);
    expect(find.text('Rules'), findsOneWidget);
    expect(find.text('Documents you need'), findsOneWidget);
    expect(find.text('0 / 9 ready'), findsOneWidget);
    await tester.tap(find.byType(Checkbox).first);
    await tester.pump();
    expect(find.text('1 / 9 ready'), findsOneWidget);
  });

  test('each deadline gets separate 30/21/14-day reminder events', () {
    final items = calendarItems();
    for (final o in opportunities.where((o) => o.calendarDate != null)) {
      final deadline = o.calendarDate!.millisecondsSinceEpoch;
      final own = items.where((i) => (i['description'] as String).contains('Grant Compass ID: ${o.title}')).toList();
      expect(own.length, 4);
      expect(own.where((i) => i['alert'] == false).single['time'], deadline);
      for (final days in [30, 21, 14]) {
        final reminder = own.singleWhere((i) => i['id'] == '${o.title} | $days days');
        expect(reminder['alert'], isTrue);
        expect(reminder['title'], '$days days left: ${o.title}');
        expect(reminder['time'], deadline - Duration(days: days).inMilliseconds);
      }
    }
  });
}
