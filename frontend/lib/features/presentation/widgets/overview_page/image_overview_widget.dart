import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/features/presentation/shared/async_image_widget.dart';
import 'package:frontend/features/presentation/shared/image_picker_sheet.dart';
import 'package:image_picker/image_picker.dart';

class ImageOverviewWidget extends StatelessWidget {
  final int? imageId;
  final void Function(XFile image) updateImage;
  final double screenHeight;

  const ImageOverviewWidget({
    super.key,
    required this.imageId,
    required this.updateImage,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: screenHeight * 0.6,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            child: AsyncImageWidget(
              imageId: imageId,
              placeholder: _filler(context),
              onData: (image) =>
                  Image.file(File(image.path), fit: BoxFit.cover),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            height: 160,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.transparent, Colors.black54],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filler(BuildContext context) => InkWell(
    onTap: () async {
      final picked = await pickUserImage(context);

      if (picked == null) return;

      updateImage(picked);
    },
    child: Container(
      color: Colors.grey.shade200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.add_a_photo, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            "Foto hinzufügen",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    ),
  );
}
