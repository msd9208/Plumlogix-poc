import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:plumlogix_poc/config/app_config.dart';
import 'package:plumlogix_poc/services/storage_service.dart';
import 'package:plumlogix_poc/services/auth_service.dart';

/// REST API Service for MuleSoft integration
/// Handles all HTTP requests with bearer token authentication
/// Demonstrates secure API integration with error handling
class ApiService {
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();
  
  final StorageService _storage = StorageService();
  final AuthService _auth = AuthService();
  
  /// Get HTTP headers with bearer token authentication
  Future<Map<String, String>> _getHeaders() async {
    final accessToken = await _storage.getAccessToken();
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    };
  }
  
  /// GET request
  Future<ApiResponse> get(String endpoint) async {
    try {
      // Ensure valid token before making request
      await _auth.ensureValidToken();
      
      final url = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');
      final headers = await _getHeaders();
      
      final response = await http.get(url, headers: headers);
      
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }
  
  /// POST request
  Future<ApiResponse> post(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      await _auth.ensureValidToken();
      
      final url = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');
      final headers = await _getHeaders();
      
      final response = await http.post(
        url,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );
      
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }
  
  /// PUT request
  Future<ApiResponse> put(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      await _auth.ensureValidToken();
      
      final url = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');
      final headers = await _getHeaders();
      
      final response = await http.put(
        url,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );
      
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }
  
  /// DELETE request
  Future<ApiResponse> delete(String endpoint) async {
    try {
      await _auth.ensureValidToken();
      
      final url = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');
      final headers = await _getHeaders();
      
      final response = await http.delete(url, headers: headers);
      
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }
  
  /// Handle HTTP response
  ApiResponse _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final data = json.decode(response.body);
        return ApiResponse.success(data, response.statusCode);
      } catch (e) {
        // Response body might not be JSON
        return ApiResponse.success(response.body, response.statusCode);
      }
    } else if (response.statusCode == 401) {
      return ApiResponse.error('Unauthorized - Please login again', statusCode: 401);
    } else if (response.statusCode == 403) {
      return ApiResponse.error('Forbidden - Access denied', statusCode: 403);
    } else if (response.statusCode == 404) {
      return ApiResponse.error('Resource not found', statusCode: 404);
    } else if (response.statusCode >= 500) {
      return ApiResponse.error('Server error', statusCode: response.statusCode);
    } else {
      return ApiResponse.error(
        'Request failed: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }
}

/// API Response wrapper
class ApiResponse {
  final bool success;
  final dynamic data;
  final String? error;
  final int statusCode;
  
  ApiResponse._({
    required this.success,
    this.data,
    this.error,
    required this.statusCode,
  });
  
  factory ApiResponse.success(dynamic data, int statusCode) {
    return ApiResponse._(
      success: true,
      data: data,
      statusCode: statusCode,
    );
  }
  
  factory ApiResponse.error(String error, {int statusCode = 0}) {
    return ApiResponse._(
      success: false,
      error: error,
      statusCode: statusCode,
    );
  }
}
