import 'package:flutter/material.dart';
import 'package:frontend/core/utils/logger.dart';
import 'package:image_picker/image_picker.dart';

Future<XFile?> pickUserImage(BuildContext context) async {
  try {
    return await showModalBottomSheet<XFile>(
      context: context,
      showDragHandle: true,
      builder: (context) => const _ImagePickerSheet(),
    );
  } catch (e, st) {
    logger.e("Error when picking image: $e\n$st");
    return null;
  }
}

class _ImagePickerSheet extends StatelessWidget {
  const _ImagePickerSheet();

  Future<XFile?> pickFromImage() async {
    final picker = ImagePicker();

    return await picker.pickImage(source: ImageSource.camera);
  }

  Future<XFile?> pickFromGalery() async {
    final picker = ImagePicker();

    return await picker.pickImage(source: ImageSource.gallery);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text("Foto aufnehmen"),
            onTap: () async {
              final image = await pickFromImage();
              if (!context.mounted) return;
              Navigator.pop(context, image);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo),
            title: const Text("Aus Galerie auswählen"),
            onTap: () async {
              final image = await pickFromGalery();
              if (!context.mounted) return;
              Navigator.pop(context, image);
            },
          ),
          ListTile(
            leading: const Icon(Icons.close),
            title: const Text("Abbrechen"),
            onTap: () => Navigator.pop(context, null),
          ),
        ],
      ),
    );
  }
}
