import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decode/jwt_decode.dart'; // ← à ajouter dans pubspec.yaml

class Coach extends StatefulWidget {
  const Coach({Key? key}) : super(key: key);

  @override
  _CoachState createState() => _CoachState();
}

class _CoachState extends State<Coach> {
  final PageController _pageController = PageController();
  final PageController _objectivesPageController = PageController();
  int currentObjectiveIndex = 0;
  int currentIndex = 1;
  int _selectedIndex = 1;

  //Liste pré-scriptée de recommandations habitudes
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

  //Liste pré-scriptée de recommandations objectifs
  List<Map<String, dynamic>> objectiveRecommendations = [
    {
      'objectiveName': 'Aller à la salle de sport',
      'relatedHabit': 'Faire du sport régulièrement',
      'description':
          'Se rendre régulièrement à la salle de sport pour pratiquer des exercices physiques et maintenir une bonne condition physique.',
      'tags': ['Fitness', 'Bien-être'],
      'habitId': 1,
    },
  ];

//Fonctions pour naviguer dans les carousels

  void _goToPrevious(
      PageController controller, int currentIndex, Function updateIndex) {
    if (currentIndex > 0) {
      updateIndex(currentIndex - 1);
      controller.animateToPage(
        currentIndex - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNext(PageController controller, int currentIndex, int itemCount,
      Function updateIndex) {
    if (currentIndex < itemCount - 1) {
      updateIndex(currentIndex + 1);
      controller.animateToPage(
        currentIndex + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _buildBottomNavigationBar(), // Barre de navigation
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          children: [
            // En-tête
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

            // Image du coach
            Center(
              child: Image.asset(
                'assets/images/coach/Coach.png',
                width: double.infinity,
                height: 280,
                fit: BoxFit.fitWidth,
              ),
            ),

            const SizedBox(height: 32),

            // Section "Recommandations"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recommandations',
                      style: TextStyle(
                        fontFamily: 'NunitoBold',
                        fontSize: 21,
                        color: Color(0xFF2F2F2F),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),

            // Carrousel avec flèches de navigation
            SizedBox(
              height: 180,
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
                      onPressed: () => _goToPrevious(
                          _pageController, currentIndex, (newIndex) {
                        setState(() {
                          currentIndex = newIndex;
                        });
                      }),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_forward_ios),
                      onPressed: () => _goToNext(
                          _pageController, currentIndex, recommendations.length,
                          (newIndex) {
                        setState(() {
                          currentIndex = newIndex;
                        });
                      }),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            // Carrousel des recommandations d’objectifs
            SizedBox(
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PageView.builder(
                    controller: _objectivesPageController,
                    itemCount: objectiveRecommendations.length,
                    onPageChanged: (index) {
                      setState(() {
                        currentObjectiveIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return _buildObjectiveCard(
                        objectiveRecommendations[index]['objectiveName'],
                        objectiveRecommendations[index]['relatedHabit'],
                        objectiveRecommendations[index]['description'],
                        objectiveRecommendations[index]['tags'],
                      );
                    },
                  ),
                  Positioned(
                    left: 10,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: () => _goToPrevious(
                          _objectivesPageController, currentObjectiveIndex,
                          (newIndex) {
                        setState(() {
                          currentObjectiveIndex = newIndex;
                        });
                      }),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_forward_ios),
                      onPressed: () => _goToNext(
                          _objectivesPageController,
                          currentObjectiveIndex,
                          objectiveRecommendations.length, (newIndex) {
                        setState(() {
                          currentObjectiveIndex = newIndex;
                        });
                      }),
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

  // Barre de navigation
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        if (_selectedIndex == index) return;

        setState(() {
          _selectedIndex = index;
        });

        if (index == 0) {
          Navigator.pushReplacementNamed(context, '/accueil');
        } else if (index == 1) {
          Navigator.pushReplacementNamed(context, '/coach');
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFFAB96FF),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), label: 'Coach'),
        BottomNavigationBarItem(icon: Icon(Icons.storefront), label: 'Magasin'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Social'),
        BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline), label: 'Messages'),
      ],
    );
  }

  // Widget pour afficher une carte de recommandation
  Widget _buildRecommendationCard(String habitName, List<String> tags) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE7E3FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            habitName,
            style: const TextStyle(
              fontFamily: 'NunitoBold',
              fontSize: 20,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 8),

          //tags
          Wrap(
            spacing: 8,
            children: tags.map((tag) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF9381FF), width: 1),
                  color: const Color(0xFFFFFFFF),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    color: Color(0xFF666666),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 35),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Bouton Accepter
              GestureDetector(
                onTap: () {
                  _showConfirmationDialog(habitName, tags);
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFB4A7FC),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 16),
              // Bouton Refuser
              GestureDetector(
                onTap: () {
                  // Action pour refuser
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF4B77A),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildObjectiveCard(String objectiveName, String relatedHabit,
      String description, List<String> tags) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3FFE5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              objectiveName,
              style: const TextStyle(
                fontFamily: 'NunitoBold',
                fontSize: 20,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Habitude concernée: $relatedHabit',
              style: const TextStyle(
                fontFamily: 'NunitoBold',
                fontSize: 10,
                color: Color(0xFF9381FF),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: tags.map((tag) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: const Color(0xFF9381FF), width: 1),
                    color: const Color(0xFFFFFFFF),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      color: Color(0xFF666666),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    _showObjectiveConfirmationDialog(
                        objectiveName, relatedHabit, description, tags);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB9ADFF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () {
                    // Action pour refuser l'objectif
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4B77A),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

//Popup de confirmation

  void _showConfirmationDialog(String habitName, List<String> tags) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF9381FF), width: 2),
          ),
          backgroundColor: const Color(0xFFFCFCFF),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/coach_popup.png',
                  width: 70,
                  height: 70,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 2),
                const Text(
                  "Acceptez-vous cette suggestion ?",
                  style: TextStyle(
                    fontFamily: 'NunitoBold',
                    fontSize: 18,
                    color: Color(0xFF2F2F2F),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7E3FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habitName,
                        style: const TextStyle(
                          fontFamily: 'NunitoBold',
                          fontSize: 20,
                          color: Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tags.join(', '),
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // ✅ Appel de addHabit ici
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      final habitData = {
                        'name': habitName,
                        'tags': tags,
                      };
                      addHabit(habitData, context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: const Color(0xFF9381FF),
                    ),
                    child: const Text(
                      "Accepter",
                      style: TextStyle(
                        fontFamily: 'NunitoBold',
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Annuler",
                    style: TextStyle(
                      fontFamily: 'NunitoBold',
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showObjectiveConfirmationDialog(String objectiveName,
      String relatedHabit, String description, List<String> tags) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF9381FF), width: 2),
          ),
          backgroundColor: const Color(0xFFFCFCFF),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icône
                Image.asset(
                  'assets/images/coach_popup.png',
                  width: 70,
                  height: 70,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 2),

                const Text(
                  "Acceptez-vous cet objectif ?",
                  style: TextStyle(
                    fontFamily: 'NunitoBold',
                    fontSize: 18,
                    color: Color(0xFF2F2F2F),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3FFE5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        objectiveName,
                        style: const TextStyle(
                          fontFamily: 'NunitoBold',
                          fontSize: 20,
                          color: Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Habitude concernée: $relatedHabit',
                        style: const TextStyle(
                          fontFamily: 'NunitoBold',
                          fontSize: 10,
                          color: Color(0xFF9381FF),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        children: tags.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: const Color(0xFF9381FF), width: 1),
                              color: const Color(0xFFFFFFFF),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 12,
                                color: Color(0xFF666666),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                //Bouton Accepter
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      final objectiveData =
                          objectiveRecommendations[currentObjectiveIndex];
                      addObjective(objectiveData, context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: const Color(0xFF9381FF),
                    ),
                    child: const Text(
                      "Accepter",
                      style: TextStyle(
                        fontFamily: 'NunitoBold',
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Bouton Annuler
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Annuler",
                    style: TextStyle(
                      fontFamily: 'NunitoBold',
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> addHabit(
      Map<String, dynamic> habitData, BuildContext context) async {
    final storage = FlutterSecureStorage();
    String? token = await storage.read(key: "jwt_token");

    if (token == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Utilisateur non authentifié")),
        );
      }
      return;
    }

    final Dio dio = Dio();

    try {
      final response = await dio.post(
        "http://localhost:8080/habits/create", // 🔁 Remplace par ton IP locale
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
        data: {
          "nom": habitData["name"],
          "statut": 1,
          "labels": habitData["tags"],
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Coach mis à jour avec succès");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Habitude assignée avec succès!")),
        );
      } else {
        print("Erreur lors de la mise à jour : ${response.data}");
      }
    } catch (e) {
      print("Erreur Dio : $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur réseau ou serveur.")),
        );
      }
    }
  }

  Future<void> addObjective(
      Map<String, dynamic> objectiveData, BuildContext context) async {
    final storage = FlutterSecureStorage();
    String? token = await storage.read(key: "jwt_token");

    if (token == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Utilisateur non authentifié")),
        );
      }
      return;
    }

    final int habitId = objectiveData["habitId"];
    final Dio dio = Dio();

    try {
      final url = "http://localhost:8080/habits/$habitId/objectifs/create";

      final response = await dio.post(url,
          options: Options(
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
          ),
          data: {
            "nom": objectiveData['objectiveName'],
            "statut": 0,
            "compteur": 0,
            "total": 10,
            "unite_compteur": "fois",
            "modules": {
              "compteur": true,
              "checkbox": false,
              "chrono": false,
              "rappel": false
            },
            "rappel_heure": null,
            "historique_progression": [
              {"date": "2024-03-23", "valeur": 0}
            ]
          });

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Objectif ajouté avec succès");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Objectif ajouté avec succès !")),
          );
        }
      } else {
        print("⚠️ Erreur lors de l'ajout : ${response.data}");
      }
    } catch (e) {
      print("❌ Erreur Dio : $e");
      if (e is DioException && e.response != null) {
        print("🪵 Réponse backend : ${e.response!.data}");
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur réseau ou serveur.")),
        );
      }
    }
  }
}
