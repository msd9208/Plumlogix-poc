import 'package:jwt_decoder/jwt_decoder.dart';

/// User model representing authenticated user data
class UserModel {
  final String id;
  final String name;
  final String email;
  final String? profilePicture;
  final String provider; 
  final Map<String, dynamic> claims;
  
  UserModel({ 
    required this.id,
    required this.name,
    required this.email,
    this.profilePicture,
    required this.provider,
    this.claims = const {},
  });
  

  factory UserModel.fromIdToken(String idToken, String provider) {
    try {
      final decodedToken = JwtDecoder.decode(idToken);
      
      return UserModel(
        id: decodedToken['sub'] ?? decodedToken['user_id'] ?? 'unknown',
        name: decodedToken['name'] ?? decodedToken['preferred_username'] ?? 'User',
        email: decodedToken['email'] ?? 'user@example.com',
        profilePicture: decodedToken['picture'],
        provider: provider,
        claims: decodedToken,
      );
    } catch (e) {
      return UserModel.demo(provider);
    }
  }
  
  factory UserModel.demo(String provider) {
    return UserModel(
      id: 'demo_user_123',
      name: 'Demo User',
      email: 'demo.user@plumlogix.com',
      profilePicture: null,
      provider: provider,
      claims: {
        'sub': 'demo_user_123',
        'name': 'Demo User',
        'email': 'demo.user@plumlogix.com',
        'iss': provider == 'salesforce' 
            ? 'https://login.salesforce.com' 
            : 'https://anypoint.mulesoft.com',
        'aud': 'demo_client_id',
        'exp': DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000,
        'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      },
    );
  }
  
  /// Get token expiry time
  DateTime? get tokenExpiry {
    if (claims.containsKey('exp')) {
      return DateTime.fromMillisecondsSinceEpoch(claims['exp'] * 1000);
    }
    return null;
  }
  
  /// Get issuer
  String? get issuer => claims['iss'];
  
  /// Get audience
  String? get audience => claims['aud'];
  
  /// Get user initials for avatar
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profilePicture': profilePicture,
      'provider': provider,
      'claims': claims,
    };
  }
  
  /// Create from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profilePicture: json['profilePicture'],
      provider: json['provider'],
      claims: json['claims'] ?? {},
    );
  }
}
