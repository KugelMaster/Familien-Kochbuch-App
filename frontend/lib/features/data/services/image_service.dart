import 'dart:io';

import 'package:dio/dio.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/network/endpoints.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImageService {
  final ApiClient _client;

  ImageService(this._client);

  /// Uploads an image to the backend server with a tag.
  Future<int> uploadImage(XFile image, String tag) async {
    final file = await MultipartFile.fromFile(image.path, filename: image.name);
    final formData = FormData.fromMap({"file": file, "tag": tag});

    final response = await _client.dio.post(
      Endpoints.images,
      data: formData,
      options: Options(contentType: image.mimeType),
    );

    return response.data?["id"] ?? -1;
  }

  /// Fetches an image from the backend server with the given [imageId].
  /// Throws an [Exception] if the image could not be found / some other error occured.
  Future<XFile> getImage(int imageId) async {
    final response = await _client.dio.get(
      Endpoints.image(imageId),
      options: Options(responseType: ResponseType.bytes),
    );

    if (response.statusCode != 200) {
      if (response.data["code"] == "NOT_FOUND") {
        throw Exception("Image with ID $imageId not found");
      } else {
        throw Exception("Image could not be fetched");
      }
    }

    final bytes = response.data as List<int>;

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
