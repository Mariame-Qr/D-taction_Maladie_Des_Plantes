# Setup de la Détection

## Problème actuel
La détection/prédiction ne fonctionne pas parce que la **clé API Gemini n'est pas configurée**.

## Solution

### Étape 1: Obtenir une clé API Gemini
1. Allez sur: **https://aistudio.google.com/apikey**
2. Cliquez sur "Create API key"
3. Sélectionnez "Create API key in new project" ou un projet existant
4. Copiez la clé générée

### Étape 2: Configurer la clé dans l'app
Ouvrez le fichier: `lib/config/api_constants.dart`

Remplacez cette ligne:
```dart
static const String geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';
```

Par:
```dart
static const String geminiApiKey = 'votre_clé_api_ici';
```

### Étape 3: Recompiler et relancer
```bash
flutter clean
flutter pub get
flutter run
```

## Architecture actuelle

### Détection (Detection Screen)
1. Sélectionner une image (caméra ou galerie)
2. Analyser avec **Gemini Vision API**
3. Obtenir: maladie, confiance, solutions
4. Sauvegarder dans l'historique local

### Gemini Service
- Envoie l'image à Gemini 2.5 Flash Lite
- Reçoit l'analyse en JSON
- Parse et retourne les résultats

### Storage Service
- Sauvegarde les détections localement (JSON)
- Récupère l'historique
- Permet d'exporter en CSV

## Notes
- **Mode hors-ligne**: Si la clé API n'est pas valide, l'app fonctionne en mode dégradé
- **TFLite local**: Non intégré actuellement (problèmes de compatibilité Gradle)
- **Backend FastAPI**: Optional, non utilisé pour la détection

## Dépannage

### L'app démarre mais la détection affiche "Erreur API"
→ Vérifiez que la clé API Gemini est configurée correctement

### "Configuration API requise"
→ La clé est toujours le placeholder, remplacez-la

### Erreurs de compilation
```bash
flutter clean
flutter pub get
```

