import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage service using native platform keystores
/// HIPAA Compliant - stores sensitive data encrypted at rest
/// Uses Android Keystore and iOS Keychain automatically
class StorageService {
  // Singleton pattern
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();
  
  // FlutterSecureStorage instance with iOS specific options
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );
  
  // Storage keys
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyTokenExpiry = 'token_expiry';
  static const String _keyIdToken = 'id_token';
  static const String _keyAuthProvider = 'auth_provider'; // salesforce or mulesoft
  
  /// Save authentication tokens securely
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
    String? idToken,
    DateTime? expiryTime,
    String? provider,
  }) async {
    await _secureStorage.write(key: _keyAccessToken, value: accessToken);
    
    if (refreshToken != null) {
      await _secureStorage.write(key: _keyRefreshToken, value: refreshToken);
    }
    
    if (idToken != null) {
      await _secureStorage.write(key: _keyIdToken, value: idToken);
    }
    
    if (expiryTime != null) {
      await _secureStorage.write(
        key: _keyTokenExpiry, 
        value: expiryTime.millisecondsSinceEpoch.toString(),
      );
    }
    
    if (provider != null) {
      await _secureStorage.write(key: _keyAuthProvider, value: provider);
    }
  }
  
  /// Get access token
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _keyAccessToken);
  }
  
  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _keyRefreshToken);
  }
  
  /// Get ID token (contains user info)
  Future<String?> getIdToken() async {
    return await _secureStorage.read(key: _keyIdToken);
  }
  
  /// Get token expiry time
  Future<DateTime?> getTokenExpiry() async {
    final expiryStr = await _secureStorage.read(key: _keyTokenExpiry);
    if (expiryStr != null) {
      return DateTime.fromMillisecondsSinceEpoch(int.parse(expiryStr));
    }
    return null;
  }
  
  /// Get auth provider
  Future<String?> getAuthProvider() async {
    return await _secureStorage.read(key: _keyAuthProvider);
  }
  
  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) return false;
    
    // Check if token is expired
    final expiry = await getTokenExpiry();
    if (expiry != null && expiry.isBefore(DateTime.now())) {
      return false;
    }
    
    return true;
  }
  
  /// Check if token is about to expire (within 5 minutes)
  Future<bool> shouldRefreshToken() async {
    final expiry = await getTokenExpiry();
    if (expiry == null) return false;
    
    final fiveMinutesFromNow = DateTime.now().add(const Duration(minutes: 5));
    return expiry.isBefore(fiveMinutesFromNow);
  }
  
  /// Delete all stored tokens (logout)
  Future<void> deleteAll() async {
    await _secureStorage.deleteAll();
  }
  
  /// Delete specific key
  Future<void> delete(String key) async {
    await _secureStorage.delete(key: key);
  }
  
  /// Save any generic secure data
  Future<void> saveSecure(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }
  
  /// Read any generic secure data
  Future<String?> readSecure(String key) async {
    return await _secureStorage.read(key: key);
  }
}
