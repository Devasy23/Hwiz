import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'theme/app_theme.dart';
import 'viewmodels/settings_viewmodel.dart';
import 'viewmodels/profile_viewmodel.dart';
import 'viewmodels/report_viewmodel.dart';
import 'views/screens/main_shell.dart';

void main() {
  runApp(const LabLensApp());
}

class LabLensApp extends StatelessWidget {
  const LabLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()..initialize()),
        ChangeNotifierProvider(create: (_) => ReportViewModel()),
      ],
      child: DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
          // Use dynamic colors from system if available (Android 12+)
          // Otherwise fall back to custom brand colors
          ColorScheme lightColorScheme;
          ColorScheme darkColorScheme;

          if (lightDynamic != null && darkDynamic != null) {
            // Dynamic colors available - use Material You colors from system
            // Harmonize with brand colors for consistent feel
            lightColorScheme = lightDynamic.harmonized();
            darkColorScheme = darkDynamic.harmonized();

            debugPrint('🎨 Material You enabled - using dynamic colors');
            debugPrint('  Primary: ${lightDynamic.primary}');
            debugPrint('  Secondary: ${lightDynamic.secondary}');
          } else {
            // Dynamic colors not available - use custom brand colors
            lightColorScheme = AppTheme.lightColorScheme;
            darkColorScheme = AppTheme.darkColorScheme;

            debugPrint('⚠️ Material You not available - using brand colors');
          }

          return MaterialApp(
            title: 'LabLens',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(lightColorScheme),
            darkTheme: AppTheme.darkTheme(darkColorScheme),
            themeMode: ThemeMode.system,
            // Enable smooth theme transitions
            themeAnimationDuration: const Duration(milliseconds: 300),
            themeAnimationCurve: Curves.easeInOut,
            home: const MainShell(),
          );
        },
      ),
    );
  }
}
