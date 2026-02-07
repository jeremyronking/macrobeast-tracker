import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'providers/app_state.dart';
import 'models/types.dart';
import 'screens/dashboard_screen.dart';
import 'screens/food_log_screen.dart';
import 'screens/add_scan_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(const ProviderScope(child: MacroBeastApp()));
}

class MacroBeastApp extends ConsumerWidget {
  const MacroBeastApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'MacroBeast Tracker',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFDC2626), // Red-600
          primary: const Color(0xFFDC2626),
          secondary: const Color(0xFF22C55E), // Green-500
          background: const Color(0xFFF9FAFB), // Gray-50
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFDC2626),
          brightness: Brightness.dark,
          primary: const Color(0xFFDC2626),
          secondary: const Color(0xFF22C55E),
          background: const Color(0xFF18181B), // Zinc-800
          surface: const Color(0xFF27272A), // Zinc-700
        ),
        scaffoldBackgroundColor: const Color(0xFF000000), // Dark-900
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF18181B),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const MainScaffold(),
    );
  }
}

class MainScaffold extends ConsumerWidget {
  const MainScaffold({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(activeTabProvider);

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: activeTab.index,
          children: const [
            DashboardScreen(),
            FoodLogScreen(),
            AddScanScreen(),
            ProgressScreen(),
            SettingsScreen(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: activeTab.index,
        onDestinationSelected: (index) {
          ref.read(activeTabProvider.notifier).setTab(AppTab.values[index]);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(LucideIcons.layoutDashboard),
            label: 'Today',
          ),
          NavigationDestination(icon: Icon(LucideIcons.utensils), label: 'Log'),
          NavigationDestination(
            icon: Icon(LucideIcons.plusCircle, color: Colors.red),
            label: 'Add',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.trendingUp),
            label: 'Progress',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
