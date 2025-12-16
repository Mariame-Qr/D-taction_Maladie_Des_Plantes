import 'package:flutter/material.dart';

class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is String) {
      return error;
    }
    
    String message = error.toString();
    
    // Analyser les types d'erreurs courants
    if (message.contains('Connection refused')) {
      return 'Erreur de connexion. Vérifiez que le backend est démarré.';
    } else if (message.contains('Connection timeout')) {
      return 'Délai d\'attente dépassé. Le serveur ne répond pas.';
    } else if (message.contains('SocketException')) {
      return 'Erreur réseau. Vérifiez votre connexion internet.';
    } else if (message.contains('404')) {
      return 'Endpoint non trouvé. Vérifiez l\'URL du serveur.';
    } else if (message.contains('500')) {
      return 'Erreur serveur. Consultez les logs du backend.';
    } else if (message.contains('Permission')) {
      return 'Permission refusée. Vérifiez les paramètres de l\'application.';
    } else if (message.contains('format')) {
      return 'Format d\'image non supporté. Utilisez JPG, PNG, GIF ou BMP.';
    }
    
    return 'Une erreur s\'est produite. Veuillez réessayer.';
  }

  static void showErrorSnackBar(BuildContext context, dynamic error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(getErrorMessage(error)),
        backgroundColor: Colors.red[700],
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Fermer',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  static void showErrorDialog(BuildContext context, String title, dynamic error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(getErrorMessage(error)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}
