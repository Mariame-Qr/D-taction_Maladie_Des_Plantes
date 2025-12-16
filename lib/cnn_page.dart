import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'services/api_service.dart';
import 'models/prediction_result.dart';

class CNNPage extends StatefulWidget {
  const CNNPage({super.key});

  @override
  State<CNNPage> createState() => _CNNPageState();
}

class _CNNPageState extends State<CNNPage> {
  bool _loading = false;
  File? _image;
  PredictionResult? _result;
  final ImagePicker _picker = ImagePicker();
  final ApiService _apiService = ApiService();

  // Sélectionner une image
  pickImage() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() {
      _loading = true;
      _image = File(image.path);
    });
    classifyImage(_image!);
  }

  // Classement de l'image via le backend API
  classifyImage(File image) async {
    try {
      final result = await _apiService.predictImage(image);
      setState(() {
        _result = result;
        _loading = false;
      });
    } catch (e) {
      print('Erreur classification: $e');
      setState(() {
        _loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Analyse CNN"),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _image == null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.image, 
                                      size: 64, color: Colors.grey[400]),
                                  const SizedBox(height: 8),
                                  Text('Aucune image',
                                      style: TextStyle(color: Colors.grey[600])),
                                ],
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child: Image.file(_image!, fit: BoxFit.cover),
                            ),
                    ),
                    const SizedBox(height: 24),

                    // Résultats
                    if (_result != null) ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Résultat',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text(_result!.className,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: _result!.confidence,
                                  minHeight: 10,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _result!.confidence > 0.8
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text('Confiance: ${_result!.getConfidencePercentage()}',
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              const Divider(),
                              const SizedBox(height: 8),
                              const Text('Solution recommandée:',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text(_result!.solution),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Bouton action
                    ElevatedButton.icon(
                      onPressed: pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text('Sélectionner une image'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}