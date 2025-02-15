import 'package:flutter/material.dart';

class SeConnecter extends StatelessWidget {
  const SeConnecter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Se connecter'),
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