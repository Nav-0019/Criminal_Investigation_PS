import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiConfig {
  /// ─── CHANGE THIS TO YOUR DEPLOYED BACKEND URL ───────────────────────
  ///
  /// Local development (Android emulator → host machine):
  ///   static const String baseUrl = 'http://10.0.2.2:8000';
  ///
  /// Local development (physical device on same Wi-Fi):
  ///   static const String baseUrl = 'http://192.168.x.x:8000';
  ///
  /// Production (deployed to Railway/Render/Cloud Run):
  ///   static const String baseUrl = 'https://your-app.up.railway.app';
  ///
  static const String baseUrl = 'https://shubham0019-nammashield-api.hf.space';

  /// Request timeout duration (increased to 60 minutes for massive 159MB files)
  static const Duration timeout = Duration(minutes: 60);
}

class ApiService {
  /// Check if the backend server is reachable
  static Future<bool> checkHealth() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/health');
      final response = await http
          .get(url)
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Send an audio file to the backend for analysis
  static Future<Map<String, dynamic>> analyzeAudio(String filePath) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/analyze/');

    try {
      // Verify file exists
      final file = File(filePath);
      if (!await file.exists()) {
        throw ApiException(
          message: 'Audio file not found at path: $filePath',
          code: 'FILE_NOT_FOUND',
        );
      }

      var request = http.MultipartRequest('POST', url);
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      // Send with timeout
      var streamedResponse = await request.send().timeout(ApiConfig.timeout);
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final body = json.decode(response.body) as Map<String, dynamic>;
        if (body['success'] == true) {
          return body;
        } else {
          throw ApiException(
            message: body['detail'] ?? 'Analysis returned unsuccessful.',
            code: 'ANALYSIS_FAILED',
          );
        }
      } else if (response.statusCode == 400) {
        final body = json.decode(response.body);
        throw ApiException(
          message: body['detail'] ?? 'Invalid request.',
          code: 'BAD_REQUEST',
        );
      } else if (response.statusCode == 500) {
        final body = json.decode(response.body);
        throw ApiException(
          message: body['detail'] ?? 'Server error during analysis.',
          code: 'SERVER_ERROR',
        );
      } else {
        throw ApiException(
          message: 'Unexpected status code: ${response.statusCode}',
          code: 'HTTP_ERROR',
        );
      }
    } on ApiException {
      rethrow;
    } on SocketException {
      throw ApiException(
        message: 'Cannot connect to the server. '
            'Make sure the backend is running at ${ApiConfig.baseUrl}',
        code: 'CONNECTION_ERROR',
      );
    } on HttpException {
      throw ApiException(
        message: 'HTTP error while contacting the server.',
        code: 'HTTP_ERROR',
      );
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw ApiException(
          message: 'Request timed out. The audio file may be too large '
              'or the server is busy.',
          code: 'TIMEOUT',
        );
      }
      throw ApiException(
        message: 'Unexpected error: $e',
        code: 'UNKNOWN',
      );
    }
  }
}

/// Custom exception for API errors with user-friendly messages
class ApiException implements Exception {
  final String message;
  final String code;

  ApiException({required this.message, required this.code});

  @override
  String toString() => 'ApiException($code): $message';
}
