import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/types.dart';

// --- Theme State ---
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void toggle() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  void setMode(ThemeMode mode) {
    state = mode;
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

// --- Navigation State ---
class ActiveTabNotifier extends Notifier<AppTab> {
  @override
  AppTab build() => AppTab.DASHBOARD;

  void setTab(AppTab tab) {
    state = tab;
  }
}

final activeTabProvider = NotifierProvider<ActiveTabNotifier, AppTab>(
  ActiveTabNotifier.new,
);

// --- Data State ---

// Mock Initial Profile
final defaultProfile = UserProfile(
  name: 'Alex',
  weight: 80,
  height: 180,
  age: 30,
  gender: 'male',
  goalType: GoalType.LOSE_WEIGHT,
  activityLevel: ActivityLevel.MODERATELY_ACTIVE,
  bmr: 1800,
  tdee: 2800,
  macroGoals: Macros(
    calories: 2500,
    protein: 180,
    carbs: 250,
    fat: 80,
    water: 3000,
  ),
);

class UserProfileNotifier extends Notifier<UserProfile> {
  @override
  UserProfile build() => defaultProfile;

  void updateProfile(UserProfile newProfile) {
    state = newProfile;
  }

  void updateWeight(double weight) {
    state = UserProfile(
      name: state.name,
      weight: weight,
      height: state.height,
      age: state.age,
      gender: state.gender,
      goalType: state.goalType,
      activityLevel: state.activityLevel,
      bmr: state.bmr,
      tdee: state.tdee,
      macroGoals: state.macroGoals,
    );
  }
}

final userProfileProvider = NotifierProvider<UserProfileNotifier, UserProfile>(
  UserProfileNotifier.new,
);

class DailyLogNotifier extends Notifier<List<LogEntry>> {
  @override
  List<LogEntry> build() => [];

  void addEntry(LogEntry entry) {
    state = [...state, entry];
  }

  void removeEntry(String id) {
    state = state.where((entry) => entry.id != id).toList();
  }
}

final dailyLogProvider = NotifierProvider<DailyLogNotifier, List<LogEntry>>(
  DailyLogNotifier.new,
);

class WaterIntakeNotifier extends Notifier<double> {
  @override
  double build() => 0;

  void add(double amount) {
    state += amount;
  }
}

final waterIntakeProvider = NotifierProvider<WaterIntakeNotifier, double>(
  WaterIntakeNotifier.new,
);

// Derived State: Daily Totals
final dailyTotalsProvider = Provider<Macros>((ref) {
  final log = ref.watch(dailyLogProvider);
  return log.fold(
    Macros(calories: 0, protein: 0, carbs: 0, fat: 0, water: 0),
    (acc, entry) => Macros(
      calories: acc.calories + entry.food.macros.calories,
      protein: acc.protein + entry.food.macros.protein,
      carbs: acc.carbs + entry.food.macros.carbs,
      fat: acc.fat + entry.food.macros.fat,
      water: acc.water,
    ),
  );
});
