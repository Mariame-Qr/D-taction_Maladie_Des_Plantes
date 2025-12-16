# 🌿 Plant Disease Detector - Application Flutter + FastAPI

## 📱 Vue d'ensemble

Une application mobile intelligente de détection de maladies de plantes combinant:
- **Frontend**: Flutter avec Material Design 3
- **Backend**: FastAPI + TensorFlow
- **API IA**: Google Gemini pour les solutions recommandées

### ✨ Fonctionnalités principales

- 📷 **Détection en temps réel** - Caméra ou galerie
- 🤖 **Prédictions précises** - Modèle TensorFlow Lite optimisé
- 💡 **Solutions intelligentes** - Générées par Google Gemini
- 📊 **Historique complet** - Suivi de toutes les analyses
- ⚙️ **Paramètres configurables** - API, mode détection, etc.
- 🔄 **Synchronisation** - Backend pour analyses avancées

---

## 🚀 Démarrage rapide

### Prérequis
- Flutter 3.9.2+
- Python 3.10+
- Appareil Android ou émulateur

### Installation en 3 étapes

```bash
# 1. Cloner le projet
cd c:\Users\qrnma\FlutterProjects\projetDetectionMaladie

# 2. Installer les dépendances
flutter pub get
cd backend
pip install -r requirements.txt
cd ..

# 3. Lancer l'application
start_app.bat
```

Pour plus de détails, voir [STARTUP.md](STARTUP.md)

---

## 📁 Architecture du projet

```
projetDetectionMaladie/
│
├── lib/                           # Code Flutter
│   ├── main.dart                 # Point d'entrée
│   ├── cnn_page.dart             # TFLite original
│   │
│   ├── config/
│   │   └── api_constants.dart    # Configuration (URLs, clés API)
│   │
│   ├── models/
│   │   └── prediction_result.dart # Modèle de données résultat
│   │
│   ├── screens/
│   │   ├── detection_screen.dart  # Écran principal de détection
│   │   ├── history_screen.dart    # Historique des prédictions
│   │   └── settings_screen.dart   # Paramètres et configuration
│   │
│   ├── services/
│   │   ├── api_service.dart       # Requêtes HTTP vers backend
│   │   ├── gemini_service.dart    # Intégration Google Gemini
│   │   ├── permission_service.dart# Gestion permissions système
│   │   └── storage_service.dart   # Sauvegarde locale
│   │
│   ├── utils/
│   │   ├── error_handler.dart     # Gestion erreurs
│   │   └── image_utils.dart       # Compression/redimensionnement
│   │
│   └── widgets/
│       └── prediction_result_widget.dart # Widget résultat réutilisable
│
├── backend/                       # Serveur FastAPI
│   ├── main.py                    # Application FastAPI
│   ├── requirements.txt           # Dépendances Python
│   ├── start.bat                  # Script lancement
│   └── README.md                  # Documentation backend
│
├── assets/                        # Ressources
│   ├── model.tflite              # Modèle TensorFlow Lite
│   └── labels.txt                # Classes (une par ligne)
│
├── pubspec.yaml                   # Configuration Flutter + dépendances
├── analysis_options.yaml          # Règles Dart/Flutter
├── STARTUP.md                     # Guide détaillé de démarrage
├── SETUP.md                       # Instructions d'installation
└── README.md                      # Ce fichier
```

---

## 🔧 Configuration

### 1. API Backend (api_constants.dart)

```dart
// Émulateur Android (par défaut)
static const String baseUrl = 'http://10.0.2.2:8000';

// Appareil physique - remplacez par votre IP
static const String baseUrl = 'http://192.168.1.100:8000';
```

### 2. Google Gemini API (Optionnel)

```dart
static const String geminiApiKey = 'YOUR_API_KEY_HERE';
```

Obtenir une clé: https://ai.google.dev

### 3. Modèle TensorFlow Lite

Assurez-vous que:
- `assets/model.tflite` existe
- `assets/labels.txt` existe avec une classe par ligne

---

## 📱 Utilisation

### Écran de Détection
1. **Sélectionner une image** (Caméra 📷 ou Galerie 🖼️)
2. **Choisir le mode**:
   - **Local**: Utilise TFLite intégré
   - **API**: Utilise le backend FastAPI
3. **Voir le résultat**:
   - Classe détectée
   - Confiance (%)
   - Solution recommandée

### Écran d'Historique
- **Voir** toutes les prédictions précédentes
- **Détails** de chaque analyse
- **Supprimer** l'historique si nécessaire

### Écran des Paramètres
- **Vérifier** la connexion au backend
- **Configurer** Google Gemini API
- **Information** sur l'application
- **Support** et aide

---

## 🔌 API Backend FastAPI

### Endpoints disponibles

#### `GET /`
Vérification que l'API est active

**Réponse**:
```json
{
  "status": "ok",
  "message": "API Plant Disease Detection active",
  "model_loaded": true,
  "classes_count": 38
}
```

#### `GET /classes`
Liste des classes disponibles

**Réponse**:
```json
{
  "classes": ["Healthy", "Early Blight", "Late Blight", ...],
  "count": 38
}
```

#### `POST /predict`
Prédiction sur une image

**Paramètres**: `file` (image multipart)

**Réponse**:
```json
{
  "class": "Tomato Late Blight",
  "confidence": 0.95,
  "solution": "Isolez la plante. Appliquez un traitement systémique...",
  "timestamp": "2025-12-15T10:30:00"
}
```

#### `POST /predict-batch`
Prédictions multiples

#### `GET /health`
Vérification de santé du serveur

**Documentation interactive**: http://localhost:8000/docs

---

## 🛠️ Dépannage

### Erreur "Connection refused"
```bash
# Démarrer le backend
cd backend
python -m uvicorn main:app --reload
```

### Port déjà utilisé
```bash
# Démarrer sur un port différent
python -m uvicorn main:app --port 8001
```

### Module Python manquant
```bash
pip install -r requirements.txt
```

### Dépendances Flutter
```bash
flutter pub get
flutter clean
flutter pub get
```

Voir [STARTUP.md](STARTUP.md) pour plus d'aide.

---

## 📚 Dépendances principales

### Flutter
- `http`: Requêtes HTTP
- `image_picker`: Sélection d'image
- `camera`: Accès caméra
- `google_generative_ai`: API Gemini
- `permission_handler`: Gestion permissions
- `path_provider`: Accès système de fichiers
- `tflite`: TensorFlow Lite

### Python
- `fastapi`: Framework web
- `uvicorn`: Serveur ASGI
- `tensorflow`: Modèles ML
- `pillow`: Traitement d'images
- `google-generativeai`: API Gemini

---

## 🎯 Points d'amélioration futurs

- [ ] Caméra en temps réel avec détection continue
- [ ] Statistiques et graphiques
- [ ] Export des résultats (PDF/CSV)
- [ ] Synchronisation cloud
- [ ] Mode hors-ligne complètement
- [ ] Support multilingue
- [ ] Notifications de maladies
- [ ] Recommandations personnalisées

---

## 📊 Technologie utilisée

| Composant | Technologie | Version |
|-----------|-------------|---------|
| Frontend | Flutter | 3.9.2+ |
| Backend | FastAPI | 0.109.0 |
| ML | TensorFlow | 2.14.0 |
| IA | Google Gemini | 0.3.0+ |
| BD Local | JSON | - |
| Serveur | Uvicorn | 0.27.0 |

---

## 🔐 Sécurité

- ✅ CORS configuré
- ✅ Validation des fichiers
- ✅ Gestion des permissions
- ✅ Erreurs sécurisées
- ✅ Données locales chiffrées

---

## 📄 License

Ce projet est fourni à titre d'exemple éducatif.

---

## 🙏 Remerciements

- TensorFlow Team
- Google AI
- Flutter Team
- Communauté open-source

---

## 📞 Support

**Problèmes de démarrage?**
→ Consultez [STARTUP.md](STARTUP.md)

**Questions d'installation?**
→ Consultez [SETUP.md](SETUP.md)

**Erreurs spécifiques?**
→ Vérifiez les logs détaillés avec `flutter run -v`

---

**Développé avec ❤️ pour la détection intelligente de maladies de plantes.**

**Dernière mise à jour: Décembre 2025**
