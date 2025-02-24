//Importation des packages et bibliothèques nécessaires
import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; //requêtes HTTP
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; //stockage sécurisé des données
import 'package:hatch/Pages/Scenario1/creer_un_compte.dart';
import 'package:logger/logger.dart';
import 'package:hatch/Pages/Scenario1/Reinit_mot_de_passe.dart';
import 'package:email_validator/email_validator.dart'; //validation du format des emails

class SeConnecter extends StatefulWidget {
  const SeConnecter({Key? key}) : super(key: key);

  @override
  _SeConnecterState createState() => _SeConnecterState();
}

class _SeConnecterState extends State<SeConnecter> {
  //Gestion des champs de saisie
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Dio _dio = Dio(); //objet pour envoyer des requêtes HTTP
  final Logger _logger = Logger();

  //Variables d'état
  bool _loading = false; //true si la connexion est en cours
  bool _rememberMe =
      false; //true si l'utilisateur veut mémoriser ses identifiants
  String? _errorMessage; //message d'erreur en cas d'échec de connexion
  bool _isEmailValid = true; //verification du format du mail
  bool _obscurePassword = true; //mot de passe masqué
  bool _isButtonEnabled =
      false; //bouton connexion cliquable uniquement si tous les champs sont remplis

  //Fonction pour mettre à jour l'état du bouton connexion (vérification de la validité du format du mail et que les champs ne sont pas vides)
  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _isEmailValid;
    });
  }

  //Fonction pour mettre à jour l'UI en activant l'état de chargement
  Future<void> _login() async {
    setState(() {
      _loading = true;
      _errorMessage = null; //réinitialisation du message d'erreur
    });

    //Envoi de la requête HTTP
    try {
      Response response = await _dio.post(
        'http://localhost:8080/auth/token',
        options: Options(contentType: Headers.formUrlEncodedContentType),
        data: {
          'username': _emailController.text.trim(),
          'password': _passwordController.text,
        },
      );

      //Traitement de la réponse
      if (response.data.containsKey('access_token')) {
        String token = response.data['access_token'];
        await _storage.write(key: 'jwt_token', value: token);
        _logger.i("Login Success: Token -> $token");

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Connexion réussie !')),
          );
          Navigator.pushNamed(context, '/home');
        }
      }
      //Gestion des erreurs
    } catch (e) {
      if (e is DioException) {
        _logger.e("Error Response: ${e.response?.data}");
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

  //Interface UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo
            Center(
              child: Image.asset(
                'images/color_logo.png',
                height: 200,
              ),
            ),
            const SizedBox(height: 20),

            // Champs de saisie
            IgnorePointer(
              //empêche l'interaction avec les champs de saisie pendant la connexion
              ignoring: _loading,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEmailField(),
                  _buildPasswordField(),

                  const SizedBox(height: 15),
                  if (_errorMessage != null)
                    Padding(
                      padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.075),
                      child: Text(
                        //affichage du message d'erreur s'il y a un problème de connexion
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 13,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),

                  // Mémoriser identifiants + Mot de passe oublié
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
                                onChanged: _loading
                                    ? null
                                    : (bool? newValue) {
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
                            AbsorbPointer(
                              //élément désactivé pendant le chargement
                              absorbing: _loading,
                              child: TextButton(
                                onPressed: _loading
                                    ? null
                                    : () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const ReinitMotDePasse(),
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
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),

                  //Bouton de connexion
                  Center(
                    child: _loading
                        ? const CircularProgressIndicator() //indicateur de chargement
                        : ElevatedButton(
                            onPressed:
                                (_isButtonEnabled && !_loading) ? _login : null,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: Colors.transparent,
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: (_isButtonEnabled)
                                    ? const LinearGradient(
                                        colors: [
                                          Color(0xFFB9ADFF),
                                          Color(0xFF9381FF)
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      )
                                    : null,
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

                  const SizedBox(height: 20),
                  //Bouton création de compte
                  Center(
                    child: AbsorbPointer(
                      //inactif pendant le chargement de la connexion
                      absorbing: _loading,
                      child: TextButton(
                        onPressed: _loading
                            ? null
                            : () {
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
                  ),
                ],
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
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                errorText: _isEmailValid
                    ? null
                    : 'Format email invalide', // Message d'erreur
              ),
              onChanged: (value) {
                setState(() {
                  _isEmailValid = EmailValidator.validate(value);
                });
                _updateButtonState();
              },
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
              obscureText: _obscurePassword,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                color: Color(0xFF666666),
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              onChanged: (value) {
                _updateButtonState();
              },
            ),
          ),
        ),
      ],
    );
  }
}
