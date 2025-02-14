import 'package:flutter/material.dart';

class CreerObjectif extends StatelessWidget {
  const CreerObjectif({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un objectif'),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text("Go to Bienvenue1"),
          onPressed: () {
            Navigator.pushNamed(context, '/');
          },
        ),
      ),
    );
  }
}