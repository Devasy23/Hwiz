import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      child: MaterialApp(
        title: 'LabLens',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: ThemeMode.system,
        home: const MainShell(),
      ),
    );
  }
}
