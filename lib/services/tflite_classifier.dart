import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// Minimal TFLite classifier that loads model.tflite and labels.txt from assets
/// and returns the top-1 label + confidence.
class TFLiteClassifier {
  static final TFLiteClassifier _instance = TFLiteClassifier._internal();

  factory TFLiteClassifier() => _instance;

  TFLiteClassifier._internal();

  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _initialized = false;

  // Compat: alias for old call site
  Future<void> ensureLoaded() => ensureInitialized();

  Future<void> ensureInitialized() async {
    if (_initialized) return;
    _interpreter = await _loadInterpreterFromAsset();
    _labels = await _loadLabels();
    _initialized = true;
  }

  Future<Interpreter> _loadInterpreterFromAsset() async {
    // Charge le modèle depuis les assets et instancie via buffer (plus robuste que fromAsset).
    final raw = await rootBundle.load('assets/plant_disease_model.tflite');
    final modelBytes = raw.buffer.asUint8List();
    return Interpreter.fromBuffer(modelBytes);
  }

  Future<List<String>> _loadLabels() async {
    final raw = await rootBundle.loadString('assets/labels.txt');
    final list = raw
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return list;
  }

  Future<PredictionResult> predict(File imageFile) async {
    await ensureInitialized();
    if (_interpreter == null || _labels.isEmpty) {
      return PredictionResult(className: 'Label indisponible', confidence: 0.0);
    }

    // Inspecter les tenseurs d'entrée
    final inputTensor = _interpreter!.getInputTensor(0);
    final inputShape = inputTensor.shape; // ex: [1, 224, 224, 3]
    final inputType = inputTensor.type;
    
    print('Modèle Input: Shape=$inputShape, Type=$inputType');

    final height = inputShape[1];
    final width = inputShape[2];

    // Decode and resize image
    final bytes = await imageFile.readAsBytes();
    final img.Image? decoded = img.decodeImage(bytes);
    if (decoded == null) {
      return PredictionResult(className: 'Image invalide', confidence: 0.0);
    }
    
    // Resize exact
    final img.Image resized = img.copyResize(decoded, width: width, height: height);

    // Préparer le buffer d'entrée selon le type attendu par le modèle
    Object inputBuffer;
    
    if (inputType == TensorType.float32) {
      // Le modèle Keras inclut déjà 'preprocess_input' (MobileNetV2).
      // Il attend donc des valeurs brutes [0, 255] en float, et fera la normalisation [-1, 1] en interne.
      final Float32List buffer = Float32List(width * height * 3);
      int index = 0;
      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final pixel = resized.getPixel(x, y);
          buffer[index++] = pixel.r.toDouble();
          buffer[index++] = pixel.g.toDouble();
          buffer[index++] = pixel.b.toDouble();
        }
      }
      inputBuffer = buffer.reshape([1, height, width, 3]);
    } else {
      // Pas de normalisation pour Uint8 (0-255)
      final Uint8List buffer = Uint8List(width * height * 3);
      int index = 0;
      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final pixel = resized.getPixel(x, y);
          buffer[index++] = pixel.r.toInt();
          buffer[index++] = pixel.g.toInt();
          buffer[index++] = pixel.b.toInt();
        }
      }
      inputBuffer = buffer.reshape([1, height, width, 3]);
    }

    // Inspecter les tenseurs de sortie
    final outputTensor = _interpreter!.getOutputTensor(0);
    final outputShape = outputTensor.shape; // ex: [1, 38]
    final outputType = outputTensor.type;
    final numClasses = outputShape.last;
    
    print('Modèle Output: Shape=$outputShape, Type=$outputType, Classes=$numClasses');
    print('Labels chargés: ${_labels.length}');

    if (numClasses != _labels.length) {
      print('ATTENTION: Nombre de classes du modèle ($numClasses) != Nombre de labels (${_labels.length})');
    }

    // Exécuter l'inférence
    late List<double> probabilities;
    
    if (outputType == TensorType.float32) {
      final outputBuffer = List.filled(numClasses, 0.0).reshape([1, numClasses]);
      _interpreter!.run(inputBuffer, outputBuffer);
      probabilities = List<double>.from(outputBuffer[0]);
    } else {
      // Si output est Uint8, on convertit en double (0-255 -> 0.0-1.0 si nécessaire, ou brut)
      // Souvent les modèles quantifiés sortent des entiers qu'on peut traiter comme scores relatifs
      final outputBuffer = List.filled(numClasses, 0).reshape([1, numClasses]);
      _interpreter!.run(inputBuffer, outputBuffer);
      probabilities = outputBuffer[0].map<double>((e) => e.toDouble()).toList();
    }

    // Trouver le meilleur score
    int bestIdx = 0;
    double bestScore = probabilities[0];
    for (int i = 1; i < probabilities.length; i++) {
      if (probabilities[i] > bestScore) {
        bestScore = probabilities[i];
        bestIdx = i;
      }
    }

    // Si c'est un modèle quantifié (scores > 1), on peut normaliser pour l'affichage (optionnel)
    if (bestScore > 1.0) {
      // Simple normalisation softmax ou division par 255 si c'est uint8
      // Ici on laisse brut ou on divise par 255 si c'est uint8
      if (outputType == TensorType.uint8) {
        bestScore = bestScore / 255.0;
      }
    }

    final label = bestIdx < _labels.length ? _labels[bestIdx] : 'Classe $bestIdx';
    print('Prédiction: $label ($bestScore)');
    
    return PredictionResult(className: label, confidence: bestScore);
  }
}

class PredictionResult {
  final String className;
  final double confidence;

  PredictionResult({required this.className, required this.confidence});
}