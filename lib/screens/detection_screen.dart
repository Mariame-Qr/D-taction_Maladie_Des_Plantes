import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/gemini_service.dart';
import '../services/storage_service.dart';
import '../services/tflite_classifier.dart';

class DetectionScreen extends StatefulWidget {
  const DetectionScreen({super.key});

  @override
  State<DetectionScreen> createState() => _DetectionScreenState();
}

class _DetectionScreenState extends State<DetectionScreen> {
  final ImagePicker _picker = ImagePicker();
  final GeminiService _geminiService = GeminiService();
  final StorageService _storageService = StorageService();
  final TFLiteClassifier _classifier = TFLiteClassifier();

  File? _selectedImage;
  bool _isLoading = false;
  String? _errorMessage;
  String? _detectedDisease;
  String? _geminiSolution;
  double _confidence = 0.0;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _detectedDisease = null;
          _geminiSolution = null;
          _errorMessage = null;
          _confidence = 0.0;
        });
        _performDetection();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur sélection image: $e';
      });
    }
  }

  Future<void> _performDetection() async {
    if (_selectedImage == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('Début de la détection...');
      
      await _storageService.init();
      await _classifier.ensureInitialized();

      // 1) Prédiction locale avec labels.txt
      final localPrediction = await _classifier.predict(_selectedImage!);

      // 2) Appel Gemini pour conseils basés sur la classe prédite
      final advice = await _geminiService.generateAdviceFromPrediction(
        diseaseName: localPrediction.className,
        confidence: localPrediction.confidence,
      );

      setState(() {
        _detectedDisease = localPrediction.className;
        _confidence = localPrediction.confidence;
        _geminiSolution = advice['solution'] ?? '';
      });

      await _storageService.saveDetection(
        imagePath: _selectedImage!.path,
        disease: _detectedDisease ?? 'Unknown',
        confidence: _confidence,
        solution: _geminiSolution ?? '',
        timestamp: DateTime.now(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Détection sauvegardée')),
        );
      }
    } catch (e) {
      print('Erreur détection: $e');
      setState(() {
        _errorMessage = 'Erreur: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Section Image
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _selectedImage == null
                  ? Container(
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aucune image sélectionnée',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                        height: 300,
                      ),
                    ),
            ),
            const SizedBox(height: 16),

            // Boutons de sélection d'image
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Caméra'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galerie'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Indicateur de chargement
            if (_isLoading)
              Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text('Analyse en cours...'),
                ],
              )
            else if (_errorMessage != null)
              // Affichage erreur
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else if (_detectedDisease != null)
              // Affichage résultats
              Column(
                children: [
                  // Résultat de détection
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      border: Border.all(color: Colors.green),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Maladie détectée:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${(_confidence * 100).toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _detectedDisease ?? '',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Solutions recommandées
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.lightbulb, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              'Solutions recommandées:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _geminiSolution ?? 'Aucune solution disponible',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Bouton pour nouvelle détection
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedImage = null;
                        _detectedDisease = null;
                        _geminiSolution = null;
                        _errorMessage = null;
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Nouvelle détection'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
