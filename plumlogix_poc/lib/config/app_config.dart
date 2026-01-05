
class AppConfig {
  static const String environment = String.fromEnvironment('ENV', defaultValue: 'dev');
  
  static const String salesforceClientId = String.fromEnvironment(
    'SALESFORCE_CLIENT_ID',
    defaultValue: 'demo_client_id', 
  );
  
  static const String salesforceRedirectUri = 'com.plumlogix.poc:/oauthredirect';
  
  static const String salesforceIssuer = 'https://login.salesforce.com';
  
  // MuleSoft OAuth Configuration (alternative)
  static const String muleoftClientId = String.fromEnvironment(
    'MULESOFT_CLIENT_ID',
    defaultValue: 'demo_mulesoft_client_id',
  );
  
  static const String muleoftRedirectUri = 'com.plumlogix.poc:/oauthredirect';
  
  static const String muleoftIssuer = String.fromEnvironment(
    'MULESOFT_ISSUER',
    defaultValue: 'https://anypoint.mulesoft.com',
  );
  
  // API Base URLs by environment
  static String get apiBaseUrl {
    switch (environment) {
      case 'prod':
        return String.fromEnvironment('API_BASE_URL', defaultValue: 'https://api.plumlogix.com');
      case 'qa':
        return String.fromEnvironment('API_BASE_URL', defaultValue: 'https://api-qa.plumlogix.com');
      case 'dev':
      default:
        return String.fromEnvironment('API_BASE_URL', defaultValue: 'https://jsonplaceholder.typicode.com');
    }
  }
  
  // OAuth Scopes
  static const List<String> oauthScopes = [
    'openid',
    'profile',
    'email',
    'api',
    'refresh_token',
    'offline_access',
  ];
  

  static const int sessionTimeoutMs = 3600000; // 1 hour

  static const bool demoMode = true; 
  
  static const bool enableSecureLogging = false; 
  static const bool enforceHttps = true;
  static const String minTlsVersion = '1.2';
}
