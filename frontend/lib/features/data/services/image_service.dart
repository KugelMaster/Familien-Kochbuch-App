import 'dart:io';

import 'package:dio/dio.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/network/endpoints.dart';
import 'package:frontend/core/utils/logger.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImageService {
  final ApiClient _client;

  ImageService(this._client);

  Future<int> uploadImage(XFile image, String tag) async {
    final file = await MultipartFile.fromFile(image.path, filename: image.name);
    final formData = FormData.fromMap({"file": file, "tag": tag});

    final response = await _client.dio.post<Map>(
      Endpoints.images,
      data: formData,
      options: Options(
        responseType: ResponseType.json,
        contentType: image.mimeType,
      ),
    );

    return response.data?["id"] ?? -1;
  }

  Future<XFile> getImage(int imageId) async {
    final response = await _client.dio.get<List<int>>(
      Endpoints.image(imageId),
      options: Options(responseType: ResponseType.bytes),
    );

    final bytes = response.data;

    if (bytes == null) {
      logger.d(
        "Failed to load image: ${response.statusCode} ${response.statusMessage}",
      );
      throw Exception("Failed to load image");
    }

    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/image_$imageId.jpg");

    await file.writeAsBytes(bytes);

    return XFile(file.path);

    // Shorter version, but doesn't work if the file is requested via path :-(
    //return XFile.fromData(
    //  Uint8List.fromList(bytes),
    //  mimeType: response.headers.value(Headers.contentTypeHeader) ?? "image/jpeg",
    //);
  }
}
