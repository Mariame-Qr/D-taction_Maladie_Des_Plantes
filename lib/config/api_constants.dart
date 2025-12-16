import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  // Backend FastAPI - MODIFIEZ SELON VOTRE CONFIGURATION
  // Options:
  // - Émulateur Android: http://10.0.2.2:8000
  // - Vrai téléphone: http://<VOTRE_IP_PC>:8000  (ex: http://192.168.1.100:8000)
  // - PC local: http://localhost:8000
  
  static const String baseUrl = 'http://192.168.1.100:8000'; // 👈 À MODIFIER avec votre IP
  
  static const String predictEndpoint = '/predict';
  static const String classesEndpoint = '/classes';

  // Gemini API - À configurer avec votre clé API
  // 1. Allez sur https://aistudio.google.com/apikey
  // 2. Créez une clé API Gemini
  // 3. Remplacez 'YOUR_GEMINI_API_KEY_HERE' par votre clé
  static String geminiApiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  
  // Mode hors-ligne (si backend pas disponible)
  static const bool enableOfflineMode = true;
}
