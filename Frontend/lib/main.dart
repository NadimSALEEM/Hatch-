import 'package:flutter/material.dart';
import 'package:hatch/Pages/app_routes.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',  // Définir l'écran de démarrage
      routes: {
        '/': (context) => const Bienvenue1(),
        '/Bienvenue2': (context) => const Bienvenue2(),
        '/accueil': (context) => const Accueil(),
        '/creer_un_compte': (context) => const CreerUnCompte(),
        '/se_connecter': (context) => const SeConnecter(),
        '/reinit_mot_de_passe': (context) => const ReinitMotDePasse(),
        '/parametres_compte': (context) => const ParametresCompte(),
        '/profil': (context) => const Profil(),
        '/questionnaire': (context) => const Questionnaire(),
        '/init_nouveau_mot_de_passe': (context) => const InitNouveauMotDePasse(),
        '/creer_objectif': (context) => const CreerObjectif(),
        '/creer_une_habitude': (context) => const CreerHabitude(),
        '/habitude': (context) => const Habitude(),
        '/parametres_habitude': (context) => const ParametresHabitude(),
        '/post_creation_habitude': (context) => const PostCreationHabitude(),
        '/progres_habitude': (context) => const ProgresHabitude(),
        '/toutes_les_habitudes': (context) => const ToutesLesHabitudes(),
        '/choix_coach': (context) => const ChoixCoach(),
        '/coach': (context) => const Coach(),
      },
      onUnknownRoute: (settings) {
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
