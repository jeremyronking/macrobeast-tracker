import { GoogleGenAI, Type } from "@google/genai";
import { FoodItem, UserProfile } from "../types";

const ai = new GoogleGenAI({ apiKey: process.env.API_KEY });
const modelId = "gemini-3-flash-preview";

// Helper to generate a unique ID
const generateId = () => Math.random().toString(36).substr(2, 9);

export const searchFoodAI = async (query: string): Promise<FoodItem[]> => {
  try {
    const response = await ai.models.generateContent({
      model: modelId,
      contents: `Search for food items matching "${query}". Return 3-5 distinct options including common brands if applicable. Estimate macros per standard serving.`,
      config: {
        responseMimeType: "application/json",
        responseSchema: {
          type: Type.ARRAY,
          items: {
            type: Type.OBJECT,
            properties: {
              name: { type: Type.STRING },
              brand: { type: Type.STRING },
              servingSize: { type: Type.STRING },
              calories: { type: Type.NUMBER },
              protein: { type: Type.NUMBER },
              carbs: { type: Type.NUMBER },
              fat: { type: Type.NUMBER },
            },
            required: ["name", "servingSize", "calories", "protein", "carbs", "fat"],
          },
        },
      },
    });

    const data = JSON.parse(response.text || "[]");
    return data.map((item: any) => ({
      id: generateId(),
      name: item.name,
      brand: item.brand || "Generic",
      servingSize: item.servingSize,
      macros: {
        calories: item.calories,
        protein: item.protein,
        carbs: item.carbs,
        fat: item.fat,
        water: 0,
      },
      isCustom: false,
    }));
  } catch (error) {
    console.error("AI Search Error:", error);
    return [];
  }
};

export const identifyBarcodeFood = async (barcode: string): Promise<FoodItem | null> => {
    // In a real app, we'd lookup the barcode in a DB. 
    // Here we use Gemini to "guess" based on a simulated barcode lookup or generate a generic placeholder
    // asking Gemini to simulate a product lookup.
    
    try {
        const response = await ai.models.generateContent({
            model: modelId,
            contents: `Simulate a food product lookup for a random popular snack or meal with barcode ending in ${barcode.slice(-4)}. Return the nutritional info.`,
             config: {
                responseMimeType: "application/json",
                responseSchema: {
                  type: Type.OBJECT,
                  properties: {
                    name: { type: Type.STRING },
                    brand: { type: Type.STRING },
                    servingSize: { type: Type.STRING },
                    calories: { type: Type.NUMBER },
                    protein: { type: Type.NUMBER },
                    carbs: { type: Type.NUMBER },
                    fat: { type: Type.NUMBER },
                  },
                   required: ["name", "servingSize", "calories", "protein", "carbs", "fat"],
                },
              },
        });
        
        const item = JSON.parse(response.text || "{}");
         return {
            id: generateId(),
            name: item.name,
            brand: item.brand,
            servingSize: item.servingSize,
            macros: {
                calories: item.calories,
                protein: item.protein,
                carbs: item.carbs,
                fat: item.fat,
                water: 0
            }
        };

    } catch (e) {
        console.error(e);
        return null;
    }
}

export const getMealIdeas = async (profile: UserProfile): Promise<string> => {
  try {
    const response = await ai.models.generateContent({
      model: modelId,
      contents: `Give me 3 distinct meal ideas (Breakfast, Lunch, Dinner) for a person with these stats:
      Goal: ${profile.goalType}
      Calories/day: ${profile.macroGoals.calories}
      Diet: High Protein preferred.
      Keep it brief and appetizing.`,
      config: {
        thinkingConfig: { thinkingBudget: 1024 } 
      }
    });
    return response.text || "No suggestions available.";
  } catch (error) {
    console.error("Meal Plan Error:", error);
    return "Could not generate meal plan at this time.";
  }
};
