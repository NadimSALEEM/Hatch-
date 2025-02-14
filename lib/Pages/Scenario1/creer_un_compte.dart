import 'package:flutter/material.dart';

class CreerUnCompte extends StatelessWidget {
  const CreerUnCompte({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Créer un compte'),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text("Go to Bienvenue1"),
          onPressed: () {
            Navigator.pushNamed(context, '/');
          },
        ),
      ),
    );
  }
}