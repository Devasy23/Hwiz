import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_analyzer/theme/theme_extensions.dart';

class _Probe extends StatelessWidget {
  const _Probe();
  @override
  Widget build(BuildContext context) {
    // Validate primaryColor maps to ColorScheme.primary
    expect(context.primaryColor, Theme.of(context).colorScheme.primary);
    // Validate semantic colors in light mode
    expect(context.successColor, const Color(0xFF10B981));
    expect(context.warningColor, const Color(0xFFF59E0B));
    expect(context.infoColor, const Color(0xFF3B82F6));
    return const SizedBox.shrink();
  }
}

class _ProbeDark extends StatelessWidget {
  const _ProbeDark();
  @override
  Widget build(BuildContext context) {
    // Validate semantic colors in dark mode
    expect(context.successColor, const Color(0xFF34D399));
    expect(context.warningColor, const Color(0xFFFBBF24));
    expect(context.infoColor, const Color(0xFF60A5FA));
    return const SizedBox.shrink();
  }
}

void main() {
  testWidgets('ThemeExtensions work in light mode', (tester) async {
    final theme = ThemeData.from(colorScheme: const ColorScheme.light());
    await tester.pumpWidget(MaterialApp(theme: theme, home: const _Probe()));
  });

  testWidgets('ThemeExtensions work in dark mode', (tester) async {
    final theme = ThemeData.from(colorScheme: const ColorScheme.dark());
    await tester.pumpWidget(MaterialApp(theme: theme, home: const _ProbeDark()));
  });
}