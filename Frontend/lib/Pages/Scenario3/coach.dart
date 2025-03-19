import 'package:flutter/material.dart';

class Coach extends StatefulWidget {
  const Coach({Key? key}) : super(key: key);

  @override
  _CoachState createState() => _CoachState();
}

class _CoachState extends State<Coach> {
  final PageController _pageController = PageController();
  int currentIndex = 0;

  final List<Map<String, dynamic>> recommendations = [
    {
      'habitName': 'Alimentation',
      'tags': ['Nutrition', 'Bien-être'],
    },
    {
      'habitName': 'Activité physique',
      'tags': ['Sport', 'Bien-être'],
    },
    {
      'habitName': 'Sommeil',
      'tags': ['Sommeil'],
    },
  ];

  void _goToPrevious() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
      _pageController.animateToPage(
        currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNext() {
    if (currentIndex < recommendations.length - 1) {
      setState(() {
        currentIndex++;
      });
      _pageController.animateToPage(
        currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            //en-tête
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 24),
                  const Text(
                    'Coach',
                    style: TextStyle(
                      fontFamily: 'NunitoBold',
                      fontSize: 22,
                      color: Color(0xFF2F2F2F),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/choix_coach');
                    },
                    child: Image.asset(
                      'assets/images/coach/fleches.png',
                      width: 30,
                      height: 30,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              height: 1,
              color: Color.fromARGB(255, 51, 47, 47),
            ),

            const SizedBox(height: 10),

            //représentation coach
            Center(
              child: Image.asset(
                'assets/images/coach/Coach.png',
                width: double.infinity, // Prend toute la largeur possible
                height: 280,
                fit: BoxFit
                    .fitWidth, // Couvre toute la zone, peut couper un peu l'image
              ),
            ),

            const SizedBox(height: 32),

            // Section "Recommandations"
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12), // Réduit la largeur
              child: Align(
                alignment: Alignment.centerLeft, // Assure l'alignement à gauche
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Alignement du texte à gauche
                  children: [
                    const Text(
                      'Recommandations',
                      style: TextStyle(
                        fontFamily: 'NunitoBold',
                        fontSize: 21,
                        color: Color(0xFF2F2F2F),
                      ),
                    ),
                    const SizedBox(
                        height: 10), // Réduit l'espacement sous le titre
                  ],
                ),
              ),
            ),

// Carrousel avec flèches de navigation
            Expanded(
              child: Column(
                children: [
                  SizedBox(
                    height: 180, // Réduit la hauteur du carrousel
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          itemCount: recommendations.length,
                          onPageChanged: (index) {
                            setState(() {
                              currentIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return _buildRecommendationCard(
                              recommendations[index]['habitName'],
                              recommendations[index]['tags'],
                            );
                          },
                        ),
                        Positioned(
                          left: 10,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios),
                            onPressed: _goToPrevious,
                          ),
                        ),
                        Positioned(
                          right: 10,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_forward_ios),
                            onPressed: _goToNext,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],


                
              ),
            ),
          ],
        ),
      ),
    );
  }


  // Widget pour afficher une carte de recommandation
 Widget _buildRecommendationCard(String habitName, List<String> tags) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFE7E3FF),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,  // Changer ici pour aligner les éléments en haut
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          habitName,
          style: const TextStyle(
            fontFamily: 'NunitoBold',
            fontSize: 20, // Taille du texte ajustée
            color: Color(0xFF666666), // Couleur du texte ajustée
          ),
        ),
        const SizedBox(height: 8),
        Text(
          tags.join(', '), // Joindre les tags en une seule chaîne de caractères
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14,
            color: Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 35),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Bouton pour accepter la suggestion
            GestureDetector(
              onTap: () {
                // Action pour valider la suggestion
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 180, 167, 252), // Fond de validation
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check, // V pour valider
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Bouton pour refuser la suggestion
            GestureDetector(
              onTap: () {
                // Action pour refuser la suggestion
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 244, 183, 122), // Fond de refus
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close, // X pour refuser
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
}