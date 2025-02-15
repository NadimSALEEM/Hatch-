import 'package:flutter/material.dart';

class Questionnaire extends StatelessWidget {
  const Questionnaire({Key? key}) : super(key: key);

  // Fonction pour afficher le pop-up
  void _showCompletionPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Questionnaire Terminé'),
          content: const Text('Merci d\'avoir complété le questionnaire !'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme le pop-up
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Questionnaire'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/'); // Aller à Bienvenue1
              },
              child: const Text('Go to Bienvenue1'),
            ),
            const SizedBox(height: 20), // Espacement entre les boutons
            ElevatedButton(
              onPressed: () {
                _showCompletionPopup(context); // Afficher le pop-up
              },
              child: const Text('Terminer le Questionnaire'),
            ),
          ],
        ),
      ),
    );
  }
}