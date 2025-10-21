import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_analyzer/models/blood_report.dart';
import 'package:health_analyzer/views/screens/report_details_screen.dart';

void main() {
  testWidgets('ReportDetailsScreen renders summary and AI section controls',
      (tester) async {
    final report = BloodReport(
      id: 1,
      profileId: 42,
      testDate: DateTime(2025, 1, 15),
      labName: 'City Lab',
      // no parameters to avoid heavy UI, just smoke test basic sections
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ReportDetailsScreen(
          report: report,
          profileName: 'John Doe',
        ),
      ),
    );

    // Summary and meta
    expect(find.textContaining('AI Health Analysis'), findsOneWidget);
    expect(find.text('View AI Analysis'), findsOneWidget);
    // Ensure the "More" menu button exists
    expect(find.byIcon(Icons.more_vert), findsOneWidget);
  });
}