import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class CompressService {
  Future<Uint8List> compressJpg(File input) async {
    return compute(_compress, input.path);
  }
}

Future<Uint8List> _compress(String path) async {
  final out = await FlutterImageCompress.compressWithFile(
    path,
    quality: 80,
    minWidth: 1400,
    minHeight: 1400,
    format: CompressFormat.jpeg,
  );
  if (out == null) throw 'Compression failed';
  return out;
}
