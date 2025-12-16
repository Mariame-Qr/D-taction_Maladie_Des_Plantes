import 'dart:io';
import 'package:image/image.dart' as img;
import 'dart:typed_data';

class ImageUtils {
  /// Compresse une image
  static Future<File> compressImage(File imageFile, {int quality = 80}) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) return imageFile;
      
      final compressed = img.encodeJpg(image, quality: quality);
      final compressedFile = File(imageFile.path.replaceAll('.jpg', '_compressed.jpg'))
        ..writeAsBytesSync(compressed);
      
      return compressedFile;
    } catch (e) {
      print('Erreur compression: $e');
      return imageFile;
    }
  }

  /// Redimensionne une image
  static Future<File> resizeImage(File imageFile, {int width = 224, int height = 224}) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) return imageFile;
      
      final resized = img.copyResize(image, width: width, height: height);
      final resizedFile = File(imageFile.path.replaceAll('.jpg', '_resized.jpg'))
        ..writeAsBytesSync(img.encodeJpg(resized));
      
      return resizedFile;
    } catch (e) {
      print('Erreur redimensionnement: $e');
      return imageFile;
    }
  }

  /// Obtient la taille du fichier en MB
  static Future<double> getFileSizeInMB(File file) async {
    final bytes = await file.length();
    return bytes / (1024 * 1024);
  }

  /// Valide le format de l'image
  static bool isValidImageFormat(String path) {
    final validFormats = ['jpg', 'jpeg', 'png', 'gif', 'bmp'];
    final extension = path.split('.').last.toLowerCase();
    return validFormats.contains(extension);
  }

  /// Obtient les informations de l'image
  static Future<Map<String, dynamic>> getImageInfo(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      
      final sizeInMB = await getFileSizeInMB(file);
      
      return {
        'width': image?.width ?? 0,
        'height': image?.height ?? 0,
        'size_mb': sizeInMB,
        'format': file.path.split('.').last.toUpperCase(),
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
