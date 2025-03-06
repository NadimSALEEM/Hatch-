import 'package:flutter/material.dart';

class CreerHabitude extends StatefulWidget {
  const CreerHabitude({Key? key}) : super(key: key);

  @override
  _CreerHabitudeState createState() => _CreerHabitudeState();
}

class _CreerHabitudeState extends State<CreerHabitude> {
  final TextEditingController _habitsNameController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  List<String> _tags = []; // Liste pour stocker les tags
  String _selectedPriority = "";
  //Variables création d'objectifs
  String? _selectedPeriod = "7";
  String? _selectedObjectiveType = "Chaque jour";
  TextEditingController _objectiveNameController = TextEditingController();

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

  void _submitObjective(BuildContext context) {
    if (_objectiveNameController.text.isEmpty) {
      // Afficher un message d'erreur si le champ est vide
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez entrer un nom d'objectif."),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      //Enregistrer objectif
      String objectiveName = _objectiveNameController.text;
      String objectivePeriod = _selectedPeriod ?? "7";
      String objectiveType = _selectedObjectiveType ?? "Chaque jour";

      // Réinitialisation des champs
      _objectiveNameController.clear();
      _selectedPeriod = "7";
      _selectedObjectiveType = "Chaque jour";

      Navigator.of(context).pop();
    }
  }

  void _showCreateObjectiveDialog(BuildContext context) {
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
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Création d’un objectif',
                          style: TextStyle(
                            fontFamily: 'NunitoBold',
                            fontSize: 18,
                            color: Color(0xFF2F2F2F),
                          ),
                        ),
                        IconButton(
                          icon:
                              const Icon(Icons.close, color: Color(0xFF2F2F2F)),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Nom de l'habitude (readonly)
                    const Text(
                      'Nom de l\'habitude',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Nunito',
                        color: Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Color(0xFFEDEDED),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: TextEditingController(
                            text: _habitsNameController.text),
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        readOnly: true,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Nom de l'objectif
                    const Text(
                      'Nom de l\'objectif',
                      style: TextStyle(
                        fontSize: 14,
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
                        border: Border.all(color: Color(0xFFEDEDED)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _objectiveNameController,
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

                    const SizedBox(height: 30),

                    // Période
                    const Text(
                      'Période',
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
                              border: Border.all(color: Color(0xFFEDEDED)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedPeriod,
                                isExpanded: true,
                                items: [
                                  "7",
                                  "30",
                                  "90",
                                  "365",
                                ].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      "$value ",
                                      style: const TextStyle(
                                        fontFamily: 'Nunito',
                                        fontSize: 14,
                                        color: Color(0xFF666666),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedPeriod =
                                        newValue; // Mise à jour de la période sélectionnée
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "jours",
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 14,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Type d'objectif
                    const Text(
                      'Type d\'objectif',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Nunito',
                        color: Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Color(0xFFEDEDED)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedObjectiveType,
                          isExpanded: true,
                          items: [
                            "Chaque jour",
                            "Chaque semaine",
                            "Chaque mois",
                          ].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 14,
                                  color: Color(0xFF666666),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedObjectiveType =
                                  newValue; // Mise à jour du type d'objectif
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Bouton Créer
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          _submitObjective(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          width: 200,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFB9ADFF), Color(0xFF9381FF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Créer',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
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
              _showCreateObjectiveDialog(context);
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
