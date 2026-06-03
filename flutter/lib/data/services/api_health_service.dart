import 'package:dio/dio.dart';

class ApiHealthService {
  ApiHealthService({
    Dio? dio,
    String baseUrl = const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://127.0.0.1:4000/api/v1',
    ),
  })  : _dio = dio ?? Dio(),
        _healthUri = _healthUriFromBaseUrl(baseUrl) {
    _dio.options.validateStatus = (_) => true;
    _dio.options.connectTimeout = const Duration(seconds: 4);
    _dio.options.receiveTimeout = const Duration(seconds: 4);
  }

  final Dio _dio;
  final Uri _healthUri;

  Future<bool> isAvailable() async {
    try {
      final response = await _dio.getUri<Object?>(_healthUri);
      final data = response.data;
      final json = data is Map ? data.cast<String, Object?>() : const <String, Object?>{};
      final payload = json['data'];
      final health = payload is Map ? payload.cast<String, Object?>() : const <String, Object?>{};

      return response.statusCode == 200 && health['status'] == 'ok';
    } catch (_) {
      return false;
    }
  }

  static Uri _healthUriFromBaseUrl(String baseUrl) {
    final uri = Uri.parse(baseUrl);
    final path = uri.path.endsWith('/api/v1') ? uri.path.substring(0, uri.path.length - '/api/v1'.length) : uri.path;
    final normalizedPath = path.endsWith('/') ? path.substring(0, path.length - 1) : path;

    return uri.replace(
      path: '$normalizedPath/healthz',
      query: null,
      fragment: null,
    );
  }
}
