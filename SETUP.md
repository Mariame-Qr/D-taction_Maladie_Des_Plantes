# Installation et Configuration

## 1️⃣ Installation des dépendances Flutter

```bash
cd c:\Users\qrnma\FlutterProjects\projetDetectionMaladie
flutter pub get
```

## 2️⃣ Démarrage du Backend FastAPI

### Prérequis
- Python 3.10+
- pip

### Démarrage rapide
```bash
cd backend
start.bat
```

Ou manuellement:
```bash
python -m venv venv
venv\Scripts\activate.bat
pip install -r requirements.txt
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

L'API sera disponible sur: **http://localhost:8000**
Documentation: **http://localhost:8000/docs**

## 3️⃣ Configuration Flutter

### Android Emulator
Modifier `lib/config/api_constants.dart`:
```dart
static const String baseUrl = 'http://10.0.2.2:8000';
```

### Appareil physique
```dart
static const String baseUrl = 'http://192.168.x.x:8000'; // Remplacez par votre IP
```

### Configuration Gemini API (Optionnel)
1. Créez un compte Google AI Studio: https://ai.google.dev
2. Obtenez votre clé API
3. Modifiez `lib/config/api_constants.dart`:
```dart
static const String geminiApiKey = 'votre_clé_api_ici';
```

## 4️⃣ Lancement de l'application Flutter

```bash
# Vérifier les appareils disponibles
flutter devices

# Lancer l'application
flutter run

# Ou sur un émulateur spécifique
flutter run -d <device_id>
```

## 5️⃣ Modèle TensorFlow Lite

Assurez-vous que votre modèle est placé dans:
- `assets/model.tflite` - Modèle TensorFlow Lite
- `assets/labels.txt` - Étiquettes des classes

## Architecture

```
projetDetectionMaladie/
├── lib/
│   ├── main.dart                 # Point d'entrée
│   ├── cnn_page.dart            # Page CNN (existant)
│   ├── config/
│   │   └── api_constants.dart    # Configuration API
│   ├── models/
│   │   └── prediction_result.dart # Modèle de données
│   ├── screens/
│   │   └── detection_screen.dart # Interface de détection
│   └── services/
│       ├── api_service.dart      # Service API
│       └── gemini_service.dart   # Service Gemini
├── backend/
│   ├── main.py                   # Serveur FastAPI
│   ├── requirements.txt           # Dépendances Python
│   ├── start.bat                 # Script de lancement
│   └── README.md                 # Documentation backend
├── assets/
│   ├── model.tflite             # Modèle TensorFlow Lite
│   └── labels.txt               # Labels des classes
└── pubspec.yaml                  # Configuration Flutter

```

## Fonctionnalités

✅ **Détection en temps réel** - Caméra et galerie
✅ **Backend FastAPI** - API REST pour prédictions
✅ **Support Gemini** - Solutions recommandées
✅ **Interface moderne** - Material Design 3
✅ **Gestion d'erreurs** - Connectivité et exceptions
✅ **Mode local/API** - Flexible selon availability
✅ **Confiance et statistiques** - Barre de progression

## Troubleshooting

### Erreur "Connection refused"
1. Vérifiez que le backend est démarré
2. Vérifiez l'URL dans `api_constants.dart`
3. Vérifiez la connectivité réseau

### Modèle ne charge pas
1. Vérifiez que `assets/model.tflite` existe
2. Vérifiez les permissions dans AndroidManifest.xml

### Problème Gemini
1. Vérifiez votre clé API
2. Vérifiez la connexion internet
3. Consultez: https://ai.google.dev

## Next Steps

1. Intégrer votre modèle TensorFlow Lite
2. Configurer la clé Gemini API
3. Tester sur un appareil réel
4. Déployer sur Google Play Store (optional)

## Liens utiles

- Flutter Docs: https://flutter.dev/docs
- FastAPI: https://fastapi.tiangolo.com
- TensorFlow Lite: https://www.tensorflow.org/lite
- Google AI: https://ai.google.dev
- Material Design 3: https://m3.material.io
