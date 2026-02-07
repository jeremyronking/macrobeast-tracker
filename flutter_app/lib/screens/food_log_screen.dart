import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/types.dart';
import '../providers/app_state.dart';
import '../widgets/food_card.dart';

class FoodLogScreen extends ConsumerWidget {
  const FoodLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyLog = ref.watch(dailyLogProvider);
    final dailyTotals = ref.watch(dailyTotalsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(
              "Food Log",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            floating: true,
          ),
          if (dailyLog.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.dumbbell,
                      size: 48,
                      color: Colors.grey.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No food logged today.",
                      style: TextStyle(
                        color: Colors.grey.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        ref
                            .read(activeTabProvider.notifier)
                            .setTab(AppTab.ADD_SCAN);
                      },
                      child: const Text(
                        "Start Logging",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final entry = dailyLog[index];
                  return FoodCard(
                    entry: entry,
                    onDelete: () {
                      ref.read(dailyLogProvider.notifier).removeEntry(entry.id);
                    },
                  );
                }, childCount: dailyLog.length),
              ),
            ),

          if (dailyLog.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF27272A) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total Consumed",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Calories: ${dailyTotals.calories.toStringAsFixed(0)}",
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                        Text(
                          "Protein: ${dailyTotals.protein.toStringAsFixed(0)}g",
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
