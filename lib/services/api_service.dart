import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_constants.dart';
import '../models/prediction_result.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal();

  /// Envoie une image au serveur pour prédiction
  Future<PredictionResult> predictImage(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.predictEndpoint}'),
      );

      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      try {
        var response = await request.send().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception('Timeout serveur');
          },
        );

        if (response.statusCode == 200) {
          var responseData = await response.stream.toBytes();
          var jsonData = jsonDecode(utf8.decode(responseData));
          return PredictionResult.fromJson(jsonData);
        } else {
          throw Exception('Erreur serveur: ${response.statusCode}');
        }
      } catch (e) {
        // Si le backend n'est pas disponible et mode hors-ligne activé
        if (ApiConstants.enableOfflineMode) {
          print('⚠️ Serveur indisponible. Mode hors-ligne activé.');
          return _getOfflinePrediction();
        }
        rethrow;
      }
    } catch (e) {
      throw Exception('Erreur prédiction: $e');
    }
  }

  /// Prédiction de démonstration (mode hors-ligne)
  PredictionResult _getOfflinePrediction() {
    final demos = [
      PredictionResult(
        className: 'Tomate - Saine',
        confidence: 0.92,
        solution: 'La plante est en bonne santé. Continuez l\'arrosage régulier.',
        timestamp: DateTime.now(),
      ),
      PredictionResult(
        className: 'Tomate - Brûlure précoce',
        confidence: 0.88,
        solution: 'Appliquez un fongicide à base de cuivre. Éliminez les feuilles infectées.',
        timestamp: DateTime.now(),
      ),
      PredictionResult(
        className: 'Tomate - Mildiou',
        confidence: 0.85,
        solution: 'Isolez la plante. Appliquez un traitement systémique immédiatement.',
        timestamp: DateTime.now(),
      ),
    ];
    return demos[DateTime.now().second % demos.length];
  }

  /// Récupère la liste des classes disponibles
  Future<List<String>> getClasses() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.classesEndpoint}'),
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<String> classes = List<String>.from(jsonData['classes'] ?? []);
        return classes;
      } else {
        throw Exception('Erreur classes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur récupération classes: $e');
    }
  }

  /// Teste la connexion au serveur
  Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/'),
      ).timeout(
        const Duration(seconds: 5),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
