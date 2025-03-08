import 'package:flutter/material.dart';

//Popup de création d'objectif
void showCreateObjectiveDialog(
  BuildContext context, //affichage popup
  TextEditingController objectiveNameController, //nom de l'objectif
  String? selectedPeriod, //période choisie
  String? selectedObjectiveType, //type d'objectif choisi
  Function(String, String, String) onObjectiveCreated,
  String habitName,
) {
  //fonction appelée quand on valide l'objectif
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
                        'Création d\'un objectif',
                        style: TextStyle(
                          fontFamily: 'NunitoBold',
                          fontSize: 18,
                          color: Color(0xFF2F2F2F),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFF2F2F2F)),
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
                      controller: TextEditingController(text: habitName),
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
                        color: Color(0xFF666666)),
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
                  const SizedBox(height: 30),

                  // Période
                  const Text(
                    'Période',
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Nunito',
                        color: Color(0xFF666666)),
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
                      setState(() {
                        selectedPeriod = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 30),

                  // Type d'objectif
                  const Text(
                    'Type d\'objectif',
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Nunito',
                        color: Color(0xFF666666)),
                  ),
                  const SizedBox(height: 10),
                  DropdownButton<String>(
                    value: selectedObjectiveType,
                    isExpanded: true,
                    items: ["Chaque jour", "Chaque semaine", "Chaque mois"]
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedObjectiveType = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 30),

                  // Bouton Créer
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
                      onPressed: () {
                        // Vérification du nom avant de créer l'objectif
                        if (objectiveNameController.text.isNotEmpty) {
                          onObjectiveCreated(objectiveNameController.text,
                              selectedPeriod!, selectedObjectiveType!);
                          Navigator.of(context).pop();
                        } else {
                          //message d'erreur si le nom est vide
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text("Veuillez entrer un nom d'objectif."),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: const Text(
                        "Créer",
                        style: TextStyle(
                          fontFamily: 'NunitoBold',
                          fontSize: 14,
                          color: Color(0xFFFBFBFB),
                        ),
                      ),
                    ),
                  )),
                ],
              );
            },
          ),
        ),
      );
    },
  );
}

//Popup de modification d'objectif
void showEditObjectiveDialog(
  BuildContext context,
  Map<String, String> objectif,
  Function(Map<String, String>) onObjectiveUpdated,
  Function onObjectiveDeleted,
  String habitName,
) {
  TextEditingController objectiveNameController =
      TextEditingController(text: objectif["nom"]);
  String? selectedPeriod = objectif["periode"];
  String? selectedObjectiveType = objectif["type"];

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
                        'Modification d\'un objectif',
                        style: TextStyle(
                          fontFamily: 'NunitoBold',
                          fontSize: 18,
                          color: Color(0xFF2F2F2F),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFF2F2F2F)),
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
                      controller: TextEditingController(text: habitName),
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
                        color: Color(0xFF666666)),
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
                  const SizedBox(height: 30),

                  // Période
                  const Text(
                    'Période',
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Nunito',
                        color: Color(0xFF666666)),
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
                      setState(() {
                        selectedPeriod = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 30),

                  // Type d'objectif
                  const Text(
                    'Type d\'objectif',
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Nunito',
                        color: Color(0xFF666666)),
                  ),
                  const SizedBox(height: 10),
                  DropdownButton<String>(
                    value: selectedObjectiveType,
                    isExpanded: true,
                    items: ["Chaque jour", "Chaque semaine", "Chaque mois"]
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedObjectiveType = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 30),

                  // Bouton Modifier
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
                        onPressed: () {
                          if (objectiveNameController.text.isNotEmpty) {
                            // mise à jour de l'objectif
                            onObjectiveUpdated({
                              "nom": objectiveNameController.text,
                              "periode": selectedPeriod!,
                              "type": selectedObjectiveType!,
                            });
                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text(
                          "Modifier",
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

                  // Bouton Supprimer
                  Center(
                    child: TextButton(
                      onPressed: () {
                        _showDeleteConfirmationDialog(context, () {
                          onObjectiveDeleted(); // Appelle la suppression depuis creerhabitude.dart
                        });
                      },
                      child: const Text(
                        "Supprimer l'objectif",
                        style: TextStyle(
                          fontFamily: 'NunitoBold',
                          fontSize: 14,
                          color: Colors.black,
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

void _showDeleteConfirmationDialog(
    BuildContext context, Function onObjectiveDeleted) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icône de suppression
            Image.asset(
              'assets/images/corbeille_suppression.png',
              height: 70,
              width: 70,
            ),
            const SizedBox(height: 10),
            const Text(
              'Etes-vous sûr de vouloir supprimer cet objectif?',
              style: TextStyle(
                fontFamily: 'NunitoBold',
                fontSize: 18,
                color: Color(0xFF2F2F2F),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
          ],
        ),
        actions: <Widget>[
          // Bouton Supprimer
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
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  onObjectiveDeleted();
                  _showDeleteSuccessDialog(context);
                },
                child: const Text(
                  "Supprimer",
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
          // Bouton Annuler
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Annuler',
                style: TextStyle(
                  fontFamily: 'NunitoBold',
                  fontSize: 14,
                  color: Color(0xFF2F2F2F),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

//Suppression de l'objectif
void onObjectiveDeleted(BuildContext context) {
  print("Objectif supprimé");
  _showDeleteSuccessDialog(context);
}

//Popup confirmation suppresion de l'objectif
void _showDeleteSuccessDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icone de succès
            Image.asset(
              'assets/images/Habitude/deleteOk.png',
              height: 90,
              width: 90,
            ),
            const SizedBox(height: 10),
            const Text(
              'L\'objectif a bien été supprimé.',
              style: TextStyle(
                fontFamily: 'NunitoBold',
                fontSize: 18,
                color: Color(0xFF2F2F2F),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: <Widget>[
          // Bouton OK
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
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "OK",
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
    },
  );
}
