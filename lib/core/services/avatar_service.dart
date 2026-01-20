import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;

/// Servicio para gestionar avatares de usuario
abstract class AvatarService {
  /// Seleccionar imagen de la galería
  Future<File?> pickFromGallery();

  /// Capturar imagen con la cámara
  Future<File?> captureFromCamera();

  /// Subir avatar a Supabase Storage
  Future<String?> uploadAvatar(String userId, File imageFile);

  /// Eliminar avatar anterior
  Future<void> deleteAvatar(String avatarUrl);

  /// Obtener URL pública del avatar
  String? getAvatarPublicUrl(String? avatarPath);
}

@LazySingleton(as: AvatarService)
class AvatarServiceImpl implements AvatarService {
  final SupabaseClient _supabaseClient;
  final ImagePicker _imagePicker;

  AvatarServiceImpl(this._supabaseClient) : _imagePicker = ImagePicker();

  static const String _bucketName = 'avatars';

  @override
  Future<File?> pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<File?> captureFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
        preferredCameraDevice: CameraDevice.front,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> uploadAvatar(String userId, File imageFile) async {
    try {
      final fileExt = path.extension(imageFile.path).replaceFirst('.', '');
      final fileName =
          '$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      await _supabaseClient.storage.from(_bucketName).upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );

      return fileName;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> deleteAvatar(String avatarUrl) async {
    try {
      // Extraer path del archivo de la URL
      final uri = Uri.parse(avatarUrl);
      final pathSegments = uri.pathSegments;

      // Buscar el índice donde comienza el path del archivo
      final bucketIndex = pathSegments.indexOf(_bucketName);
      if (bucketIndex >= 0 && bucketIndex < pathSegments.length - 1) {
        final filePath = pathSegments.sublist(bucketIndex + 1).join('/');
        await _supabaseClient.storage.from(_bucketName).remove([filePath]);
      }
    } catch (e) {
      // Silently fail - el avatar antiguo se queda huérfano
    }
  }

  @override
  String? getAvatarPublicUrl(String? avatarPath) {
    if (avatarPath == null || avatarPath.isEmpty) return null;

    // Si ya es una URL completa, devolverla
    if (avatarPath.startsWith('http')) {
      return avatarPath;
    }

    // Generar URL pública
    return _supabaseClient.storage.from(_bucketName).getPublicUrl(avatarPath);
  }
}
