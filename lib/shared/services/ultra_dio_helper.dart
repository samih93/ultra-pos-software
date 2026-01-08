import 'dart:io';

import 'package:desktoppossystem/shared/config/secure_config.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/services/dependency_injection.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

/// user token and current user key from secure storage in headers
class UltraDioHelper {
  final Dio dio;

  UltraDioHelper(this.dio);

  Future<void> init() async {
    // Fix SSL certificate verification issue
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () =>
        HttpClient()
          ..badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
  }

  /// Get authentication headers from secure storage
  Future<Map<String, String>> _getAuthHeaders() async {
    try {
      final securePrefs = globalAppWidgetRef.read(securePreferencesProvider);

      // Get token and current user key from secure storage
      final userId = await securePrefs.getData(key: "registrationUserId") ?? "";
      final token = SecureConfig.ultraPosTokenKey;
      return {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'x-custom-header': 'core_header',
        'Authorization': 'Bearer $token',
        'x-user-id': "user$userId",
      };
    } catch (e) {
      // Fallback to basic headers if secure storage fails
      return {'Content-Type': 'application/json', 'Accept': 'application/json'};
    }
  }

  Future<Response> getData({
    required String endPoint,
    Map<String, dynamic>? query,
  }) async {
    try {
      dio.options.connectTimeout = const Duration(seconds: 15);

      // Get auth headers and merge with any additional headers
      final authHeaders = await _getAuthHeaders();
      dio.options.headers = {...authHeaders};

      return await dio.get(endPoint, queryParameters: query);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout occurred!');
      } else if (e.error is SocketException) {
        throw Exception(
          'No internet connection or DNS resolution failed. Please check your network.',
        );
      } else if (e.response != null && e.response?.data != null) {
        // Extract the actual error message from the response body
        final errorData = e.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          throw Exception(errorData['message']);
        } else {
          throw Exception('${e.message}');
        }
      } else {
        print('Dio error: ${e.message}');
        throw Exception('${e.message}');
      }
    } catch (e) {
      print('Unexpected error: $e');
      throw Exception('$e');
    }
  }

  Future<Response> postData({
    required String endPoint,
    Map<String, dynamic>? query,
    Map<String, dynamic>? data,
  }) async {
    try {
      dio.options.connectTimeout = const Duration(seconds: 15);

      // Get auth headers and merge with any additional headers
      final authHeaders = await _getAuthHeaders();
      dio.options.headers = {...authHeaders};

      return await dio.post(endPoint, queryParameters: query, data: data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout occurred!');
      } else if (e.error is SocketException) {
        throw Exception(
          'No internet connection or DNS resolution failed. Please check your network.',
        );
      } else if (e.response != null && e.response?.data != null) {
        // Extract the actual error message from the response body
        final errorData = e.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          throw Exception(errorData['message']);
        } else {
          throw Exception('${e.message}');
        }
      } else {
        print('Dio error: ${e.message}');
        throw Exception('${e.message}');
      }
    } catch (e) {
      print('Unexpected error: $e');
      throw Exception('$e');
    }
  }

  Future<Response> updateData({
    required String endPoint,
    Map<String, dynamic>? query,
    Map<String, dynamic>? data,
  }) async {
    try {
      dio.options.connectTimeout = const Duration(seconds: 15);

      // Get auth headers and merge with any additional headers
      final authHeaders = await _getAuthHeaders();
      dio.options.headers = {...authHeaders};

      return await dio.patch(endPoint, queryParameters: query, data: data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout occurred!');
      } else if (e.error is SocketException) {
        throw Exception(
          'No internet connection or DNS resolution failed. Please check your network.',
        );
      } else if (e.response != null && e.response?.data != null) {
        // Extract the actual error message from the response body
        final errorData = e.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          throw Exception(errorData['message']);
        } else {
          throw Exception('${e.message}');
        }
      } else {
        print('Dio error: ${e.message}');
        throw Exception('${e.message}');
      }
    } catch (e) {
      print('Unexpected error: $e');
      throw Exception('$e');
    }
  }

  Future<Response> delete({
    required String endPoint,
    Map<String, dynamic>? query,
    Map<String, dynamic>? data,
  }) async {
    try {
      dio.options.connectTimeout = const Duration(seconds: 15);

      // Get auth headers and merge with any additional headers
      final authHeaders = await _getAuthHeaders();
      dio.options.headers = {...authHeaders};

      final response = await dio.delete(
        endPoint,
        queryParameters: query,
        data: data,
      );
      return response;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout occurred!');
      } else if (e.error is SocketException) {
        throw Exception(
          'No internet connection or DNS resolution failed. Please check your network.',
        );
      } else if (e.response != null && e.response?.data != null) {
        // Extract the actual error message from the response body
        final errorData = e.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          throw Exception(errorData['message']);
        } else {
          throw Exception('${e.message}');
        }
      } else {
        print('Dio error: ${e.message}');
        throw Exception('${e.message}');
      }
    } catch (e) {
      print('Unexpected error: $e');
      throw Exception('$e');
    }
  }

  Future<Response> putData({
    required String endPoint,
    Map<String, dynamic>? query,
    dynamic data, // Changed to dynamic to accept both Map and String
    Map<String, String>? additionalHeaders,
  }) async {
    try {
      dio.options.connectTimeout = const Duration(seconds: 15);

      // Get auth headers and merge with any additional headers
      final authHeaders = await _getAuthHeaders();
      dio.options.headers = {...authHeaders, ...?additionalHeaders};

      return await dio.put(endPoint, queryParameters: query, data: data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout occurred!');
      } else if (e.error is SocketException) {
        throw Exception(
          'No internet connection or DNS resolution failed. Please check your network.',
        );
      } else if (e.response != null && e.response?.data != null) {
        // Extract the actual error message from the response body
        final errorData = e.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          throw Exception(errorData['message']);
        } else {
          throw Exception('${e.message}');
        }
      } else {
        print('Dio error: ${e.message}');
        throw Exception('${e.message}');
      }
    } catch (e) {
      print('Unexpected error: $e');
      throw Exception('$e');
    }
  }
}
