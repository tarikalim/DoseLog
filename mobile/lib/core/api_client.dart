import 'dart:convert';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'token_manager.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final TokenManager _tokenManager = TokenManager();

  // Build headers with authentication token
  Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      final token = await _tokenManager.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // Handle response
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }
      return json.decode(response.body);
    } else {
      String errorMessage = 'Request failed';
      try {
        final errorBody = json.decode(response.body);
        errorMessage = errorBody['error'] ?? errorBody['message'] ?? errorMessage;
      } catch (e) {
        errorMessage = response.body.isNotEmpty ? response.body : errorMessage;
      }
      throw ApiException(errorMessage, response.statusCode);
    }
  }

  // GET request
  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? queryParams,
    bool includeAuth = true,
  }) async {
    try {
      final uri = Uri.parse('${AppConstants.apiUrl}$endpoint').replace(
        queryParameters: queryParams,
      );
      final headers = await _getHeaders(includeAuth: includeAuth);
      final response = await http.get(uri, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  // POST request
  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool includeAuth = true,
  }) async {
    try {
      final uri = Uri.parse('${AppConstants.apiUrl}$endpoint');
      final headers = await _getHeaders(includeAuth: includeAuth);
      final response = await http.post(
        uri,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  // PUT request
  Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool includeAuth = true,
  }) async {
    try {
      final uri = Uri.parse('${AppConstants.apiUrl}$endpoint');
      final headers = await _getHeaders(includeAuth: includeAuth);
      final response = await http.put(
        uri,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  // DELETE request
  Future<dynamic> delete(
    String endpoint, {
    bool includeAuth = true,
  }) async {
    try {
      final uri = Uri.parse('${AppConstants.apiUrl}$endpoint');
      final headers = await _getHeaders(includeAuth: includeAuth);
      final response = await http.delete(uri, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }
}
