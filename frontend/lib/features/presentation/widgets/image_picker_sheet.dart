import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<XFile?> pickUserImage(BuildContext context) {
  return showModalBottomSheet<XFile>(
    context: context,
    showDragHandle: true,
    builder: (context) => const _ImagePickerSheet(),
  );
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
