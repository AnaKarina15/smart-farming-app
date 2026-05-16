import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_endpoints.dart';

/// Shared provider that manages the user's profile photo.
/// It notifies all listeners (CustomAppBar, ProfileScreen, etc.) when the photo changes.
class ProfileImageProvider extends ChangeNotifier {
  final DioClient? dioClient;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  String? _backendAvatarUrl;

  ProfileImageProvider([this.dioClient]);

  File? get imageFile => _imageFile;
  bool get isUploading => _isUploading;
  String? get backendAvatarUrl => _backendAvatarUrl;

  /// Opens a bottom sheet for the user to choose camera or gallery,
  /// then picks the image, shows a confirmation dialog, and saves it.
  Future<void> pickImage(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Cambiar foto de perfil',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 5),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF1E5266),
                  child: Icon(Icons.camera_alt, color: Colors.white),
                ),
                title: const Text('Tomar foto'),
                subtitle: const Text('Usar la cámara del dispositivo'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF2E5D42),
                  child: Icon(Icons.photo_library, color: Colors.white),
                ),
                title: const Text('Elegir de galería'),
                subtitle: const Text('Seleccionar una imagen existente'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              if (_imageFile != null)
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.red,
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  title: const Text('Eliminar foto actual'),
                  onTap: () {
                    _imageFile = null;
                    notifyListeners();
                    Navigator.pop(ctx);
                  },
                ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    // Show confirmation dialog
    if (!context.mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirmar foto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(pickedFile.path),
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            const Text('¿Deseas usar esta foto como tu foto de perfil?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E5266),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('CONFIRMAR'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _imageFile = File(pickedFile.path);
      notifyListeners();
      
      // Upload to backend
      await _uploadToBackend(_imageFile!);
    }
  }

  Future<void> _uploadToBackend(File file) async {
    if (dioClient == null) return;
    
    _isUploading = true;
    notifyListeners();

    try {
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final response = await dioClient!.dio.post(
        ApiEndpoints.avatar,
        data: formData,
      );

      if (response.statusCode == 201) {
        final data = response.data;
        // La API devuelve un UserResponseDto, leemos fotoPerfilUrl
        _backendAvatarUrl = data['fotoPerfilUrl'];
      }
    } catch (e) {
      debugPrint('Error uploading avatar: $e');
      // Podriamos mostrar un toast o revertir la imagen, por ahora solo lo registramos
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }
}
