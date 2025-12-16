import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();

  factory PermissionService() {
    return _instance;
  }

  PermissionService._internal();

  /// Demande les permissions caméra et galerie
  Future<bool> requestCameraPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.camera.request();
      return status.isGranted;
    } else if (Platform.isIOS) {
      final status = await Permission.camera.request();
      return status.isGranted;
    }
    return true;
  }

  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    return true;
  }

  /// Demande les permissions photos
  Future<bool> requestPhotosPermission() async {
    if (Platform.isIOS) {
      final status = await Permission.photos.request();
      return status.isGranted;
    }
    return true;
  }

  /// Vérifie toutes les permissions requises
  Future<bool> requestAllPermissions() async {
    bool cameraOk = await requestCameraPermission();
    bool storageOk = await requestStoragePermission();
    bool photosOk = await requestPhotosPermission();
    
    return cameraOk && storageOk && photosOk;
  }

  /// Montre une boîte de dialogue pour demander les permissions
  static Future<void> showPermissionDialog(BuildContext context, String title, String message) {
    return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.of(context).pop();
            },
            child: const Text('Ouvrir paramètres'),
          ),
        ],
      ),
    );
  }
}
