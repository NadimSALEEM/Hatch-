import 'package:flutter/material.dart';

class Bienvenue1 extends StatelessWidget {
  const Bienvenue1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          //Redirection vers l'écran suivant lorsqu'on clique sur l'écran
          Navigator.pushNamed(context, '/Bienvenue2');
        },
        child: Container(
          //Fond dégradé
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFB9ADFF), Color(0xFF9381FF)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Center(
            child: Image.asset( //Affichage du logo
              'images/white_logo.png',
              width: 150,
              height: 150,
            ),
          ),
        ),
      ),
    );
  }
}
