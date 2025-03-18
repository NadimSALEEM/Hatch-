import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'creer_objectif.dart';

class CreerHabitude extends StatefulWidget {
  const CreerHabitude({Key? key}) : super(key: key);

  @override
  _CreerHabitudeState createState() => _CreerHabitudeState();
}

class _CreerHabitudeState extends State<CreerHabitude> {
  final TextEditingController _habitsNameController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final TextEditingController _objectiveNameController = TextEditingController();
  final List<String> _tags = [];
  String? _selectedPriority = "moyenne";
  String? _selectedPeriod;
  String? _selectedObjectiveType;
  final List<Map<String, dynamic>> _objectifs = [];
  final Dio _dio = Dio();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  bool _isLoading = false;

  // Ajouter un tag à la liste
  void _addTag() {
    final String tag = _tagsController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
      });
      _tagsController.clear();
    }
  }

  // Retirer un tag de la liste
  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  // Changement de la priorité
  void _selectPriority(String priority) {
    setState(() {
      _selectedPriority = priority;
    });
  }


Future<void> _createHabit() async {
  setState(() => _isLoading = true);
  try {
    // Récupérer le token JWT
    String? token = await _secureStorage.read(key: "jwt_token");
    if (token == null || token.isEmpty) throw Exception("Token non trouvé");

    // Récupérer et valider le nom de l'habitude
    String habitName = _habitsNameController.text.trim();
    if (habitName.isEmpty) {
      throw Exception("Le nom de l'habitude ne peut pas être vide");
    }

    // Créer l'habitude
    Response responseHabitude = await _dio.post(
      "http://localhost:8080/habits/create",
      data: {
        "nom": habitName,
        "statut": 1,
        "freq": "quotidien",
        "prio": _selectedPriority,
        "desc": "",
        "labels": _tags,
      },
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );

    int? habitId;
    int? userId;

    // Vérifier si l'API renvoie directement l'ID et `user_id`
    if (responseHabitude.statusCode == 201 && responseHabitude.data != null) {
      if (responseHabitude.data.containsKey("id")) {
        habitId = responseHabitude.data["id"];
      }
      if (responseHabitude.data.containsKey("user_id")) {
        userId = responseHabitude.data["user_id"];
      }
      print("ID de l'habitude: $habitId, ID de l'utilisateur: $userId");
    }

    // Si `habit_id` est null, récupérer avec une requête GET
    if (habitId == null) {
      Response responseAllHabits = await _dio.get(
        "http://localhost:8080/habits",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (responseAllHabits.statusCode == 200 && responseAllHabits.data is List) {
        List habits = responseAllHabits.data;
        if (habits.isNotEmpty) {
          var lastHabit = habits.last;
          habitId = lastHabit["id"];
          print("ID récupéré depuis la liste des habitudes: $habitId");
        }
      }
    }

    // Vérifier si on a bien `habit_id` et `user_id` avant de continuer
    if (habitId == null || userId == null) {
      throw Exception("Impossible de récupérer les IDs nécessaires");
    }

    // Créer les objectifs associés (si la liste n'est pas vide)
    if (_objectifs.isNotEmpty) {
  for (var objectif in _objectifs) {
    try {
      print("Envoi objectif: ${objectif["nom"]}, habit_id=$habitId, user_id=$userId");
      print("Données envoyées: $objectif");

      Response responseObjectif = await _dio.post(
        "http://localhost:8080/habits/$habitId/objectifs/create",  // 🔥 Correction ici
        data: {
          "habit_id": habitId,  // Associer l'objectif à l'habitude
          "user_id": userId,  // Associer l'objectif à l'utilisateur
          "nom": objectif["nom"],  
          "statut": objectif["statut"] ?? 1,  // Statut actif (par défaut = 1)
          "compteur": objectif["compteur"] ?? 0,  // Valeur par défaut = 0
          "total": objectif["total"] ?? 100,  // Objectif final (modifiable)
          "unite_compteur": objectif["unite_compteur"] ?? "fois",  // Unité par défaut
          "modules": objectif["modules"] ?? {},  // Modules interactifs activés
          "rappel_heure": objectif["rappel_heure"],  // Peut être null
          "historique_progression": objectif["historique_progression"] ?? [],  // Historique vide par défaut
        },
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (responseObjectif.statusCode == 201) {
        print("Objectif '${objectif["nom"]}' créé avec succès !");
      } else {
        print("Échec de création de l'objectif: ${objectif["nom"]}");
      }
    } catch (e) {
      print("Erreur lors de l'ajout de l'objectif '${objectif["nom"]}': $e");
    }
  }
}






    // Afficher un message de succès
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Habitude '$habitName' créée avec succès !"),
        backgroundColor: Colors.green,
      ),
    );

    // Redirection après création
    Navigator.pushNamed(context, '/post_creation_habitude');
  } catch (e) {
    // Gestion des erreurs Dio
    if (e is DioError) {
      print("Erreur Dio: ${e.response?.statusCode}");
      print("Réponse API: ${e.response?.data}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur API: ${e.response?.data}"),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      print("Erreur inattendue: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  } finally {
    setState(() => _isLoading = false);
  }
}


  //Appel de la popup de création d'objectifs
  void _showCreateObjectiveDialog() {
    showCreateObjectiveDialog(
      context,
      _objectiveNameController,
      _selectedPeriod,
      _selectedObjectiveType,
      (String name, String period, String type, Map<String, bool> modules) {
        setState(() {
          // Ajouter l'objectif la liste
          _addObjective(name, period, type, modules);
        });

        // Réinitialisation des champs après la création
        _objectiveNameController.clear();
        _selectedPeriod = "7";
        _selectedObjectiveType = "Chaque jour";
      },
      _habitsNameController.text,
    );
  }

  //Ajout d'objectif à la liste
  void _addObjective(String name, String period, String type, Map<String, bool> modules) {
    setState(() {
      _objectifs.add({
        "nom": name,
        "periode": period,
        "type": type,
        "modules": modules,
        "compteur": 0,  // Progression initiale
        "total": 100,   // Objectif final par défaut (modifiable)
        "unite_compteur": "fois", // Unité par défaut
        "statut": 1,  // Actif par défaut
        "rappel_heure": null  // Pas de rappel par défaut
      });
    });
  }


  //Appel de la popup de modification d'objectifs
  void _showEditObjectiveDialog(Map<String, dynamic> objectif) {
    showEditObjectiveDialog(
      context,
      objectif,
      (updatedObjective) {
        setState(() {
          int index = _objectifs.indexOf(objectif);
          if (index != -1) {
            _objectifs[index] = updatedObjective;
          }
        });
      },
      () {
        setState(() {
          _objectifs.remove(objectif); // Supprime l'objectif de la liste
        });
      },
      _habitsNameController.text,
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Créer une habitude',
          style: TextStyle(
            fontSize: 20,
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHabitNameField(),
              const SizedBox(height: 30),
              _buildObjectivesSection(),
              const SizedBox(height: 40),
              _buildTagsField(),
              const SizedBox(height: 30),
              const Text(
                'Choisissez une priorité',
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'Nunito',
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildPrioritySection('Basse', Color(0xFFF8F7FF), 'Basse'),
                  const SizedBox(width: 16),
                  _buildPrioritySection(
                      'Moyenne', Color(0xFFFFEEDD), 'Moyenne'),
                  const SizedBox(width: 16),
                  _buildPrioritySection('Haute', Color(0xFFFFB4B4), 'Haute'),
                ],
              ),
              const SizedBox(height: 80),
              _buildCreateHabitButton(),
            ],
          ),
        ),
      ),
    );
  }

  // Champ de saisie pour le nom de l'habitude
  Widget _buildHabitNameField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nom de l\'habitude',
            style: TextStyle(
              fontSize: 15,
              fontFamily: 'Nunito',
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFEDEDED)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _habitsNameController,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                color: Color(0xFF666666),
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Section Objectifs
  Widget _buildObjectivesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Objectifs',
          style: TextStyle(
            fontSize: 15,
            fontFamily: 'Nunito',
            color: Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 12),
        //Bouton ajouter objectif
        Container(
          width: MediaQuery.of(context).size.width * 0.4,
          padding: const EdgeInsets.symmetric(horizontal: 12),
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
              _showCreateObjectiveDialog();
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              side: BorderSide(color: Colors.transparent),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                "+    Ajouter un objectif",
                style: TextStyle(
                  fontFamily: 'NunitoBold',
                  fontSize: 14,
                  color: Color(0xFFFBFBFB),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Affichage de la liste des objectifs
        _objectifs.isEmpty
            ? const Text(
                "Aucun objectif ajouté",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              )
            : Column(
                children: _objectifs.map((objectif) {
                  int currentDay = 1;
                  int totalDays = int.parse(objectif["periode"] ??
                      "7"); // Période en jours, 7 par défaut
                  double progress = currentDay / totalDays;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    color: Color(0xFFE3FFE5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nom de l'objectif
                          Text(
                            objectif["nom"]!,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(height: 3),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: Colors.grey.shade300,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          Color(0xFFB9ADFF)),
                                  minHeight: 6,
                                ),
                              ),
                              IconButton(
                                icon: Image.asset(
                                  'assets/images/Habitude/changeObjective.png',
                                  width: 38,
                                  height: 38,
                                ),
                                onPressed: () {
                                  _showEditObjectiveDialog(objectif);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),

                          // Affichage de la période et du type d'objectif
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "$currentDay/${objectif["periode"]} jours",
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 12,
                                  color: Color(0xFFB8B8FF),
                                ),
                              ),
                              Text(
                                objectif["type"]!,
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 12,
                                  color: Color(0xFFB8B8FF),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
      ],
    );
  }

  // Champ de saisie pour les Tags
  Widget _buildTagsField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tags',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Nunito',
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFEDEDED)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _tagsController,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Color(0xFF9381FF)),
                onPressed: () {
                  _addTag();
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8.0, //Possibilité d'ajouter des tags ou de les supprimer
            runSpacing: 4.0,
            children: _tags
                .map((tag) => Chip(
                      label: Text(tag),
                      deleteIcon: const Icon(Icons.close),
                      onDeleted: () => _removeTag(tag),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  // Choix de la priorité
  Widget _buildPrioritySection(String label, Color color, String priority) {
    return ElevatedButton(
      onPressed: () => _selectPriority(priority),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.black,
        side: BorderSide(
          color: _selectedPriority == priority
              ? const Color(0xFFB3A8FF)
              : Colors.transparent,
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 14,
          color: _selectedPriority == priority
              ? Colors.black
              : const Color(0xFF666666),
        ),
      ),
    );
  }

 Widget _buildCreateHabitButton() {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFB9ADFF), Color(0xFF9381FF)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextButton(
          onPressed: _isLoading ? null : _createHabit,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            side: BorderSide(color: Colors.transparent),
          ),
          child: const Text(
            "Créer l'habitude",
            style: TextStyle(
              fontFamily: 'NunitoBold',
              fontSize: 14,
              color: Color(0xFFFBFBFB),
            ),
          ),
        ),
      ),
    );
  }
}
