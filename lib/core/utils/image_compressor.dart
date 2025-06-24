import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageCompressor {
  static Future<Uint8List> compressUint8List(
    Uint8List inputBytes, {
    int minWidth = 800,
    int minHeight = 800,
    int quality = 70,
  }) async {
    final compressed = await FlutterImageCompress.compressWithList(
      inputBytes,
      minWidth: minWidth,
      minHeight: minHeight,
      quality: quality,
      format: CompressFormat.jpeg,
    );

    return compressed;
  }
}
