import 'package:dio/dio.dart';

typedef FirebaseTokenProvider = Future<String?> Function();

class PocketTarotApiClient {
  PocketTarotApiClient({
    Dio? dio,
    FirebaseTokenProvider? tokenProvider,
    String baseUrl = const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://127.0.0.1:4000/api/v1',
    ),
  }) : _dio = dio ?? Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        )),
       _tokenProvider = tokenProvider ?? (() async => null) {
    _dio.options.baseUrl = _dio.options.baseUrl.isEmpty
        ? baseUrl
        : _dio.options.baseUrl;
    _dio.options.validateStatus = (_) => true;
  }

  final Dio _dio;
  final FirebaseTokenProvider _tokenProvider;

  Future<Map<String, Object?>> getJson(String path) async {
    final response = await _dio.get<Object?>(
      path,
      options: await _authOptions(),
    );
    return _readJsonResponse(response);
  }

  Future<Map<String, Object?>> postJson(
    String path,
    Map<String, Object?> body,
  ) async {
    final response = await _dio.post<Object?>(
      path,
      data: body,
      options: await _authOptions(),
    );
    return _readJsonResponse(response);
  }

  Future<Map<String, Object?>> patchJson(
    String path,
    Map<String, Object?> body,
  ) async {
    final response = await _dio.patch<Object?>(
      path,
      data: body,
      options: await _authOptions(),
    );
    return _readJsonResponse(response);
  }

  Future<Map<String, Object?>> deleteJson(String path) async {
    final response = await _dio.delete<Object?>(
      path,
      options: await _authOptions(),
    );
    return _readJsonResponse(response);
  }

  Future<Options> _authOptions() async {
    final token = await _tokenProvider();
    if (token == null || token.isEmpty) {
      return Options();
    }

    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Map<String, Object?> _readJsonResponse(Response<Object?> response) {
    final data = response.data;
    final json = data is Map
        ? data.cast<String, Object?>()
        : <String, Object?>{};

    if ((response.statusCode ?? 500) >= 400) {
      final error = json['error'];
      if (error is Map) {
        final errorJson = error.cast<String, Object?>();
        throw ApiException(
          statusCode: response.statusCode ?? 500,
          code: errorJson['code'] as String? ?? 'INTERNAL_ERROR',
          message: errorJson['message'] as String? ?? 'Request failed',
          details: errorJson['details'] is Map
              ? (errorJson['details'] as Map).cast<String, Object?>()
              : const {},
        );
      }

      throw ApiException(
        statusCode: response.statusCode ?? 500,
        code: 'INTERNAL_ERROR',
        message: 'Request failed',
      );
    }

    return json;
  }
}

class ApiException implements Exception {
  const ApiException({
    required this.statusCode,
    required this.code,
    required this.message,
    this.details = const {},
  });

  final int statusCode;
  final String code;
  final String message;
  final Map<String, Object?> details;

  @override
  String toString() => 'ApiException($statusCode, $code, $message)';
}
