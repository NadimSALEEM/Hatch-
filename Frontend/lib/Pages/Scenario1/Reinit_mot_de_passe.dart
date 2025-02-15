import 'package:flutter/material.dart';

class ReinitMotDePasse extends StatelessWidget {
  const ReinitMotDePasse({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reinit mot de passe'),
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