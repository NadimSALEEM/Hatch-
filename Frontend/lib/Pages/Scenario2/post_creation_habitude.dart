import 'package:flutter/material.dart';

class PostCreationHabitude extends StatelessWidget {
  const PostCreationHabitude({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/Habitude/habitCreated.png', width: 250, height: 250),
              const SizedBox(height: 20),

              const Text(
                'Bravo !',
                style: TextStyle(
                  fontSize: 36,
                  fontFamily: 'NunitoBold',
                  color: Color(0xFF2F2F2F),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              const Text(
                "Une nouvelle habitude a été ajoutée.\n"
                "Faisons de notre mieux pour atteindre votre objectif !",
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Nunito',
                  color: Color(0xFF666666),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),

              // Bouton OK
              Container(
                width: MediaQuery.of(context).size.width * 0.6,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFB9ADFF), Color(0xFF9381FF)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/accueil');
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "OK",
                    style: TextStyle(
                      fontFamily: 'NunitoBold',
                      fontSize: 16,
                      color: Color(0xFFFBFBFB),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
