import 'package:flutter/material.dart';
import 'package:hatch/Pages/Scenario1/init_nouveau_mot_de_passe.dart';

class Profil extends StatelessWidget {
  const Profil({Key? key}) : super(key: key);

  void _showDeleteAccountPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFB9ADFF)),
          ),
          contentPadding: const EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/corbeille_suppression.png',
                width: 75,
                height: 75,
              ),
              const SizedBox(height: 5),
              const Text(
                'Voulez-vous vraiment supprimer votre compte ?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'NunitoBold',
                  color: Color(0xFF2F2F2F),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Cette action est irréversible et votre progression sera perdue pour toujours.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'Nunito',
                  color: Color(0xFF838383),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFB9ADFF), Color(0xFF9381FF)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    alignment: Alignment.center,
                    child: const Text(
                      'Annuler',
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'Nunito',
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Supprimer mon compte',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'NunitoBold',
                    color: Color(0xFFFF3B30),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2F2F2F)),
          onPressed: () => Navigator.pushReplacementNamed(context, '/accueil'),
        ),
        title: const Text(
          'Profil',
          style: TextStyle(
            fontSize: 17,
            fontFamily: 'NunitoBold',
            color: Color(0xFF2F2F2F),
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            color: Color(0xFFE0E0E0),
            thickness: 1,
            height: 1,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InitNouveauMotDePasse(),
                  ),
                );
              },
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFB9ADFF), Color(0xFF9381FF)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                  child: const Text(
                    'Changer mon mot de passe',
                    style: TextStyle(
                      fontSize: 15,
                      fontFamily: 'Nunito',
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () {
                _showDeleteAccountPopup(context);
              },
              child: const Text(
                'Supprimer mon compte',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'NunitoBold',
                  color: Color(0xFFB9ADFF),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
