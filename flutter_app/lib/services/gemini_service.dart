import 'dart:convert';
import 'dart:math';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/types.dart';

class GeminiService {
  final GenerativeModel _model;

  // Using gemini-1.5-flash as a stable fallback, but keeping the user's model ID in mind.
  static const String _modelId = 'gemini-2.5-flash-lite';

  GeminiService(String apiKey)
    : _model = GenerativeModel(model: _modelId, apiKey: apiKey);

  String _generateId() {
    return Random().nextInt(100000000).toString(); // Simple ID generation
  }

  Future<List<FoodItem>> searchFoodAI(String query) async {
    try {
      final prompt =
          'Search for food items matching "$query". Return 3-5 distinct options including common brands if applicable. Estimate macros per standard serving.';

      final content = [Content.text(prompt)];

      // Using JSON mode logic where we enforce the schema via prompt structure or responseMimeType
      // The Dart SDK supports responseMimeType and responseSchema in recent versions.

      final response = await _model.generateContent(
        content,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          responseSchema: Schema.array(
            items: Schema.object(
              properties: {
                'name': Schema.string(),
                'brand': Schema.string(),
                'servingSize': Schema.string(),
                'calories': Schema.number(),
                'protein': Schema.number(),
                'carbs': Schema.number(),
                'fat': Schema.number(),
              },
              requiredProperties: [
                'name',
                'servingSize',
                'calories',
                'protein',
                'carbs',
                'fat',
              ],
            ),
          ),
        ),
      );

      if (response.text == null) return [];

      final List<dynamic> data = jsonDecode(response.text!);
      return data
          .map(
            (item) => FoodItem(
              id: _generateId(),
              name: item['name'],
              brand: item['brand'] ?? 'Generic',
              servingSize: item['servingSize'],
              macros: Macros(
                calories: (item['calories'] as num).toDouble(),
                protein: (item['protein'] as num).toDouble(),
                carbs: (item['carbs'] as num).toDouble(),
                fat: (item['fat'] as num).toDouble(),
                water: 0,
              ),
              isCustom: false,
            ),
          )
          .toList();
    } catch (e) {
      print('AI Search Error: $e');
      return [];
    }
  }

  Future<FoodItem?> identifyBarcodeFood(String barcode) async {
    try {
      final prompt =
          'Simulate a food product lookup for a random popular snack or meal with barcode ending in ${barcode.substring(max(0, barcode.length - 4))}. Return the nutritional info.';

      final content = [Content.text(prompt)];

      final response = await _model.generateContent(
        content,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          responseSchema: Schema.object(
            properties: {
              'name': Schema.string(),
              'brand': Schema.string(),
              'servingSize': Schema.string(),
              'calories': Schema.number(),
              'protein': Schema.number(),
              'carbs': Schema.number(),
              'fat': Schema.number(),
            },
            requiredProperties: [
              'name',
              'servingSize',
              'calories',
              'protein',
              'carbs',
              'fat',
            ],
          ),
        ),
      );

      if (response.text == null) return null;

      final Map<String, dynamic> item = jsonDecode(response.text!);
      return FoodItem(
        id: _generateId(),
        name: item['name'],
        brand: item['brand'],
        servingSize: item['servingSize'],
        macros: Macros(
          calories: (item['calories'] as num).toDouble(),
          protein: (item['protein'] as num).toDouble(),
          carbs: (item['carbs'] as num).toDouble(),
          fat: (item['fat'] as num).toDouble(),
          water: 0,
        ),
      );
    } catch (e) {
      print('Barcode Error: $e');
      return null;
    }
  }

  Future<String> getMealIdeas(UserProfile profile) async {
    try {
      final prompt =
          '''Give me 3 distinct meal ideas (Breakfast, Lunch, Dinner) for a person with these stats:
      Goal: ${profile.goalType.toString().split('.').last}
      Calories/day: ${profile.macroGoals.calories}
      Diet: High Protein preferred.
      Keep it brief and appetizing.''';

      final content = [Content.text(prompt)];

      final response = await _model.generateContent(content);
      return response.text ?? "No suggestions available.";
    } catch (e) {
      print('Meal Plan Error: $e');
      return "Could not generate meal plan at this time.";
    }
  }
}
