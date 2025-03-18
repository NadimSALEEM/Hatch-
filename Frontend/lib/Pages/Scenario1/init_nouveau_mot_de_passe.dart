import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';

class InitNouveauMotDePasse extends StatefulWidget {
  const InitNouveauMotDePasse({Key? key}) : super(key: key);

  @override
  _InitNouveauMotDePasseState createState() => _InitNouveauMotDePasseState();
}

class _InitNouveauMotDePasseState extends State<InitNouveauMotDePasse> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isPasswordValid = false;
  bool _isFieldEmpty = true;

  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _loading = false; // Pour gérer le chargement

  Future<void> _resetPassword() async {
    setState(() {
      _loading = true;
    });

    String? token = await _storage.read(key: 'jwt_token');
    if (token == null) {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Utilisateur non authentifié.")),
      );
      return;
    }


    try {
      Response response = await _dio.put(
        'http://localhost:8080/users/me/change_pw',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'mot_de_passe_hache': _passwordController.text,
        },
      );


      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Mot de passe mis à jour avec succès.")),
        );
        Navigator.pushReplacementNamed(context, '/profil');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Erreur lors de la mise à jour du mot de passe.")),
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  // Vérification du format du mot de passe
  final RegExp _passwordRegExp =
      RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2F2F2F)),
          onPressed: () => Navigator.pushReplacementNamed(context, '/profil'),
        ),
        title: const Text(
          'Réinitialiser mot de passe',
          style: TextStyle(
            fontSize: 17,
            fontFamily: 'NunitoBold',
            color: Color(0xFF2F2F2F),
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            color: Color(0xFFE0E0E0),
            thickness: 1,
            height: 1,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Entrez un nouveau mot de passe.",
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Nunito',
                color: Color(0xFF2F2F2F),
              ),
            ),

            const SizedBox(height: 25),

            _buildPasswordField(),

            const SizedBox(height: 20),

            // Bouton "Réinitialiser mot de passe"
            Center(
              child: _loading
                  ? const CircularProgressIndicator() // Affiche un loader si en cours de requête
                  : ElevatedButton(
                      onPressed:
                          (_isPasswordValid && !_isFieldEmpty && !_loading)
                              ? _resetPassword
                              : null,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: Colors.transparent,
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: (_isPasswordValid && !_isFieldEmpty)
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
                              vertical: 15, horizontal: 40),
                          child: Text(
                            'Réinitialiser mot de passe',
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'Nunito',
                              color: (_isPasswordValid && !_isFieldEmpty)
                                  ? Colors.white
                                  : Colors.grey[500],
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Champ de saisie du mot de passe avec validation
  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nouveau mot de passe',
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'Nunito',
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 8),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFEDEDED)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                color: Color(0xFF666666),
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                suffixIcon: IconButton(
                  // Icône visibilité mot de passe
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _isFieldEmpty = value.isEmpty;
                  _isPasswordValid = _passwordRegExp.hasMatch(value);
                });
              },
            ),
          ),

          const SizedBox(height: 8),

          // Message d'erreur si le mot de passe est invalide
          Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Text(
              (_isPasswordValid || _isFieldEmpty)
                  ? ''
                  : 'Min. 8 caractères, 1 majuscule, 1 chiffre, 1 caractère spécial',
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'Nunito',
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
