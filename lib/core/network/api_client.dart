import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../errors/app_exception.dart';
import '../services/storage_service.dart';

class ApiClient {
  ApiClient({
    required StorageService storageService,
  })  : _storageService = storageService,
        _dio = Dio(
          BaseOptions(
            baseUrl: AppConfig.baseUrl,
            connectTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 20),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _storageService.token;

          if (AppConfig.shouldUseNgrokHeader) {
            options.headers['ngrok-skip-browser-warning'] = 'true';
          }

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          _logRequest(options);
          handler.next(options);
        },
        onResponse: (response, handler) {
          _logResponse(response);
          handler.next(response);
        },
        onError: (error, handler) {
          _logError(error);
          handler.reject(error);
        },
      ),
    );
  }

  final Dio _dio;
  final StorageService _storageService;

  void _logRequest(RequestOptions options) {
    if (!AppConfig.isDev) {
      return;
    }

    developer.log(
      'REQUEST ${options.method} ${options.uri}\n'
      'query: ${options.queryParameters}\n'
      'body: ${options.data}',
      name: _logNameFromPath(options.path),
    );
  }

  void _logResponse(Response<dynamic> response) {
    if (!AppConfig.isDev) {
      return;
    }

    developer.log(
      'RESPONSE ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri}\n'
      'data: ${response.data}',
      name: _logNameFromPath(response.requestOptions.path),
    );
  }

  void _logError(DioException error) {
    if (!AppConfig.isDev) {
      return;
    }

    developer.log(
      'ERROR ${error.response?.statusCode ?? '-'} ${error.requestOptions.method} ${error.requestOptions.uri}\n'
      'message: ${error.message}\n'
      'response: ${error.response?.data}',
      name: _logNameFromPath(error.requestOptions.path),
      error: error,
    );
  }

  String _logNameFromPath(String path) {
    final cleaned = path
        .replaceAll(RegExp(r'^/+|/+$'), '')
        .split('/')
        .where((segment) => segment.isNotEmpty)
        .join('_')
        .replaceAll(RegExp(r'[^a-zA-Z0-9_]+'), '_')
        .toLowerCase();

    if (cleaned.isEmpty) {
      return 'api_call';
    }

    final segments = cleaned.split('_');
    final preferred = segments.isNotEmpty ? segments.last : cleaned;
    return '${preferred}_api_call';
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );

      return response.data ?? <String, dynamic>{};
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );

      return response.data ?? <String, dynamic>{};
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  AppException _mapDioException(DioException error) {
    final responseData = error.response?.data;
    final statusCode = error.response?.statusCode;

    if (responseData is Map<String, dynamic>) {
      final message = responseData['message'];
      if (message is String && message.isNotEmpty) {
        return AppException(message, statusCode: statusCode);
      }
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppException('Koneksi timeout. Coba lagi.', statusCode: statusCode);
      case DioExceptionType.connectionError:
        return AppException(
          'Tidak bisa terhubung ke server.',
          statusCode: statusCode,
        );
      default:
        return AppException(
          'Terjadi kesalahan pada jaringan.',
          statusCode: statusCode,
        );
    }
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );

      return response.data ?? <String, dynamic>{};
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.delete<Map<String, dynamic>>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );

      return response.data ?? <String, dynamic>{};
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }
}
