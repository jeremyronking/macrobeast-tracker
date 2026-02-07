import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/types.dart';
import '../providers/app_state.dart';
import '../widgets/macro_ring.dart';
import '../services/gemini_service.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String? _mealAdvice;
  bool _loadingAdvice = false;

  Future<void> _handleGetAdvice(UserProfile profile) async {
    setState(() => _loadingAdvice = true);
    // TODO: Get API Key safely.
    const apiKey = String.fromEnvironment('GEMINI_API_KEY');
    if (apiKey.isEmpty) {
      if (mounted) {
        setState(() {
          _mealAdvice =
              "Please configure your GEMINI_API_KEY to use AI features.";
          _loadingAdvice = false;
        });
      }
      return;
    }

    final service = GeminiService(apiKey);
    final advice = await service.getMealIdeas(profile);

    if (mounted) {
      setState(() {
        _mealAdvice = advice;
        _loadingAdvice = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(userProfileProvider);
    final dailyTotals = ref.watch(dailyTotalsProvider);
    final waterIntake = ref.watch(waterIntakeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final caloriesLeft =
        (userProfile.macroGoals.calories - dailyTotals.calories).clamp(
          0,
          double.infinity,
        );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "TODAY",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    "Let's hit those macros, ${userProfile.name}.",
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              CircleAvatar(
                backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                child: Icon(
                  LucideIcons.user,
                  color: isDark ? Colors.white : Colors.grey[600],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Main Calories Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF27272A)
                    : const Color(0xFFF3F4F6),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      caloriesLeft.toStringAsFixed(0),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const Text(
                      "CALORIES LEFT",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.flame,
                          size: 14,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Goal: ${userProfile.macroGoals.calories.toStringAsFixed(0)}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                MacroRing(
                  value: dailyTotals.calories,
                  max: userProfile.macroGoals.calories,
                  color: Colors.red,
                  label: "Consumed",
                  unit: "kcal",
                  size: 'lg',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Small Rings Row
          Row(
            children: [
              Expanded(
                child: _MacroCard(
                  label: "Protein",
                  unit: "g",
                  value: dailyTotals.protein,
                  max: userProfile.macroGoals.protein,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MacroCard(
                  label: "Carbs",
                  unit: "g",
                  value: dailyTotals.carbs,
                  max: userProfile.macroGoals.carbs,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MacroCard(
                  label: "Fat",
                  unit: "g",
                  value: dailyTotals.fat,
                  max: userProfile.macroGoals.fat,
                  color: Colors.purple,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Water Tracker
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? Colors.blue.withOpacity(0.1) : Colors.blue[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.blue.withOpacity(0.3)
                    : Colors.blue[100]!,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        LucideIcons.droplets,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Water Intake",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.blue[100] : Colors.grey[800],
                          ),
                        ),
                        Text(
                          "${waterIntake.toStringAsFixed(0)} / ${userProfile.macroGoals.water.toStringAsFixed(0)} ml",
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? Colors.blue[200]!.withOpacity(0.6)
                                : Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    ref.read(waterIntakeProvider.notifier).add(250);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.blue : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.add,
                      color: isDark ? Colors.white : Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // AI Suggestion
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black
                  : const Color(0xFF111827), // Gray-900 equivalent
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -10,
                  right: -10,
                  child: Icon(
                    LucideIcons.brainCircuit,
                    size: 80,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Need Meal Ideas?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Get AI-powered suggestions based on your remaining macros.",
                      style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                    ),
                    const SizedBox(height: 16),
                    if (_mealAdvice == null || _mealAdvice!.isEmpty)
                      ElevatedButton.icon(
                        onPressed: _loadingAdvice
                            ? null
                            : () => _handleGetAdvice(userProfile),
                        icon: _loadingAdvice
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const SizedBox.shrink(),
                        label: Text(
                          _loadingAdvice ? 'Thinking...' : 'Generate Plan',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFFDC2626,
                          ), // Primary Red
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[700]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _mealAdvice!,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => setState(() => _mealAdvice = null),
                              child: const Text(
                                "Close",
                                style: TextStyle(
                                  color: Color(0xFFDC2626),
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroCard extends StatelessWidget {
  final String label;
  final String unit;
  final double value;
  final double max;
  final Color color;

  const _MacroCard({
    required this.label,
    required this.unit,
    required this.value,
    required this.max,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF27272A) : const Color(0xFFF3F4F6),
        ),
      ),
      child: Column(
        children: [
          MacroRing(
            value: value,
            max: max,
            color: color,
            label: label,
            unit: unit,
            size: 'sm',
          ),
        ],
      ),
    );
  }
}
