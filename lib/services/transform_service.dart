import 'dart:typed_data';
import 'package:http/http.dart' as http;

class TransformService {
  const TransformService({required this.endpoint});
  final String endpoint;

  Future<Uint8List> transform({
    required Uint8List jpegBytes,
    required String prompt,
    required int resolution, // 512 ou 1024
  }) async {
    final size = (resolution == 512) ? 512 : 1024;

    final req = http.MultipartRequest('POST', Uri.parse(endpoint))
      ..fields['prompt'] = prompt
      ..fields['size'] = '$size'
      ..files.add(
        http.MultipartFile.fromBytes(
          'image',
          jpegBytes,
          filename: 'input.jpg',
        ),
      );

    final streamed = await req.send().timeout(const Duration(minutes: 2));
    final res = await http.Response.fromStream(streamed);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw 'HTTP ${res.statusCode}: ${res.body}';
    }

    // ✅ image bytes directe (PNG)
    return res.bodyBytes;
  }
}
