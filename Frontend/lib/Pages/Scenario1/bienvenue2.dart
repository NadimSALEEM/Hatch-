import 'package:flutter/material.dart';

class Bienvenue2 extends StatelessWidget {
  const Bienvenue2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Première moitié haute de l'écran
          Container(
            height: MediaQuery.of(context).size.height / 2,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFB9ADFF), Color(0xFF9381FF)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Center(
              child: Image.asset(
                'images/dragons_welcome.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Boîte blanche qui occupe la moitié basse de l'écran
          Container(
            height: MediaQuery.of(context).size.height / 2,
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Bienvenue sur Hatch!',
                    style: TextStyle(
                      fontSize: 25,
                      fontFamily: 'BricolageGrotesqueBold',
                      color: Color(0xFF9381FF),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('Votre Suivi Personnel d\'Habitudes !',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'BricolageGrotesqueMedium',
                        color: Color.fromARGB(180, 0, 0, 0),
                      ),
                      textAlign: TextAlign.center),
                  SizedBox(height: 30),
                   Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0), // Marge égale de chaque côté
          child: Text(
                    'Prenez le contrôle de vos habitudes et transformez votre vie avec Hatch!',
                    style: TextStyle(
                      fontSize: 15,
                      fontFamily: 'BricolageGrotesqueBold',
                      color: const Color.fromARGB(180, 0, 0, 0),
                    ),
                    textAlign: TextAlign.center,
                  ),
                   ),
                  SizedBox(height: 10),
                  Text(
                    'Commençons ensemble votre voyage vers le succès !',
                    style: TextStyle(
                      fontSize: 15,
                      fontFamily: 'BricolageGrotesqueBold',
                      color: const Color.fromARGB(180, 0, 0, 0),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/se_connecter');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero, 
                      backgroundColor: Colors.transparent,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFB9ADFF),
                            Color(0xFF9381FF)
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
                          'Allons-y ensemble!',
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily:
                                'Nunito',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
