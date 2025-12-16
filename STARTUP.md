# 🌿 Plant Disease Detector - Guide Complet de Démarrage

## 📋 Table des matières
1. [Prérequis](#prérequis)
2. [Installation rapide](#installation-rapide)
3. [Démarrage](#démarrage)
4. [Configuration](#configuration)
5. [Dépannage](#dépannage)

---

## ✅ Prérequis

### Windows
- **Flutter**: 3.9.2 ou supérieur → [Télécharger](https://flutter.dev/docs/get-started/install/windows)
- **Python**: 3.10+ → [Télécharger](https://www.python.org)
- **Android Studio** (pour émulateur) ou appareil Android connecté
- **Git** (optionnel)

### Vérification
```bash
flutter --version
python --version
```

---

## 🚀 Installation Rapide

### Étape 1: Cloner/Ouvrir le projet
```bash
cd c:\Users\qrnma\FlutterProjects\projetDetectionMaladie
```

### Étape 2: Installer les dépendances Flutter
```bash
flutter pub get
```

### Étape 3: Configurer le backend Python
```bash
cd backend
python -m venv venv
venv\Scripts\activate.bat
pip install -r requirements.txt
cd ..
```

---

## 🎯 Démarrage

### Option 1: Utiliser le script automatique ⭐ (Recommandé)
```bash
start_app.bat
```

Puis sélectionnez l'option désirée:
- **1**: Démarrer Flutter uniquement
- **2**: Démarrer le backend FastAPI uniquement
- **3**: Démarrer les deux

### Option 2: Démarrage manuel

#### Terminal 1 - Backend FastAPI
```bash
cd backend
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

Vous devriez voir:
```
INFO:     Uvicorn running on http://0.0.0.0:8000
```

#### Terminal 2 - Flutter
```bash
flutter run
```

---

## ⚙️ Configuration

### Configuration API
Modifiez `lib/config/api_constants.dart`:

```dart
// Pour l'émulateur Android
static const String baseUrl = 'http://10.0.2.2:8000';

// Pour un appareil physique (changez l'IP)
static const String baseUrl = 'http://192.168.1.100:8000';

// Pour tester sur PC
static const String baseUrl = 'http://localhost:8000';
```

### Configuration Gemini API (Optionnel)
1. Visitez: https://ai.google.dev
2. Créez un compte Google
3. Générez une clé API
4. Modifiez `lib/config/api_constants.dart`:
```dart
static const String geminiApiKey = 'your_api_key_here';
```

### Modèle TensorFlow Lite
Placez vos fichiers dans le dossier `assets/`:
```
assets/
├── model.tflite       # Votre modèle
├── labels.txt         # Classes (une par ligne)
└── (autres assets)
```

Assurez-vous qu'ils sont déclarés dans `pubspec.yaml`:
```yaml
assets:
  - assets/model.tflite
  - assets/labels.txt
```

---

## 🔍 Vérification de la Configuration

### Backend API
Ouvrez votre navigateur:
```
http://localhost:8000
```

Vous devriez voir:
```json
{
  "status": "ok",
  "message": "API Plant Disease Detection active",
  "model_loaded": true,
  "classes_count": 38
}
```

### Documentation API Interactive
```
http://localhost:8000/docs
```

### Flutter Devices
```bash
flutter devices
```

Devrait lister vos appareils disponibles.

---

## 📱 Utilisation de l'Application

### Écrans disponibles

1. **Détection** (Caméra 📷)
   - Sélectionner image (caméra ou galerie)
   - Voir la prédiction et la confiance
   - Solutions recommandées

2. **Historique** (Historique 📜)
   - Voir toutes les prédictions passées
   - Afficher les détails
   - Effacer l'historique

3. **Paramètres** (⚙️)
   - Vérifier la connexion au serveur
   - Configuration Gemini
   - Information sur l'app
   - Aide et support

4. **CNN** (Analyse 📊)
   - Page originale TensorFlow Lite
   - Mode détection local

---

## 🐛 Dépannage

### ❌ "Connection refused" - Backend non trouvé

**Cause**: Le backend n'est pas démarré ou l'URL est incorrecte

**Solution**:
1. Démarrez le backend dans un terminal:
```bash
cd backend
python -m uvicorn main:app --reload
```

2. Vérifiez l'URL dans `api_constants.dart`

3. Testez: `http://localhost:8000` dans le navigateur

### ❌ "Module not found"

**Solution**:
```bash
flutter pub get
cd backend
pip install -r requirements.txt
```

### ❌ Émulateur Android ne se connecte pas

**Solution**:
```bash
flutter run -v  # Mode verbose pour voir les erreurs
adb devices     # Vérifier la connexion
flutter clean   # Nettoyer et reconstruire
```

### ❌ Port 8000 déjà utilisé

**Solution**:
```bash
# Tuer le processus sur le port 8000
netstat -ano | findstr :8000

# Puis démarrer sur un port différent
python -m uvicorn main:app --port 8001
```

Modifiez aussi `api_constants.dart`:
```dart
static const String baseUrl = 'http://localhost:8001';
```

### ❌ Erreur permissions (Caméra/Galerie)

**Solution**: 
1. Acceptez les permissions dans l'app
2. Vérifiez AndroidManifest.xml (Android)
3. Vérifiez Info.plist (iOS)

---

## 📊 Structure du Projet

```
projetDetectionMaladie/
├── lib/
│   ├── main.dart                  # Point d'entrée
│   ├── cnn_page.dart             # Page CNN TFLite
│   ├── config/
│   │   └── api_constants.dart    # Configuration API
│   ├── models/
│   │   └── prediction_result.dart # Modèle de données
│   ├── screens/
│   │   ├── detection_screen.dart  # Écran de détection
│   │   ├── history_screen.dart    # Écran d'historique
│   │   └── settings_screen.dart   # Écran paramètres
│   └── services/
│       ├── api_service.dart       # Requêtes API
│       ├── gemini_service.dart    # Service Gemini
│       ├── permission_service.dart# Gestion permissions
│       └── storage_service.dart   # Sauvegarde locale
├── backend/
│   ├── main.py                    # Serveur FastAPI
│   ├── requirements.txt           # Dépendances Python
│   ├── start.bat                  # Script démarrage
│   └── README.md                  # Doc backend
├── assets/
│   ├── model.tflite              # Modèle TFLite
│   └── labels.txt                # Classes
├── pubspec.yaml                   # Config Flutter
├── start_app.bat                  # Script de démarrage
└── STARTUP.md                     # Ce fichier
```

---

## 🔗 Ressources Utiles

- **Flutter**: https://flutter.dev
- **FastAPI**: https://fastapi.tiangolo.com
- **TensorFlow Lite**: https://www.tensorflow.org/lite
- **Google AI Studio**: https://ai.google.dev
- **Material Design 3**: https://m3.material.io

---

## 💡 Tips & Tricks

### Hot Reload (Développement Flutter)
Après modification du code, appuyez sur `r` dans le terminal Flutter pour recharger.

### Debug Mode
```bash
flutter run --verbose
```

### Build Release
```bash
flutter build apk --release
flutter build app-bundle --release
```

### Logs Flutter
```bash
flutter logs
```

### Logs Backend
Consultez la sortie du terminal où le backend s'exécute.

---

## ✨ Prochaines étapes

- [ ] Intégrer votre modèle TensorFlow Lite
- [ ] Configurer votre clé API Gemini
- [ ] Tester sur un appareil réel
- [ ] Optimiser les performances
- [ ] Déployer sur Google Play Store
- [ ] Ajouter des fonctionnalités supplémentaires

---

## 📞 Support

Si vous rencontrez des problèmes:
1. Consultez la section [Dépannage](#dépannage)
2. Vérifiez les logs détaillés avec `-v` flag
3. Consultez la documentation officielle des frameworks utilisés
4. Ouvrez une issue si nécessaire

---

**Bonne chance avec votre application! 🚀**
