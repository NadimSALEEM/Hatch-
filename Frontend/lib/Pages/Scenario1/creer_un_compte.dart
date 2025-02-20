import 'package:flutter/material.dart';

class CreerUnCompte extends StatefulWidget {
  const CreerUnCompte({Key? key}) : super(key: key);

  @override
  _CreerUnCompteState createState() => _CreerUnCompteState();
}

class _CreerUnCompteState extends State<CreerUnCompte> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _acceptTerms = false; // Variable pour vérifier si la case est cochée

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(context, '/se_connecter');
          },
        ),
        title: Text(
          'Inscription',
          style: TextStyle(fontFamily: 'BricolageGrotesqueBold', fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Ligne de séparation fixée avec le header
          Container(
            height: 1.0,
            color: Colors.black,
          ),
          SizedBox(height: 30),
          Expanded(
            child: SingleChildScrollView(
              // page scrollable
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildTextField(_usernameController, 'Nom d\'Utilisateur'),
                  _buildTextField(_emailController, 'Email'),
                  _buildTextField(_phoneController, 'Téléphone'),
                  _buildTextField(_dobController, 'Date de Naissance'),
                  _buildTextField(_passwordController, 'Mot de Passe',
                      obscureText: true),
                  _buildTextField(_confirmPasswordController,
                      'Confirmation du Mot de Passe',
                      obscureText: true),

                  SizedBox(height: 20),
                  // Conditions d'utilisation
                  Row(
                    children: [
                      Transform.scale(
                        scale: 0.8,
                        child: Checkbox(
                          value: _acceptTerms,
                          onChanged: (bool? value) {
                            setState(() {
                              _acceptTerms = value!;
                            });
                          },
                          activeColor: const Color(0xFF9381FF),
                          checkColor: Colors.white,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "J'accepte les conditions d'utilisation",
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'Nunito',
                            color: const Color(0xFF666666),
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                  // Bouton Inscription
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _acceptTerms //cliquable si les conditions d'utilisation sont acceptées
                        ? () {
                            Navigator.pushNamed(context, '/questionnaire');
                          }
                        : null,
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
                          'Inscription',
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'Nunito',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.85,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              color: Color(0xFF666666),
            ),
            textAlign: TextAlign.left,
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
              controller: controller,
              obscureText: obscureText,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                color: Color(0xFF666666),
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
