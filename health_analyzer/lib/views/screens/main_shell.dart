import 'package:flutter/material.dart';
import 'home_tab.dart';
import 'settings_tab.dart';

/// Main shell with bottom navigation
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    HomeTab(),
    SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      // Material 3 NavigationBar (replaces BottomNavigationBar)
      // Best practices:
      // - No shadow/elevation (M3 uses surface color instead)
      // - Pill-shaped indicator for active state
      // - 3-5 destinations of equal importance
      // - Filled icons for active state
      // - Labeled for better accessibility
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        // Material 3: Use tonal surface elevation instead of shadow
        elevation: 0,
        // Indicator shows active state with pill shape
        indicatorColor: Theme.of(context).colorScheme.secondaryContainer,
        // Smooth animation between tabs
        animationDuration: const Duration(milliseconds: 300),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
            // Tooltip for accessibility
            tooltip: 'Home screen',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
            tooltip: 'App settings',
          ),
        ],
      ),
    );
  }
}
