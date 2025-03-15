import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:convert';

class Habitude extends StatefulWidget {
  final int habitId;

  const Habitude({Key? key, required this.habitId}) : super(key: key);

  @override
  _HabitudeState createState() => _HabitudeState();
}

class _HabitudeState extends State<Habitude> {
  final Dio _dio = Dio();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  Map<String, dynamic>? habitDetails;
  
  int _selectedIndex = 0;

  final List<String> dragonNames = [
  "Midgardsormr", "Fafnir", "Bahamut", "Dracolich", "Alduin", "Smaug", "Tiamat", "Shenron"
  ];

  late String dragonName;
  List<dynamic> _objectifs = [];

  @override
  void initState() {
    super.initState();
    dragonName = (dragonNames..shuffle()).first;
    fetchHabitDetails();
    fetchObjectives();
  }

  Future<void> fetchHabitDetails() async {
    try {
      String? token = await _secureStorage.read(key: "jwt_token");
      if (token == null) return;

      final response = await _dio.get(
        "http://localhost:8080/habits/${widget.habitId}",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        setState(() {
          habitDetails = response.data;
        });
      }
    } catch (e) {
      print("Erreur lors du chargement de l’habitude : $e");
    }
  }  


Future<void> fetchObjectives() async {
  try {
    String? token = await _secureStorage.read(key: "jwt_token");
    if (token == null) {
      print("Erreur : Token JWT non trouvé.");
      return;
    }

    final response = await _dio.get(
      "http://localhost:8080/habits/${widget.habitId}/objectifs",
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );

    if (response.statusCode == 200) {
      setState(() {
        _objectifs = response.data;
      });
    } else {
      print("Erreur HTTP ${response.statusCode} : ${response.data}");
    }
  } catch (e) {
    print("Erreur lors du chargement des objectifs : $e");
  }
}

Future<void> _addObjectiveToAPI(Map<String, dynamic> objectif) async {
  try {
    String? token = await _secureStorage.read(key: "jwt_token");
    if (token == null) {
      print("Erreur : Token JWT non trouvé.");
      return;
    }

    if (habitDetails == null || habitDetails?["user_id"] == null) {
      print("Erreur : Détails de l'habitude non trouvés.");
      return;
    }

    int habitId = widget.habitId;
    int userId = habitDetails!["user_id"];

    final response = await _dio.post(
      "http://localhost:8080/habits/$habitId/objectifs/create",
      data: {
        "habit_id": habitId,
        "user_id": userId,
        "nom": objectif["nom"],
        "statut": 1,
        "compteur": 0,
        "total": 100,
        "unite_compteur": "fois",
        "modules": objectif["modules"],
        "rappel_heure": null,
        "historique_progression": [],
      },
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );

    if (response.statusCode == 201) {
      print("Objectif ajouté avec succès : ${response.data}");
      fetchObjectives(); // Met à jour la liste des objectifs
    } else {
      print("Erreur HTTP ${response.statusCode} : ${response.data}");
    }
  } catch (e) {
    print("Erreur lors de l'ajout de l'objectif : $e");
  }
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFfcfcff),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHabitCard(),
            const SizedBox(height: 20),
            _buildNotesSection(),
            const SizedBox(height: 20),
            _buildProgressSection(),
            const SizedBox(height: 20),
            _buildObjectivesSection(),
            const SizedBox(height: 20),
            _buildResourcesSection(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF2F2F2F)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        habitDetails?["nom"] ?? "Chargement...",
        style: TextStyle(fontSize: 18, fontFamily: 'NunitoBold', color: Color(0xFFAB96FF)),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings, color: Color(0xFF2F2F2F)),
          onPressed: () {},
        ),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(color: Color(0xFFE0E0E0), thickness: 1, height: 1),
      ),
    );
  }

Widget _buildHabitCard() {
  // Choisir un nom de dragon aléatoire
  String dragon = dragonName;

  return Stack(
    children: [
      SizedBox(
        width: double.infinity, // Force la largeur max
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          color: Color(0xFFE0E4C7),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Image du dragon
                Image.asset(
                  'images/Habitude/dragon1.png', // (Peut être remplacé par une image dynamique)
                  height: 120,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 10),

                // Informations du dragon
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      dragon, // Nom aléatoire du dragon
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'NunitoBold',
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Jeune dragon',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'NunitoSemiBold',
                        color: Colors.orange,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Tags en bas
                if (habitDetails?["labels"] != null)
                  Wrap(
                    spacing: 6,
                    children: (habitDetails!["labels"] as List<dynamic>).map((labels) {
                      return _buildTag(labels);
                    }).toList(),
                  ),
              ],
            ),
          ),
        ),
      ),

      // Tag de priorité en haut à droite
      if (habitDetails?["prio"] != null)
        Positioned(
          top: 10,
          right: 10,
          child: _buildPriorityTag(habitDetails!["prio"]),
        ),
    ],
  );
}


  Widget _buildTag(String labels) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFFAB96FF), width: 1),
      ),
      child: Text(
        labels,
        style: TextStyle(
          fontSize: 12,
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w500,
          color: Color(0xFFAB96FF),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }


  Widget _buildPriorityTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: label == "haute" ? Colors.red.shade100 
              : label == "moyenne" ? Colors.orange.shade100 
              : Colors.green.shade100,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: label == "haute" ? Colors.red : 
                label == "moyenne" ? Colors.orange : Colors.green,
          width: 1,
        ),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontFamily: 'Nunito',
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }


Widget _buildNotesSection() {
  final TextEditingController _noteController =
      TextEditingController(text: habitDetails?["desc"] ?? "");
  Timer? _debounce;

  void saveNoteAutomatically(String note) async {
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 1), () async {
      try {
        String? token = await _secureStorage.read(key: "jwt_token");
        if (token == null) {
          print("Erreur : Token non trouvé.");
          return;
        }

        if (habitDetails == null || habitDetails!["id"] == null) {
          print("Erreur : habitDetails ou ID de l'habitude non défini.");
          return;
        }

        final int habitId = habitDetails!["id"];
        final Map<String, dynamic> data = {
          "id": habitId,
          "desc": note,  // Peut être "" si l'utilisateur efface tout
        };

        print("Envoi de la requête PUT à : http://localhost:8080/habits/$habitId/edit");
        print("Données envoyées : ${jsonEncode(data)}");

        final response = await _dio.put(
          "http://localhost:8080/habits/$habitId/edit",
          data: jsonEncode(data),
          options: Options(headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          }),
        );

        if (response.statusCode == 200) {
          setState(() {
            habitDetails!["desc"] = note;
            habitDetails!["maj_le"] = DateTime.now().toIso8601String();
          });

          print("Sauvegarde réussie : ${response.data}");
        } else {
          print("Erreur HTTP ${response.statusCode} : ${response.data}");
        }
      } catch (e) {
        if (e is DioException) {
          print("DioException : ${e.message}");
          print("Response data : ${e.response?.data}");
        } else {
          print("Erreur inconnue : $e");
        }
      }
    });
  }


  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    elevation: 4,
    shadowColor: Colors.grey.shade300,
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notes',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'NunitoBold',
              color: Color(0xFF2F2F2F),
            ),
          ),
          SizedBox(height: 4),
          TextField(
            controller: _noteController,
            maxLines: null,
            decoration: InputDecoration(
              hintText: "Ajoutez une description...",
              border: InputBorder.none,
            ),
            onChanged: saveNoteAutomatically,
          ),
          if (habitDetails?["maj_le"] != null) ...[
            SizedBox(height: 8),
            Text(
              "Dernière modification : ${DateFormat('dd MMM yyyy à HH:mm').format(DateTime.parse(habitDetails!["maj_le"]))}",
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'Nunito',
                color: Colors.grey,
              ),
            ),
          ],
        ],
      ),
    ),
  );
}


Widget _buildProgressSection() {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    elevation: 4,
    shadowColor: Colors.grey.shade300,
    color: Color(0xFFFFFFFF),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progrès',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'NunitoBold',
                  color: Color(0xFF2F2F2F),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/progres_habitude');
                },
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      colors: [Color(0xFFB9ADFF), Color(0xFF9381FF)],
                    ).createShader(bounds);
                  },
                  child: Row(
                  children: [
                    Text(
                      'Tout',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFFAB96FF)),
                    ),
                    SizedBox(width: 4), // Ajoute un petit espace
                    Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFAB96FF)),
                  ],
                ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              CircularPercentIndicator(
                radius: 50.0,
                lineWidth: 10.0,
                percent: 0.6,
                center: const Text(
                  '60%',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Nunito',
                    color: Color(0xFF2F2F2F),
                  ),
                ),
                linearGradient: const LinearGradient(
                  colors: [Color(0xFFB9ADFF), Color(0xFF9381FF)],
                ),
                backgroundColor: Color(0xFFE0E0E0),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Résultats par rapport à vos objectifs de durée',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Nunito',
                        color: Color(0xFF2F2F2F),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: const Color(0xFF9381FF),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: const LinearProgressIndicator(
                          value: 0.5,
                          backgroundColor: Color(0xFFE0E0E0),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      '5/10 Jours réussis',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Nunito',
                        color: Color(0xFF9381FF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}


Widget _buildObjectivesSection() {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 4,
    shadowColor: Colors.grey.shade300,
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Objectifs',
                style: TextStyle(fontSize: 18, fontFamily: 'NunitoBold', color: Color(0xFF2F2F2F)),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/tous_les_objectifs', arguments: {'habitId': widget.habitId});
                },
                child: Row(
                  children: [
                    Text(
                      'Tout',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFFAB96FF)),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFAB96FF)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Liste des objectifs (s'ils existent)
          _objectifs.isEmpty
              ? Center(
                  child: Text("Aucun objectif pour l'instant.", style: TextStyle(fontSize: 16, color: Colors.grey)),
                )
              : Column(
                  children: _objectifs.map((objectif) {
                    double progressValue = objectif["compteur"] / objectif["total"];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Color(0xFFF3F2FF), borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                objectif["nom"],
                                style: const TextStyle(fontSize: 16, fontFamily: 'NunitoBold', color: Color(0xFF2F2F2F)),
                              ),
                              Icon(Icons.edit, color: Color(0xFF9381FF)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: progressValue,
                            backgroundColor: Colors.grey.shade300,
                            color: Color(0xFF9381FF),
                            minHeight: 8,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${objectif["compteur"]} / ${objectif["total"]} ${objectif["unite_compteur"]}',
                                  style: const TextStyle(fontSize: 14, fontFamily: 'Nunito', color: Color(0xFF2F2F2F))),
                              Text('Actif', style: TextStyle(fontSize: 14, fontFamily: 'NunitoBold', color: Colors.green)),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
          const SizedBox(height: 10),

          // Bouton Ajouter un Objectif
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: const LinearGradient(colors: [Color(0xFFB9ADFF), Color(0xFF9381FF)]),
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                showCreateObjectiveDialog(
                    context: context,
                    habitId: widget.habitId,
                    addObjectiveToAPI: _addObjectiveToAPI,
                  );
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Ajouter un objectif',
                  style: TextStyle(fontSize: 16, fontFamily: 'NunitoBold', color: Colors.white)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

void showCreateObjectiveDialog({
  required BuildContext context,
  required int habitId,
  required Future<void> Function(Map<String, dynamic>) addObjectiveToAPI,
}) {
  final TextEditingController objectiveNameController = TextEditingController();
  String selectedPeriod = "7";
  String selectedObjectiveType = "Chaque jour";
  Map<String, bool> selectedModules = {
    "counter": false,
    "chrono": false,
    "reminder": false,
    "checkbox": false
  };

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF9381FF), width: 2),
        ),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🟣 Titre et bouton fermer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Nouvel Objectif',
                          style: TextStyle(
                            fontFamily: 'NunitoBold',
                            fontSize: 18,
                            color: Color(0xFF2F2F2F),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Color(0xFF2F2F2F)),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // 🟣 Nom de l'objectif
                    const Text(
                      'Nom de l\'objectif',
                      style: TextStyle(fontSize: 14, fontFamily: 'Nunito', color: Color(0xFF666666)),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: objectiveNameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFEDEDED)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 🟣 Sélection Période et Type d'Objectif
                    const Text(
                      'Période',
                      style: TextStyle(fontSize: 14, fontFamily: 'Nunito', color: Color(0xFF666666)),
                    ),
                    const SizedBox(height: 10),
                    DropdownButton<String>(
                      value: selectedPeriod,
                      isExpanded: true,
                      items: ["7", "30", "90", "365"].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text("$value jours"),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() => selectedPeriod = newValue!);
                      },
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Type d\'objectif',
                      style: TextStyle(fontSize: 14, fontFamily: 'Nunito', color: Color(0xFF666666)),
                    ),
                    const SizedBox(height: 10),
                    DropdownButton<String>(
                      value: selectedObjectiveType,
                      isExpanded: true,
                      items: ["Chaque jour", "Chaque semaine", "Chaque mois"].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() => selectedObjectiveType = newValue!);
                      },
                    ),
                    const SizedBox(height: 20),

                    // 🟣 Sélection des modules
                    const Text(
                      'Modules',
                      style: TextStyle(fontSize: 14, fontFamily: 'Nunito', color: Color(0xFF666666)),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: CheckboxListTile(
                            title: const Text("Compteur", style: TextStyle(fontSize: 12, fontFamily: 'Nunito')),
                            value: selectedModules["counter"],
                            onChanged: (bool? value) {
                              setState(() => selectedModules["counter"] = value!);
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        Expanded(
                          child: CheckboxListTile(
                            title: const Text("Chrono", style: TextStyle(fontSize: 12, fontFamily: 'Nunito')),
                            value: selectedModules["chrono"],
                            onChanged: (bool? value) {
                              setState(() => selectedModules["chrono"] = value!);
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: CheckboxListTile(
                            title: const Text("Rappel", style: TextStyle(fontSize: 12, fontFamily: 'Nunito')),
                            value: selectedModules["reminder"],
                            onChanged: (bool? value) {
                              setState(() => selectedModules["reminder"] = value!);
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        Expanded(
                          child: CheckboxListTile(
                            title: const Text("Checkbox", style: TextStyle(fontSize: 12, fontFamily: 'Nunito')),
                            value: selectedModules["checkbox"],
                            onChanged: (bool? value) {
                              setState(() => selectedModules["checkbox"] = value!);
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // 🟣 Bouton Ajouter
                    Center(
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
                          onPressed: () async {
                            if (objectiveNameController.text.isNotEmpty) {
                              Map<String, dynamic> nouvelObjectif = {
                                "nom": objectiveNameController.text,
                                "periode": selectedPeriod,
                                "type": selectedObjectiveType,
                                "modules": selectedModules,
                              };

                              await addObjectiveToAPI(nouvelObjectif);
                              Navigator.of(context).pop();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Veuillez entrer un nom d'objectif."),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          child: const Text(
                            "Ajouter l'objectif",
                            style: TextStyle(fontFamily: 'NunitoBold', fontSize: 14, color: Color(0xFFFBFBFB)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    },
  );
}


  Widget _buildResourcesSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 4,
      shadowColor: Colors.grey.shade300,
      color: Color(0xFFFFFFFF),
      child: ListTile(
        title: const Text('Ressources', style: TextStyle(fontSize: 18, fontFamily: 'NunitoBold', color: Color(0xFF2F2F2F))),
        subtitle: const Text('Rechercher des articles liés à votre habitude', style: TextStyle(fontSize: 14, fontFamily: 'Nunito', color: Color(0xFF666666))),
        trailing: const Icon(Icons.search, color: Color(0xFF9381FF)),
        onTap: () {},
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF9381FF),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Coach'),
        BottomNavigationBarItem(icon: Icon(Icons.storefront), label: 'Magasin'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Social'),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Messages'),
      ],
    );
  }
}