import 'package:flutter/material.dart';

class CodeVerification extends StatelessWidget {
  const CodeVerification({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController codeController = TextEditingController();
    final String email = ModalRoute.of(context)!.settings.arguments as String;

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

            // Instructions
            Center(
              child: SizedBox(
                width: 300,
                child: Text(
                  'Un code de vérification a été envoyé à $email. Veuillez le saisir ci-dessous.',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    color: Color(0xFF666666),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Champ de saisie pour le code
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Code de vérification',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 16,
                        color: Color(0xFF666666),
                      ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFEDEDED)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: codeController,
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Bouton pour vérifier le code
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (codeController.text.isNotEmpty) {
                    Navigator.pushNamed(
                      context,
                      '/init_nouveau_mot_de_passe',
                      arguments: email,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Veuillez entrer un code valide')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.transparent,
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFB9ADFF), Color(0xFF9381FF)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 130),
                    child: const Text(
                      'Vérifier',
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
          ],
        ),
      ),
    );
  }
}