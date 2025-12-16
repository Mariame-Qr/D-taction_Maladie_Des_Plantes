#!/usr/bin/env python3
"""
Script de vérification de la configuration complète
Teste Flutter, Python, et la connectivité du backend
"""

import subprocess
import sys
import os
import time
import socket
from pathlib import Path

def check_command(cmd, description):
    """Vérifie si une commande existe"""
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        return True, result.stdout.strip()
    except:
        return False, None

def check_port(host, port):
    """Vérifie si un port est accessible"""
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(2)
        result = sock.connect_ex((host, port))
        sock.close()
        return result == 0
    except:
        return False

def main():
    print("\n" + "="*70)
    print("🔍 Vérification de la configuration - Plant Disease Detector")
    print("="*70)
    
    checks_passed = 0
    checks_total = 0
    
    # 1. Vérifier Flutter
    print("\n📱 Vérification Flutter...")
    checks_total += 1
    success, version = check_command("flutter --version", "Flutter")
    if success:
        print(f"  ✅ Flutter: {version.split(chr(10))[0]}")
        checks_passed += 1
    else:
        print("  ❌ Flutter non trouvé")
    
    # 2. Vérifier Python
    print("\n🐍 Vérification Python...")
    checks_total += 1
    success, version = check_command(f"{sys.executable} --version", "Python")
    if success:
        print(f"  ✅ Python: {version}")
        checks_passed += 1
    else:
        print("  ❌ Python non trouvé")
    
    # 3. Vérifier dépendances Flutter
    print("\n📦 Vérification dépendances Flutter...")
    flutter_deps = ["http", "image_picker", "camera", "google_generative_ai"]
    for dep in flutter_deps:
        checks_total += 1
        pubspec_path = Path("pubspec.yaml")
        if pubspec_path.exists():
            content = pubspec_path.read_text()
            if dep in content:
                print(f"  ✅ {dep}")
                checks_passed += 1
            else:
                print(f"  ❌ {dep} manquant")
        else:
            print(f"  ⚠️  pubspec.yaml non trouvé")
    
    # 4. Vérifier dépendances Python
    print("\n🐍 Vérification dépendances Python...")
    python_deps = ["fastapi", "uvicorn", "tensorflow", "pillow"]
    for dep in python_deps:
        checks_total += 1
        check_cmd = f"{sys.executable} -c \"import {dep}\""
        success, _ = check_command(check_cmd, dep)
        if success:
            print(f"  ✅ {dep}")
            checks_passed += 1
        else:
            print(f"  ⚠️  {dep} non importable (installer requirements.txt)")
    
    # 5. Vérifier fichiers critiques
    print("\n📁 Vérification fichiers critiques...")
    critical_files = [
        "lib/main.dart",
        "lib/config/api_constants.dart",
        "pubspec.yaml",
        "backend/main.py",
        "backend/requirements.txt",
        "assets/labels.txt"
    ]
    
    for file_path in critical_files:
        checks_total += 1
        if os.path.exists(file_path):
            print(f"  ✅ {file_path}")
            checks_passed += 1
        else:
            print(f"  ⚠️  {file_path} manquant (optionnel pour labels.txt)")
    
    # 6. Vérifier connectivité réseau
    print("\n🌐 Vérification connectivité...")
    checks_total += 1
    if check_port("127.0.0.1", 8000):
        print("  ✅ Backend accessible sur localhost:8000")
        checks_passed += 1
    else:
        print("  ⚠️  Backend non accessible (normal s'il n'est pas démarré)")
    
    # Résumé
    print("\n" + "="*70)
    percentage = (checks_passed / checks_total * 100) if checks_total > 0 else 0
    print(f"📊 Résumé: {checks_passed}/{checks_total} vérifications ({percentage:.0f}%)")
    
    if checks_passed == checks_total:
        print("✅ Toutes les vérifications sont passées!")
        print("\n🚀 Vous pouvez maintenant démarrer l'application:")
        print("   1. Ouvrir backend/start.bat pour le serveur FastAPI")
        print("   2. Ouvrir un autre terminal et exécuter: flutter run")
    elif percentage >= 80:
        print("⚠️  Quelques vérifications manquent, mais vous pouvez continuer")
        print("\n💡 Assurez-vous que:")
        print("   • Tous les fichiers requis sont présents")
        print("   • Les dépendances Python sont installées (pip install -r backend/requirements.txt)")
        print("   • Le modèle TensorFlow Lite est dans assets/")
    else:
        print("❌ Plusieurs vérifications ont échoué")
        print("\n👉 Consultez STARTUP.md pour des instructions détaillées")
    
    print("="*70 + "\n")
    
    return checks_passed == checks_total

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
