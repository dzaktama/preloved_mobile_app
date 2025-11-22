import 'package:flutter/material.dart';

class HelperGambar {
  // Show dialog pilih sumber gambar
  static Future<String?> tampilkanDialogPilihSumber(
    BuildContext context,
    Future<String?> Function() onKamera,
    Future<String?> Function() onGaleri,
  ) async {
    return showModalBottomSheet<String?>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Pilih Sumber Foto',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2F3640),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFFE84118)),
                title: const Text('Kamera'),
                onTap: () async {
                  Navigator.pop(context);
                  final path = await onKamera();
                  if (path != null && context.mounted) {
                    Navigator.pop(context, path);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFFE84118)),
                title: const Text('Galeri'),
                onTap: () async {
                  Navigator.pop(context);
                  final path = await onGaleri();
                  if (path != null && context.mounted) {
                    Navigator.pop(context, path);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}