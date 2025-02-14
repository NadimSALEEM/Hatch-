import 'package:flutter/material.dart';

class Bienvenue2 extends StatelessWidget {
  const Bienvenue2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenue2'),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text("Retour à Bienvenue1"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}