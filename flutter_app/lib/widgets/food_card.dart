import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/types.dart';

class FoodCard extends StatelessWidget {
  final LogEntry entry;
  final VoidCallback onDelete;

  const FoodCard({super.key, required this.entry, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF27272A) : const Color(0xFFF3F4F6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.food.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${entry.food.macros.calories.toStringAsFixed(0)} kcal',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _MacroBadge(label: 'P', value: entry.food.macros.protein),
                    const SizedBox(width: 8),
                    _MacroBadge(label: 'C', value: entry.food.macros.carbs),
                    const SizedBox(width: 8),
                    _MacroBadge(label: 'F', value: entry.food.macros.fat),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: Icon(
              LucideIcons.trash2,
              size: 20,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }
}

class _MacroBadge extends StatelessWidget {
  final String label;
  final double value;

  const _MacroBadge({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Text(
      '$label: ${value.toStringAsFixed(0)}g',
      style: TextStyle(
        fontSize: 12,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
      ),
    );
  }
}
