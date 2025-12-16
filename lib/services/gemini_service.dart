import 'dart:convert';
import 'dart:math';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/api_constants.dart';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  late final GenerativeModel _model;
  bool _apiKeyValid = false;

  factory GeminiService() {
    return _instance;
  }

  GeminiService._internal() {
    _initModel();
  }

  void _initModel() {
    _apiKeyValid = ApiConstants.geminiApiKey != 'YOUR_GEMINI_API_KEY_HERE' &&
                   ApiConstants.geminiApiKey.isNotEmpty;
    
    if (_apiKeyValid) {
      _model = GenerativeModel(
        model: 'gemini-2.5-flash-lite', 
        apiKey: ApiConstants.geminiApiKey,
      );
    }
  }

  /// Génère une solution pour une maladie de plante
  Future<String> generateSolution(String diseaseName) async {
    try {
      if (!_apiKeyValid) {
        return 'API Key non configurée. Mode hors-ligne activé.';
      }

      final prompt = '''
      Vous êtes un expert en phytopathologie (maladies des plantes).
      
      La maladie de plante détectée est: $diseaseName
      
      Fournissez des recommandations de traitement courtes (max 300 caractères):
      ''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      return response.text ?? 'Pas de solution disponible';
    } catch (e) {
      print('Erreur Gemini generateSolution: $e');
      return 'Traitement recommandé: Consulter un phytopathologiste';
    }
  }

  /// Prend une prédiction (nom + confiance) et génère une solution concise.
  Future<Map<String, dynamic>> generateAdviceFromPrediction({
    required String diseaseName,
    required double confidence,
  }) async {
    try {
      if (!_apiKeyValid) {
        return {
          'solution': 'Clé API Gemini manquante. Ajoutez-la dans api_constants.dart.',
        };
      }

      final prompt = '''
      Maladie détectée: $diseaseName
      Confiance: ${(confidence * 100).toStringAsFixed(1)}%

      Fournis un plan d'action court (max 4 puces) :
      - Traitement immédiat
      - Prévention courte
      - Remède maison simple si possible
      - Quand consulter un expert
      ''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      final text = response.text ?? '';

      return {
        'solution': text.isEmpty
            ? 'Pas de recommandation disponible pour le moment.'
            : text,
      };
    } catch (e) {
      print('Erreur Gemini generateAdviceFromPrediction: $e');
      return {
        'solution': 'Erreur Gemini: ${e.toString().substring(0, 80)}',
      };
    }
  }

  /// Parse la réponse Gemini en JSON
  Map<String, dynamic> _parseGeminiResponse(String response) {
    try {
      // Chercher JSON dans la réponse
      final regex = RegExp(r'\{[^{}]*(?:"[^"]*"[^{}]*)*\}');
      final match = regex.firstMatch(response);
      
      if (match != null) {
        final jsonStr = match.group(0)!;
        print('JSON trouvé: $jsonStr');
        
        final json = jsonDecode(jsonStr);
        return {
          'disease': json['disease'] ?? 'Maladie',
          'confidence': (json['confidence'] ?? 0.5).toDouble(),
          'solution': json['solution'] ?? 'Pas de solution',
        };
      }
      
      // Fallback: parser le texte directement
      return {
        'disease': 'Maladie détectée',
        'confidence': 0.7,
        'solution': response.length > 200 
            ? response.substring(0, 200) 
            : response,
      };
    } catch (e) {
      print('Erreur parsing JSON: $e');
      return {
        'disease': 'Analyse effectuée',
        'confidence': 0.6,
        'solution': response.isNotEmpty 
            ? response.substring(0, min(200, response.length))
            : 'Pas de détails disponibles',
      };
    }
  }
}

int min(int a, int b) => a < b ? a : b;
