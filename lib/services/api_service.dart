import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import '../models/sign_prediction.dart';

class ApiService {
  ApiService({http.Client? client, String? baseUrl})
      : _client = client ?? _createDefaultClient(),
        _baseUrl = baseUrl ?? _defaultBaseUrl;

  static const String _defaultBaseUrl = 'https://thick-weeks-happen.loca.lt';

  final http.Client _client;
  final String _baseUrl;

  /// Longer timeouts so slow backend (first inference) doesn't cause "Connection timed out".
  static http.Client _createDefaultClient() {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 30);
    client.idleTimeout = const Duration(seconds: 90);
    return IOClient(client);
  }

  Uri _buildUri(String path) => Uri.parse('$_baseUrl$path');

  /// Calls the `/predict` endpoint with an image for sign detection.
  Future<SignPrediction> predictSign(File imageFile) async {
    final uri = _buildUri('/predict');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Bypass-Tunnel-Reminder'] = 'true'
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    final streamed = await _client.send(request);
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      throw HttpException(
        'Failed to predict sign: ${response.statusCode}',
        uri: uri,
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return SignPrediction.fromJson(data);
  }
}

