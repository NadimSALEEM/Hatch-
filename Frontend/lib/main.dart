import 'package:flutter/material.dart';
import 'package:hatch/Pages/app_routes.dart';
import 'package:hatch/Services/auth_guard.dart';


void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // Définir l'écran de démarrage
      routes: {
        '/': (context) => Bienvenue1(), // Routes publiques
        '/Bienvenue2': (context) => Bienvenue2(),
        '/creer_un_compte': (context) => CreerUnCompte(),
        '/se_connecter': (context) => SeConnecter(),
        '/reinit_mot_de_passe': (context) => ReinitMotDePasse(),
        '/init_nouveau_mot_de_passe': (context) => InitNouveauMotDePasse(),
        '/code_verification': (context) => CodeVerification(),

        '/accueil': (context) => AuthGuard(page: Accueil()),  // Pages protégées
        '/parametres_compte': (context) => AuthGuard(page: ParametresCompte()),
        '/profil': (context) => AuthGuard(page: Profil()),
        '/questionnaire': (context) => AuthGuard(page: Questionnaire()),
        '/creer_objectif': (context) => AuthGuard(page: CreerObjectif()),
        '/creer_une_habitude': (context) => AuthGuard(page: CreerHabitude()),
        '/habitude': (context) => AuthGuard(page: Habitude()),
        '/parametres_habitude': (context) => AuthGuard(page: ParametresHabitude()),
        '/post_creation_habitude': (context) => AuthGuard(page: PostCreationHabitude()),
        '/progres_habitude': (context) => AuthGuard(page: ProgresHabitude()),
        '/toutes_les_habitudes': (context) => AuthGuard(page: ToutesLesHabitudes()),
        '/choix_coach': (context) => AuthGuard(page: ChoixCoach()),
        '/coach': (context) => AuthGuard(page: Coach()),
      },
      onUnknownRoute: (settings) { // Gestion des erreurs 404
        return MaterialPageRoute(builder: (context) => const NotFoundPage());
      },
    );
  }
}

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Erreur 404")),
      body: const Center(
        child: Text(
          "Page non trouvée !",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
