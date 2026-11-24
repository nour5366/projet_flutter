import 'package:flutter/foundation.dart' show kIsWeb;

/// Adresse du backend Spring Boot.
/// - Chrome (web)       : localhost
/// - Emulateur Android  : 10.0.2.2 (alias du PC hote)
class ApiConfig {
  static const int port = 8081;

  static String get baseUrl =>
      kIsWeb ? 'http://localhost:$port' : 'http://10.0.2.2:$port';
}
