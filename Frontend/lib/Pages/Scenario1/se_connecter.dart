import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hatch/Pages/Scenario1/creer_un_compte.dart';
import 'package:logger/logger.dart';
import 'package:hatch/Pages/Scenario1/Reinit_mot_de_passe.dart';

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
  bool _rememberMe = false;
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // Logo
          children: [
            Center(
              child: Image.asset(
                'images/color_logo.png',
                height: 200,
              ),
            ),
            const SizedBox(height: 20),

            // Champs de saisie
            _buildEmailField(),
            _buildPasswordField(),
            if (_errorMessage != null)
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 30),

            // Mémoriser identifiants / Lien "Mot de passe oublié"
            Padding(
              padding: const EdgeInsets.only(left: 0),
              child: Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Transform.scale(
                        scale: 0.8,
                        child: Checkbox(
                          value: _rememberMe,
                          onChanged: (bool? newValue) {
                            setState(() {
                              _rememberMe = newValue ?? false;
                            });
                          },
                          activeColor: const Color(0xFF9381FF),
                          checkColor: Colors.white,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "Mémoriser mes identifiants",
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Nunito',
                            color: const Color(0xFF666666),
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      // Lien "Mot de passe oublié"
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ReinitMotDePasse(),
                            ),
                          );
                        },
                        child: const Text(
                          'Mot de passe oublié ?',
                          style: TextStyle(
                            color: Color(0xFF9381FF),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 50),

            // Bouton Connexion
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/accueil');
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.transparent,
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFB9ADFF),
                        Color(0xFF9381FF),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 130),
                    child: Text(
                      'Connexion',
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'Nunito',
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Lien Inscrivez-vous
            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreerUnCompte(),
                    ),
                  );
                },
                child: const Text(
                  'Inscrivez-vous >',
                  style: TextStyle(
                    color: Color(0xFF9381FF),
                    fontSize: 14,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //Champs de saisie

  //Saisie du mail
  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.85,
            child: const Text(
              'Email',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                color: Color(0xFF666666),
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Color(0xFFEDEDED)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _emailController,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                color: Color(0xFF666666),
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  //Saisie du mot de passe
  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.85,
            child: const Text(
              'Mot de Passe',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                color: Color(0xFF666666),
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Color(0xFFEDEDED)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _passwordController,
              obscureText: true,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                color: Color(0xFF666666),
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}