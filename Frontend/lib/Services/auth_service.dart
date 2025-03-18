import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Ce service permet de vérifier si un utilisateur est connecté
class AuthService {
  final _storage = const FlutterSecureStorage();

  Future<bool> isAuthenticated() async {
    String? token = await _storage.read(key: "jwt_token");
    return token != null;
  }
}
