
enum GoalType {
  LOSE_WEIGHT,
  MAINTAIN,
  GAIN_MUSCLE,
}

enum ActivityLevel {
  SEDENTARY,
  LIGHTLY_ACTIVE,
  MODERATELY_ACTIVE,
  VERY_ACTIVE,
}

enum AppTab {
  DASHBOARD,
  FOOD_LOG,
  ADD_SCAN,
  PROGRESS,
  SETTINGS,
}

class Macros {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double water;

  Macros({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.water,
  });

  factory Macros.fromJson(Map<String, dynamic> json) {
    return Macros(
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      water: (json['water'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'water': water,
    };
  }
}

class UserProfile {
  final String name;
  final double weight;
  final double height;
  final int age;
  final String gender;
  final GoalType goalType;
  final ActivityLevel activityLevel;
  final double bmr;
  final double tdee;
  final Macros macroGoals;

  UserProfile({
    required this.name,
    required this.weight,
    required this.height,
    required this.age,
    required this.gender,
    required this.goalType,
    required this.activityLevel,
    required this.bmr,
    required this.tdee,
    required this.macroGoals,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'],
      weight: (json['weight'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      age: json['age'],
      gender: json['gender'],
      goalType: GoalType.values.firstWhere((e) => e.toString().split('.').last == json['goalType']),
      activityLevel: ActivityLevel.values.firstWhere((e) => e.toString().split('.').last == json['activityLevel']),
      bmr: (json['bmr'] as num).toDouble(),
      tdee: (json['tdee'] as num).toDouble(),
      macroGoals: Macros.fromJson(json['macroGoals']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'weight': weight,
      'height': height,
      'age': age,
      'gender': gender,
      'goalType': goalType.toString().split('.').last,
      'activityLevel': activityLevel.toString().split('.').last,
      'bmr': bmr,
      'tdee': tdee,
      'macroGoals': macroGoals.toJson(),
    };
  }
}

class FoodItem {
  final String id;
  final String name;
  final String? brand;
  final String servingSize;
  final Macros macros;
  final bool isCustom;

  FoodItem({
    required this.id,
    required this.name,
    this.brand,
    required this.servingSize,
    required this.macros,
    this.isCustom = false,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'],
      name: json['name'],
      brand: json['brand'],
      servingSize: json['servingSize'],
      macros: Macros.fromJson(json['macros']),
      isCustom: json['isCustom'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'servingSize': servingSize,
      'macros': macros.toJson(),
      'isCustom': isCustom,
    };
  }
}

class LogEntry {
  final String id;
  final FoodItem food;
  final int timestamp;
  final String date;

  LogEntry({
    required this.id,
    required this.food,
    required this.timestamp,
    required this.date,
  });

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      id: json['id'],
      food: FoodItem.fromJson(json['food']),
      timestamp: json['timestamp'],
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'food': food.toJson(),
      'timestamp': timestamp,
      'date': date,
    };
  }
}

class DailySummary {
  final String date;
  final Macros consumed;
  final List<LogEntry> entries;

  DailySummary({
    required this.date,
    required this.consumed,
    required this.entries,
  });

  factory DailySummary.fromJson(Map<String, dynamic> json) {
    return DailySummary(
      date: json['date'],
      consumed: Macros.fromJson(json['consumed']),
      entries: (json['entries'] as List).map((e) => LogEntry.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'consumed': consumed.toJson(),
      'entries': entries.map((e) => e.toJson()).toList(),
    };
  }
}
