import 'package:flutter/material.dart';

class InitNouveauMotDePasse extends StatelessWidget {
  const InitNouveauMotDePasse({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Init nouveau mot de passe'),
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