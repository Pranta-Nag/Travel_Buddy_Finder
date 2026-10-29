import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_buddy_finder/core/constants/api_constants.dart';

class ApiClient {
  ApiClient._();

  static const String _tokenKey = 'jwt_auth_token';
  static const Duration _requestTimeout = Duration(seconds: 30);

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<Map<String, String>> _headers([bool isJson = true]) async {
    final token = await getToken();
    final Map<String, String> headers = {
      'Accept': 'application/json',
    };
    if (isJson) {
      headers['Content-Type'] = 'application/json';
    } else {
      headers['Content-Type'] = 'application/x-www-form-urlencoded';
    }
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<http.Response> get(String endpoint) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final headers = await _headers();
    return http.get(uri, headers: headers).timeout(_requestTimeout);
  }

  static Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool isJson = true,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final headers = await _headers(isJson);

    if (isJson) {
      return http.post(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(_requestTimeout);
    } else {
      final Map<String, String> formBody = {};
      if (body != null) {
        for (final entry in body.entries) {
          formBody[entry.key] = entry.value?.toString() ?? '';
        }
      }
      return http.post(
        uri,
        headers: headers,
        body: formBody,
      ).timeout(_requestTimeout);
    }
  }

  static Future<http.Response> multipartPost(
    String endpoint, {
    Map<String, String>? fields,
    Map<String, List<int>>? filesBytes,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final request = http.MultipartRequest('POST', uri);

    request.headers['Accept'] = 'application/json';
    final token = await getToken();
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    if (fields != null) {
      request.fields.addAll(fields);
    }

    if (filesBytes != null) {
      for (final entry in filesBytes.entries) {
        final String filename = '${entry.key}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        request.files.add(http.MultipartFile.fromBytes(
          entry.key,
          entry.value,
          filename: filename,
          contentType: MediaType('image', 'jpeg'),
        ));
      }
    }

    final streamedResponse = await request.send().timeout(_requestTimeout);
    return http.Response.fromStream(streamedResponse).timeout(_requestTimeout);
  }
}
