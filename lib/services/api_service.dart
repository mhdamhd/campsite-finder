import 'package:campsite_finder/models/campsite.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ApiService {
  final Dio _dio;
  static const String baseUrl = 'https://62ed0389a785760e67622eb2.mockapi.io/spots/v1';

  ApiService({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
  }

  Future<List<Campsite>> getCampsites() async {
    try {
      final response = await _dio.get('/campsites');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((json) => Campsite.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw ApiException('Failed to load campsites', response.statusCode ?? 0);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException('Unexpected error occured: $e', 0);
    }
  }

  ApiException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException('Connection timeout. Please check your internet connection.', 408);

      case DioExceptionType.connectionError:
        return ApiException('No internet connection. Please check your network.', 0);

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 0;
        final message = error.response?.statusMessage ?? 'Unknown error';
        return ApiException('Server error: $message', statusCode);

      case DioExceptionType.cancel:
        return ApiException('Request was cancelled', 0);

      case DioExceptionType.unknown:
      default:
        return ApiException('Network error occurred', 0);
    }
  }

}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  const ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});