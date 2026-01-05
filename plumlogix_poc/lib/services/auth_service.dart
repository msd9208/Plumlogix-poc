import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:plumlogix_poc/config/app_config.dart';
import 'package:plumlogix_poc/services/storage_service.dart';
import 'package:plumlogix_poc/models/user_model.dart';

import 'logging_service.dart';


class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();
  
  final FlutterAppAuth _appAuth = const FlutterAppAuth();
  final StorageService _storage = StorageService();
  
  /// Login with Salesforce using OAuth 2.0
  Future<bool> loginWithSalesforce() async {
    if (AppConfig.demoMode) {
      return await _mockLogin('salesforce');
    }
    
    try {
      final AuthorizationTokenResponse result =
          await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          AppConfig.salesforceClientId,
          AppConfig.salesforceRedirectUri,
          issuer: AppConfig.salesforceIssuer,
          scopes: AppConfig.oauthScopes,
          promptValues: ['login'],
        ),
      );
      
      await _saveAuthResult(result, 'salesforce');
      return true;
    } catch (e) {
      PrintLogs.printError('Salesforce OAuth error: $e');
      return false;
    }
  }
  
  /// Login with MuleSoft using OAuth 2.0
  Future<bool> loginWithMulesoft() async {
    if (AppConfig.demoMode) {
      return await _mockLogin('mulesoft');
    }
    
    try {
      final AuthorizationTokenResponse result =
          await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          AppConfig.muleoftClientId,
          AppConfig.muleoftRedirectUri,
          issuer: AppConfig.muleoftIssuer,
          scopes: AppConfig.oauthScopes,
          promptValues: ['login'],
        ),
      );
      
      await _saveAuthResult(result, 'mulesoft');
      return true;
    } catch (e) {
      PrintLogs.printError('MuleSoft OAuth error: $e');
      return false;
    }
  }
  
  /// Mock login for demo mode
  Future<bool> _mockLogin(String provider) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Create demo tokens
    final now = DateTime.now();
    final expiry = now.add(const Duration(hours: 1));
    
    await _storage.saveTokens(
      accessToken: 'demo_access_token_${now.millisecondsSinceEpoch}',
      refreshToken: 'demo_refresh_token',
      idToken: 'demo_id_token',
      expiryTime: expiry,
      provider: provider,
    );
    
    return true;
  }
  
  /// Save authentication result to secure storage
  Future<void> _saveAuthResult(
    AuthorizationTokenResponse result,
    String provider,
  ) async {
    DateTime? expiryTime;
    if (result.accessTokenExpirationDateTime != null) {
      expiryTime = result.accessTokenExpirationDateTime;
    }
    
    await _storage.saveTokens(
      accessToken: result.accessToken!,
      refreshToken: result.refreshToken,
      idToken: result.idToken,
      expiryTime: expiryTime,
      provider: provider,
    );
  }
  
  /// Refresh access token using refresh token
  Future<bool> refreshToken() async {
    if (AppConfig.demoMode) {
      final provider = await _storage.getAuthProvider() ?? 'salesforce';
      return await _mockLogin(provider);
    }
    
    try {
      final refreshToken = await _storage.getRefreshToken();
      final provider = await _storage.getAuthProvider();
      
      if (refreshToken == null || provider == null) return false;
      
      final issuer = provider == 'salesforce' 
          ? AppConfig.salesforceIssuer 
          : AppConfig.muleoftIssuer;
      final clientId = provider == 'salesforce'
          ? AppConfig.salesforceClientId
          : AppConfig.muleoftClientId;
      final redirectUri = provider == 'salesforce'
          ? AppConfig.salesforceRedirectUri
          : AppConfig.muleoftRedirectUri;
      
      final TokenResponse result = await _appAuth.token(
        TokenRequest(
          clientId,
          redirectUri,
          issuer: issuer,
          refreshToken: refreshToken,
        ),
      );
      
      DateTime? expiryTime;
      if (result.accessTokenExpirationDateTime != null) {
        expiryTime = result.accessTokenExpirationDateTime;
      }
      
      await _storage.saveTokens(
        accessToken: result.accessToken!,
        refreshToken: result.refreshToken ?? refreshToken,
        idToken: result.idToken,
        expiryTime: expiryTime,
        provider: provider,
      );
      return true;
    } catch (e) {
      PrintLogs.printError('Token refresh error: $e');
      return false;
    }
  }
  
  /// Logout - clear all tokens and session data
  Future<void> logout() async {
    await _storage.deleteAll();
  }
  
  /// Get current authenticated user
  Future<UserModel?> getCurrentUser() async {
    final idToken = await _storage.getIdToken();
    final provider = await _storage.getAuthProvider();
    
    if (idToken != null && provider != null) {
      return UserModel.fromIdToken(idToken, provider);
    }
    
    // In demo mode, return a mock user
    if (AppConfig.demoMode && await _storage.isAuthenticated()) {
      return UserModel.demo(provider ?? 'salesforce');
    }
    
    return null;
  }
  
  /// Check if authenticated
  Future<bool> isAuthenticated() async {
    return await _storage.isAuthenticated();
  }
  
  /// Check and refresh token if needed
  Future<bool> ensureValidToken() async {
    if (!await isAuthenticated()) return false;
    
    if (await _storage.shouldRefreshToken()) {
      return await refreshToken();
    }
    
    return true;
  }
}
