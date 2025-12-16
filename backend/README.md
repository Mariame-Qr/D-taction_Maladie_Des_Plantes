# Backend FastAPI pour Détection de Maladies de Plantes

## Installation

### Prérequis
- Python 3.10 ou supérieur
- pip (gestionnaire de packages Python)

### Étapes

1. **Créer un environnement virtuel** (recommandé)
```bash
python -m venv venv

# Windows
venv\Scripts\activate.bat

# macOS/Linux
source venv/bin/activate
```

2. **Installer les dépendances**
```bash
pip install -r requirements.txt
```

3. **Préparer les fichiers du modèle**
Assurez-vous que les fichiers suivants sont présents:
- `../assets/model.tflite` - Votre modèle TensorFlow Lite
- `../assets/labels.txt` - Fichier avec les noms des classes

## Lancement

### Option 1: Avec le script batch (Windows)
```bash
start.bat
```

### Option 2: Directement
```bash
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

L'API sera accessible sur:
- **Serveur**: http://localhost:8000
- **Documentation interactive**: http://localhost:8000/docs
- **Documentation Redoc**: http://localhost:8000/redoc

## Endpoints

### GET `/`
Vérification que l'API est active
```json
{
  "status": "ok",
  "message": "API Plant Disease Detection active",
  "model_loaded": true,
  "classes_count": 38
}
```

### GET `/classes`
Récupère la liste des maladies disponibles
```json
{
  "classes": ["Healthy", "Early Blight", "Late Blight", ...],
  "count": 38
}
```

### POST `/predict`
Prédiction sur une seule image
**Paramètres**: `file` (multipart/form-data)
**Réponse**:
```json
{
  "class": "Tomato Late Blight",
  "confidence": 0.95,
  "solution": "Isolez la plante. Appliquez un traitement systémique immédiatement.",
  "timestamp": "2025-12-15T10:30:00"
}
```

### POST `/predict-batch`
Prédiction sur plusieurs images
**Paramètres**: `files` (liste de fichiers)

### GET `/health`
Vérification de santé du serveur

## Configuration pour Flutter

### URL du serveur dans `lib/config/api_constants.dart`

```dart
// Émulateur Android
static const String baseUrl = 'http://10.0.2.2:8000';

// Appareil physique (remplacez par votre IP)
static const String baseUrl = 'http://192.168.x.x:8000';

// PC local
static const String baseUrl = 'http://localhost:8000';
```

## Troubleshooting

### "Module not found" error
```bash
pip install -r requirements.txt
```

### Port 8000 déjà utilisé
```bash
# Changer le port
python -m uvicorn main:app --reload --port 8001
```

### CORS error
Les headers CORS sont déjà configurés. Si vous avez toujours des problèmes:
```python
# Vérifier la configuration CORSMiddleware dans main.py
```

## Extension future

Pour intégrer Gemini API:
1. Ajouter votre clé API dans les variables d'environnement
2. Importer et utiliser `google.generativeai`
3. Appeler le modèle Gemini pour les solutions détaillées
