import 'dart:math';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;

/// Local classifier placeholder that reads labels.txt and returns a deterministic
/// label based on the image bytes. Replace with real TFLite inference when ready.
class LocalClassifier {
  static final LocalClassifier _instance = LocalClassifier._internal();
  late final List<String> _labels;
  bool _initialized = false;

  factory LocalClassifier() => _instance;

  LocalClassifier._internal();

  Future<void> _loadLabels() async {
    final raw = await rootBundle.loadString('assets/labels.txt');
    _labels = raw
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    _initialized = true;
  }

  Future<void> ensureLoaded() async {
    if (_initialized) return;
    await _loadLabels();
  }

  /// Fake prediction: hashes the image bytes to pick a label deterministically.
  Future<PredictionResult> predict(File imageFile) async {
    await ensureLoaded();
    if (_labels.isEmpty) {
      return PredictionResult(className: 'Label inconnu', confidence: 0.0);
    }

    final bytes = await imageFile.readAsBytes();
    final hash = _simpleHash(bytes);
    final idx = hash % _labels.length;
    final label = _labels[idx];

    // Confidence is a pseudo value between 0.6 and 0.9 for UX feedback.
    final confidence = 0.6 + (hash % 30) / 100.0; // 0.60..0.89

    return PredictionResult(className: label, confidence: confidence);
  }

  int _simpleHash(Uint8List bytes) {
    int hash = 0;
    for (final b in bytes.take(1024)) {
      hash = (hash * 31 + b) & 0x7fffffff;
    }
    return hash.abs();
  }
}

class PredictionResult {
  final String className;
  final double confidence;

  PredictionResult({required this.className, required this.confidence});
}