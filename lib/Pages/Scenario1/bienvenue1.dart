import 'package:flutter/material.dart';

class Bienvenue1 extends StatelessWidget {
  const Bienvenue1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Liste des routes et leurs libellés correspondants
    final Map<String, String> routes = {
      '/Bienvenue2': 'Aller à Bienvenue2',
      '/accueil': 'Aller à Accueil',
      '/creer_un_compte': 'Aller à Créer un compte',
      '/se_connecter': 'Aller à Se connecter',
      '/reinit_mot_de_passe': 'Aller à Réinitialiser le mot de passe',
      '/parametres_compte': 'Aller à Paramètres du compte',
      '/profil': 'Aller à Profil',
      '/questionnaire': 'Aller à Questionnaire',
      '/init_nouveau_mot_de_passe': 'Aller à Initier un nouveau mot de passe',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bienvenue1'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: routes.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  // Navigation vers la page correspondante en fonction de la clé de la route
                  Navigator.pushNamed(context, entry.key);
                },
                child: Text(entry.value),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
