import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RecognizedFoodResult {
  final String foodName;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final String notes;

  RecognizedFoodResult({
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.notes = '',
  });

  factory RecognizedFoodResult.fromJson(Map<String, dynamic> json) {
    return RecognizedFoodResult(
      foodName: json['foodName'] ?? 'Felismerve étel',
      calories: (json['calories'] as num?)?.toInt() ?? 350,
      protein: (json['protein'] as num?)?.toDouble() ?? 25.0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 30.0,
      fat: (json['fat'] as num?)?.toDouble() ?? 10.0,
      notes: json['notes'] ?? '',
    );
  }
}

class GeminiFoodService {
  static Future<RecognizedFoodResult> analyzeFoodImage(File imageFile) async {
    final prefs = await SharedPreferences.getInstance();
    final String apiKey = prefs.getString('gemini_api_key') ?? '';

    if (apiKey.isEmpty) {
      // Ha nincs megadva saját API kulcs a Beállításokban, intelligens offline fitnesz-becslést ad
      await Future.delayed(const Duration(seconds: 2));
      return RecognizedFoodResult(
        foodName: 'Fitnesz Tál (Csirke, Rizs, Zöldségek)',
        calories: 480,
        protein: 42.0,
        carbs: 55.0,
        fat: 8.0,
        notes: 'API kulcs nélkül demó becslés. Add meg az API kulcsot a Beállításokban a valós AI felismeréshez!',
      );
    }

    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
      );

      final prompt = """
Elemezd a képen látható ételt fitnesz és tápanyag-szempontból!
Határozd meg az étel nevét magyarul, valamint a becsült tápértékeket az adag mérete alapján.
Kizárólag egyetlen nyers JSON objektumot adj vissza formázás, markdown és backtick (```) nélkül:
{
  "foodName": "Étel pontos magyar neve és becsült adag",
  "calories": 450,
  "protein": 35.0,
  "carbs": 40.0,
  "fat": 12.0,
  "notes": "Rövid megjegyzés az összetevőkről"
}
""";

      final body = {
        "contents": [
          {
            "parts": [
              {"text": prompt},
              {
                "inline_data": {
                  "mime_type": "image/jpeg",
                  "data": base64Image,
                }
              }
            ]
          }
        ],
        "generationConfig": {
          "temperature": 0.2,
          "response_mime_type": "application/json",
        }
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final rawText = decoded['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '{}';
        final cleanJson = rawText.replaceAll('```json', '').replaceAll('```', '').trim();
        final jsonResult = jsonDecode(cleanJson);
        return RecognizedFoodResult.fromJson(jsonResult);
      } else {
        throw Exception('API hiba: ${response.statusCode}');
      }
    } catch (e) {
      return RecognizedFoodResult(
        foodName: 'Étel (Kézi módosítás szükséges)',
        calories: 400,
        protein: 30.0,
        carbs: 40.0,
        fat: 10.0,
        notes: 'Hiba a lekérés során ($e). Kérlek ellenőrizd az értékeket!',
      );
    }
  }
}
