import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

class DioHelper {
  Dio dio;
  DioHelper(this.dio);

  Future<void> init() async {
    // erooooorrrr befor added this
    //DioError [DioErrorType.other]: HandshakeException: Handshake error in client (OS Error: I/flutter ( 9085):
    // CERTIFICATE_VERIFY_FAILED: unable to get local issuer certificate(handshake.cc:359))

    // ignore: deprecated_member_use
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () =>
        HttpClient()
          ..badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
  }

  Future<Response> getData(
      {required String url, Map<String, dynamic>? query}) async {
    try {
      dio.options.connectTimeout = const Duration(seconds: 15);

      dio.options.headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      return await dio.get(url, queryParameters: query);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout occurred!');
      } else if (e.error is SocketException) {
        throw Exception(
            'No internet connection or DNS resolution failed. Please check your network.');
      } else {
        throw Exception('An unexpected Dio error occurred: ${e.message}');
      }
    } catch (e) {
      // Catch any other type of exceptions not related to Dio
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<Response> postData({
    required String url,
    Map<String, dynamic>? query,
    Map<String, dynamic>? data,
  }) async {
    try {
      dio.options.connectTimeout = const Duration(seconds: 15);

      dio.options.headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      return dio.post(
        url,
        queryParameters: query,
        data: data,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout occurred!');
      } else if (e.error is SocketException) {
        throw Exception(
            'No internet connection or DNS resolution failed. Please check your network.');
      } else {
        throw Exception('An unexpected Dio error occurred: ${e.message}');
      }
    } catch (e) {
      // Catch any other type of exceptions not related to Dio
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<Response> updateData({
    required String url,
    Map<String, dynamic>? query,
    Map<String, dynamic>? data,
  }) async {
    try {
      dio.options.connectTimeout = const Duration(seconds: 15);

      dio.options.headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      return dio.patch(
        url,
        queryParameters: query,
        data: data,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout occurred!');
      } else if (e.error is SocketException) {
        throw Exception(
            'No internet connection or DNS resolution failed. Please check your network.');
      } else {
        throw Exception('An unexpected Dio error occurred: ${e.message}');
      }
    } catch (e) {
      // Catch any other type of exceptions not related to Dio
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<Response> delete({
    required String url,
    Map<String, dynamic>? query,
    Map<String, dynamic>? data,
  }) async {
    try {
      dio.options.connectTimeout = const Duration(seconds: 15);

      dio.options.headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      return dio.delete(
        url,
        queryParameters: query,
        data: data,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout occurred!');
      } else if (e.error is SocketException) {
        throw Exception(
            'No internet connection or DNS resolution failed. Please check your network.');
      } else {
        throw Exception('An unexpected Dio error occurred: ${e.message}');
      }
    } catch (e) {
      // Catch any other type of exceptions not related to Dio
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
