import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hatch/Pages/Scenario1/se_connecter.dart';

class AuthGuard extends StatefulWidget {
  final Widget page;

  const AuthGuard({Key? key, required this.page}) : super(key: key);

  @override
  _AuthGuardState createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  final _storage = const FlutterSecureStorage();
  bool? _isAuthenticated;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    String? token = await _storage.read(key: "jwt_token"); // Lire le token de l'utilisateur
    setState(() {
      _isAuthenticated = token != null; // Vérifier si le token existe
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthenticated == null) {
      return const Center(child: CircularProgressIndicator()); // Chargement
    }

    if (!_isAuthenticated!) {
      return const SeConnecter(); // Rediriger vers la page de connexion si l'utilisateur n'est pas connecté
    }

    return widget.page;
  }
}
