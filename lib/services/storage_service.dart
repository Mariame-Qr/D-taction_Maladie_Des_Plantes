import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import '../models/prediction_result.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  
  late Directory _appDocDir;
  late File _historyFile;

  factory StorageService() {
    return _instance;
  }

  StorageService._internal();

  /// Initialise les répertoires
  Future<void> init() async {
    _appDocDir = await getApplicationDocumentsDirectory();
    _historyFile = File('${_appDocDir.path}/predictions_history.json');
    
    if (!_historyFile.existsSync()) {
      _historyFile.createSync(recursive: true);
      _historyFile.writeAsStringSync('[]');
    }
  }

  /// Sauvegarde une prédiction dans l'historique
  Future<void> savePrediction(PredictionResult result) async {
    try {
      List<dynamic> history = jsonDecode(_historyFile.readAsStringSync());
      history.add(result.toJson());
      _historyFile.writeAsStringSync(jsonEncode(history));
    } catch (e) {
      print('Erreur sauvegarde prédiction: $e');
    }
  }

  /// Sauvegarde une détection avec tous les paramètres
  Future<void> saveDetection({
    required String imagePath,
    required String disease,
    required double confidence,
    required String solution,
    required DateTime timestamp,
  }) async {
    try {
      final result = PredictionResult(
        className: disease,
        confidence: confidence,
        solution: solution,
        timestamp: timestamp,
      );
      await savePrediction(result);
    } catch (e) {
      print('Erreur sauvegarde détection: $e');
    }
  }

  /// Récupère l'historique des prédictions
  Future<List<PredictionResult>> getPredictionHistory() async {
    try {
      String contents = _historyFile.readAsStringSync();
      List<dynamic> jsonList = jsonDecode(contents);
      return jsonList
          .map((json) => PredictionResult.fromJson(json))
          .toList()
          .reversed
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Efface l'historique
  Future<void> clearHistory() async {
    try {
      _historyFile.writeAsStringSync('[]');
    } catch (e) {
      print('Erreur suppression historique: $e');
    }
  }

  /// Exporte l'historique en CSV
  Future<String> exportHistoryAsCSV() async {
    try {
      List<PredictionResult> history = await getPredictionHistory();
      
      StringBuffer csv = StringBuffer();
      csv.writeln('Maladie,Confiance,Date,Solution');
      
      for (var result in history) {
        csv.writeln('${result.className},${result.confidence},${result.timestamp},${result.solution}');
      }
      
      return csv.toString();
    } catch (e) {
      return '';
    }
  }
}
