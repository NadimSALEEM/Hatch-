import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

class SeConnecter extends StatefulWidget {
  const SeConnecter({Key? key}) : super(key: key);

  @override
  _SeConnecterState createState() => _SeConnecterState();
}

class _SeConnecterState extends State<SeConnecter> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Dio _dio = Dio();
  final Logger _logger = Logger();

  bool _loading = false;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      Response response = await _dio.post(
        'http://localhost:80/auth/token',
        options: Options(contentType: Headers.formUrlEncodedContentType),
        data: {
          'username': _emailController.text.trim(),
          'password': _passwordController.text,
        },
      );

      if (response.data.containsKey('access_token')) {
        String token = response.data['access_token'];
        await _storage.write(key: 'jwt_token', value: token);
        _logger.i("✅ Login Success: Token -> $token");

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Connexion réussie !')),
          );
          Navigator.pushNamed(context, '/home');
        }
      }
    } catch (e) {
      if (e is DioException) {
        _logger.e("🛠️ Error Response: ${e.response?.data}");
      }
      setState(() {
        _errorMessage = "Échec de la connexion. Vérifiez vos identifiants.";
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Se connecter')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildEmailField(),
            _buildPasswordField(),
            if (_errorMessage != null)
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    child: const Text('Connexion'),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: _emailController,
      decoration: const InputDecoration(labelText: 'Email'),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      decoration: const InputDecoration(labelText: 'Mot de passe'),
      obscureText: true,
    );
  }
}
