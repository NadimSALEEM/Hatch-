import 'package:flutter/material.dart';
import 'creer_objectif.dart';

class CreerHabitude extends StatefulWidget {
  const CreerHabitude({Key? key}) : super(key: key);

  @override
  _CreerHabitudeState createState() => _CreerHabitudeState();
}

class _CreerHabitudeState extends State<CreerHabitude> {
  final TextEditingController _habitsNameController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final TextEditingController _objectiveNameController =TextEditingController();
  final List<String> _tags = []; // Liste pour stocker les tags
  String _selectedPriority = "";
  //Variables création d'objectifs
  String? _selectedPeriod = "7";
  String? _selectedObjectiveType = "Chaque jour";
  final List<Map<String, String>> _objectifs = []; // Liste des objectifs

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

  //Appel de la popup de création d'objectifs
  void _showCreateObjectiveDialog() {
    showCreateObjectiveDialog(
      context,
      _objectiveNameController,
      _selectedPeriod,
      _selectedObjectiveType,
      (String name, String period, String type) {
        setState(() {
          // Ajouter l'objectif la liste
          _addObjective(name, period, type);
        });

        // Réinitialisation des champs après la création
        _objectiveNameController.clear();
        _selectedPeriod = "7";
        _selectedObjectiveType = "Chaque jour";
      },
    );
  }

  //Ajout d'objectif à la liste
  void _addObjective(String name, String period, String type) {
    setState(() {
      _objectifs.add({
        "nom": name,
        "periode": period,
        "type": type,
      });
    });
  }

  //Appel de la popup de modification d'objectifs
  void _showEditObjectiveDialog(Map<String, String> objectif) {
  showEditObjectiveDialog(
    context,
    objectif,
    (updatedObjective) {
      setState(() {
        // Trouver l'objectif dans la liste et le mettre à jour
        int index = _objectifs.indexOf(objectif);
        if (index != -1) {
          _objectifs[index] = updatedObjective;
        }
      });
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
                  int currentDay =1; 
                  int totalDays = int.parse(objectif["periode"] ??"7"); // Période en jours, 7 par défaut
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
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFB9ADFF)),
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

  // Bouton "Créer l'habitude"
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
          onPressed: () {
            if (_habitsNameController.text.trim().isEmpty) {
              // Message d'erreur si le champ est vide
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Veuillez saisir un nom pour votre habitude."),
                  backgroundColor: Colors.red,
                ),
              );
            } else {
              Navigator.pushNamed(context, '/post_creation_habitude');
            }
          },
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
