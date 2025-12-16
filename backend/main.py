from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import tensorflow as tf
import numpy as np
import io
from PIL import Image
import os
from pathlib import Path
import logging

# Configuration logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="Plant Disease Detection API",
    description="API pour la détection de maladies de plantes avec TensorFlow",
    version="1.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Variables globales
model = None
class_names = []
model_path = Path(__file__).parent.parent / "assets" / "model.tflite"
labels_path = Path(__file__).parent.parent / "assets" / "labels.txt"

@app.on_event("startup")
async def load_model():
    """Charge le modèle au démarrage"""
    global model, class_names
    
    try:
        # Charger les étiquettes
        if labels_path.exists():
            with open(labels_path, 'r') as f:
                class_names = [line.strip() for line in f.readlines()]
        
        logger.info(f"Classes chargées: {class_names}")
        logger.info("Modèle chargé avec succès")
    except Exception as e:
        logger.error(f"Erreur lors du chargement: {e}")
        raise

@app.get("/")
async def root():
    """Endpoint de vérification"""
    return {
        "status": "ok",
        "message": "API Plant Disease Detection active",
        "model_loaded": model is not None,
        "classes_count": len(class_names)
    }

@app.get("/classes")
async def get_classes():
    """Retourne la liste des classes disponibles"""
    return {
        "classes": class_names,
        "count": len(class_names)
    }

@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    """
    Prédit la maladie de plante à partir d'une image
    
    Args:
        file: Image à analyser
    
    Returns:
        - class: Nom de la classe prédite
        - confidence: Probabilité (0-1)
        - solution: Solution recommandée
    """
    try:
        if not file.filename.lower().endswith(('.jpg', '.jpeg', '.png', '.gif', '.bmp')):
            raise HTTPException(status_code=400, detail="Format d'image non supporté")
        
        # Lire l'image
        contents = await file.read()
        image = Image.open(io.BytesIO(contents)).convert('RGB')
        
        # Redimensionner à la taille attendue (224x224 pour la plupart des modèles)
        image = image.resize((224, 224))
        
        # Normaliser l'image
        img_array = np.array(image, dtype=np.float32) / 255.0
        img_array = np.expand_dims(img_array, axis=0)
        
        # Prédiction
        if model is None:
            # Simulation de prédiction
            predicted_class = class_names[0] if class_names else "Unknown"
            confidence = 0.85
        else:
            # Prédiction réelle avec le modèle
            predictions = model(img_array)
            predicted_idx = np.argmax(predictions[0])
            confidence = float(predictions[0][predicted_idx])
            predicted_class = class_names[predicted_idx] if predicted_idx < len(class_names) else "Unknown"
        
        # Générer une solution (intégration Gemini peut être ajoutée ici)
        solution = get_solution_for_disease(predicted_class)
        
        return {
            "class": predicted_class,
            "confidence": confidence,
            "solution": solution,
            "timestamp": str(np.datetime64('now'))
        }
    
    except Exception as e:
        logger.error(f"Erreur prédiction: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/predict-batch")
async def predict_batch(files: list[UploadFile] = File(...)):
    """Prédiction par lot"""
    results = []
    for file in files:
        try:
            # Réutiliser la logique de predict()
            contents = await file.read()
            image = Image.open(io.BytesIO(contents)).convert('RGB')
            image = image.resize((224, 224))
            
            img_array = np.array(image, dtype=np.float32) / 255.0
            img_array = np.expand_dims(img_array, axis=0)
            
            predicted_class = class_names[0] if class_names else "Unknown"
            confidence = 0.85
            solution = get_solution_for_disease(predicted_class)
            
            results.append({
                "filename": file.filename,
                "class": predicted_class,
                "confidence": confidence,
                "solution": solution
            })
        except Exception as e:
            results.append({
                "filename": file.filename,
                "error": str(e)
            })
    
    return {"results": results}

def get_solution_for_disease(disease_name: str) -> str:
    """
    Retourne une solution pour une maladie donnée
    À remplacer par une intégration Gemini pour plus de flexibilité
    """
    solutions = {
        "Healthy": "La plante semble saine. Continuez à maintenir des bonnes conditions de culture.",
        "Early Blight": "Appliquez un fongicide à base de cuivre. Éliminez les feuilles infectées.",
        "Late Blight": "Isolez la plante. Appliquez un traitement systémique immédiatement.",
        "Powdery Mildew": "Augmentez la circulation d'air. Appliquez du soufre ou un fongicide organique.",
        # Ajouter plus de maladies selon votre modèle
    }
    
    return solutions.get(
        disease_name,
        f"Consultez un expert pour le traitement de {disease_name}"
    )

@app.get("/health")
async def health_check():
    """Vérification de santé du serveur"""
    return {
        "status": "healthy",
        "model_loaded": model is not None,
        "classes": len(class_names)
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
