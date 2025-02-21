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
      initialRoute: '/', // Définir l'écran de démarrage test
      routes: {
        '/': (context) =>  Bienvenue1(),
        '/Bienvenue2': (context) =>  Bienvenue2(),
        '/accueil': (context) =>  Accueil(),
        '/creer_un_compte': (context) =>  CreerUnCompte(),
        '/se_connecter': (context) =>  SeConnecter(),
        '/reinit_mot_de_passe': (context) =>  ReinitMotDePasse(),
        '/parametres_compte': (context) =>  ParametresCompte(),
        '/profil': (context) =>  Profil(),
        '/questionnaire': (context) =>  Questionnaire(),
        '/init_nouveau_mot_de_passe': (context) =>
            const InitNouveauMotDePasse(),
        '/creer_objectif': (context) =>  CreerObjectif(),
        '/creer_une_habitude': (context) =>  CreerHabitude(),
        '/habitude': (context) =>  Habitude(),
        '/parametres_habitude': (context) =>  ParametresHabitude(),
        '/post_creation_habitude': (context) =>  PostCreationHabitude(),
        '/progres_habitude': (context) =>  ProgresHabitude(),
        '/toutes_les_habitudes': (context) =>  ToutesLesHabitudes(),
        '/choix_coach': (context) =>  ChoixCoach(),
        '/coach': (context) =>  Coach(),
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
