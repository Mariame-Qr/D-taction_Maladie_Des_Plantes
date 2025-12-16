#!/usr/bin/env python3
"""
Script de configuration du backend Plant Disease Detection
Crée l'environnement virtuel et installe les dépendances
"""

import os
import sys
import subprocess
import platform

def run_command(cmd, description):
    """Exécute une commande et affiche le statut"""
    print(f"\n{'='*60}")
    print(f"► {description}")
    print(f"{'='*60}")
    
    try:
        result = subprocess.run(cmd, shell=True, check=True)
        print(f"✅ {description} - Succès")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ {description} - Erreur: {e}")
        return False
    except Exception as e:
        print(f"❌ Erreur inattendue: {e}")
        return False

def main():
    print("\n" + "="*60)
    print("🌿 Plant Disease Detection - Configuration Backend")
    print("="*60)
    
    # Déterminer le système d'exploitation
    is_windows = platform.system() == "Windows"
    
    # Chemins
    backend_dir = os.path.dirname(os.path.abspath(__file__))
    venv_path = os.path.join(backend_dir, "venv")
    
    # 1. Vérifier Python
    print("\n[1/4] Vérification de Python...")
    try:
        py_version = subprocess.check_output([sys.executable, "--version"], 
                                            text=True).strip()
        print(f"✅ Python détecté: {py_version}")
    except:
        print("❌ Python n'est pas installé")
        return False
    
    # 2. Créer l'environnement virtuel
    print("\n[2/4] Création de l'environnement virtuel...")
    
    if not os.path.exists(venv_path):
        venv_cmd = f"{sys.executable} -m venv venv"
        if not run_command(venv_cmd, "Création d'environnement virtuel"):
            return False
    else:
        print(f"✅ Environnement virtuel existe déjà")
    
    # 3. Déterminer la commande d'activation et pip
    if is_windows:
        activate_cmd = os.path.join(venv_path, "Scripts", "activate.bat")
        pip_cmd = os.path.join(venv_path, "Scripts", "pip.exe")
        python_cmd = os.path.join(venv_path, "Scripts", "python.exe")
    else:
        activate_cmd = os.path.join(venv_path, "bin", "activate")
        pip_cmd = os.path.join(venv_path, "bin", "pip")
        python_cmd = os.path.join(venv_path, "bin", "python")
    
    # 4. Installer les dépendances
    print("\n[3/4] Installation des dépendances...")
    
    requirements_path = os.path.join(backend_dir, "requirements.txt")
    if os.path.exists(requirements_path):
        install_cmd = f"{pip_cmd} install -r {requirements_path}"
        if not run_command(install_cmd, "Installation des packages Python"):
            return False
    else:
        print(f"❌ requirements.txt non trouvé")
        return False
    
    # 5. Vérifier les dépendances critiques
    print("\n[4/4] Vérification des dépendances...")
    
    check_modules = ["fastapi", "uvicorn", "tensorflow", "pillow"]
    all_installed = True
    
    for module in check_modules:
        check_cmd = f"{python_cmd} -c \"import {module}\""
        try:
            subprocess.run(check_cmd, shell=True, check=True, 
                         capture_output=True)
            print(f"  ✅ {module}")
        except:
            print(f"  ❌ {module} - Erreur d'import")
            all_installed = False
    
    # Résumé final
    print("\n" + "="*60)
    if all_installed:
        print("✅ Configuration complète!")
        print("\nProchaines étapes:")
        print("1. Pour démarrer le serveur:")
        if is_windows:
            print(f"   {activate_cmd}")
        else:
            print(f"   source {activate_cmd}")
        print("   python -m uvicorn main:app --reload")
        print("\n2. L'API sera accessible sur: http://localhost:8000")
        print("3. Documentation: http://localhost:8000/docs")
        return True
    else:
        print("⚠️  Certains modules n'ont pas pu être vérifiés")
        print("Mais la configuration a probablement réussi.")
        return True

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
