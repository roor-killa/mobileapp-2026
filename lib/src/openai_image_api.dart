import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class OpenAIImageApi {
  static const _endpoint = 'https://api.openai.com/v1/images/edits';

  Future<Uint8List> editImage({
    required String apiKey,
    required File imageFile,
    required String prompt,
  }) async {
    final req = http.MultipartRequest('POST', Uri.parse(_endpoint));

    req.headers['Authorization'] = 'Bearer $apiKey';

    // Endpoint: POST /v1/images/edits (supports GPT Image models like gpt-image-1)
    req.fields['model'] = 'gpt-image-1';
    req.fields['prompt'] = prompt;
    req.fields['size'] = '1024x1024';

    req.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    final streamed = await req.send().timeout(const Duration(minutes: 3));
    final res = await http.Response.fromStream(streamed);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw 'HTTP ${res.statusCode} — ${_safeBody(res.body)}';
    }

    final jsonMap = json.decode(res.body) as Map<String, dynamic>;
    final data = (jsonMap['data'] as List).cast<Map<String, dynamic>>();
    if (data.isEmpty) throw 'Réponse vide';

    final b64 = data.first['b64_json'] as String?;
    if (b64 == null || b64.isEmpty) throw 'Image absente (b64_json)';

    return base64Decode(b64);
  }

  String _safeBody(String s) => s.length <= 600 ? s : s.substring(0, 600);
}
