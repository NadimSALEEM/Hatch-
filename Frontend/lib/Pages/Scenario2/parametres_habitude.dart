import 'package:flutter/material.dart';

class ParametresHabitude extends StatefulWidget {
  const ParametresHabitude({Key? key}) : super(key: key);

  @override
  _ParametresHabitudeState createState() => _ParametresHabitudeState();
}

class _ParametresHabitudeState extends State<ParametresHabitude> {
  bool isActive = true; //false si l'habitude est en pause
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2F2F2F)), // Bouton retour 🔙
          onPressed: () {
            Navigator.pop(context); // Retour en arrière
          },
        ),
        centerTitle: true,
        title: const Text(
          "Paramètres",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'NunitoBold',
            color: Color(0xFF2F2F2F),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              Center(
                child: Column(
                  children: [
                    _buildParamButton(context, 'Changer le dragon'),
                    const SizedBox(height: 16),
                    _buildParamButton(context, 'Modifier l\'habitude'),
                  ],
                ),
              ),

              const Spacer(),

              //Bouton Activer habitude (désactivé par défaut)
              Center(
                child: Column(
                  children: [
                    _buildActionButton(
                      context,
                      "Activer l'habitude",
                      !isActive, // Si l'habitude est active: bouton désactivé
                      onPressed: () {
                        setState(() {
                          isActive = true; // Réactive l'habitude
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Bouton Mettre en pause l'habitude (actif par défaut)
                    _buildActionButton(
                      context,
                      "Mettre en pause l'habitude",
                      isActive, // Si l'habitude est active: bouton actif
                      onPressed: () {
                        showPauseHabitDialog(context, "Nom de l'habitude"); //remplacer par le vrai nom de l'habitude
                      },
                    ),

                    const SizedBox(height: 16),

                    // Bouton Supprimer l'habitude
                    _buildActionButton(
                      context,
                      "Supprimer l'habitude",
                      true, // Toujours actif
                      onPressed: () {
                        //suppression de l'habitude
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Boutons paramètre (style général)
  Widget _buildParamButton(BuildContext context, String label) {
    return GestureDetector(
      onTap: () {
        // pas d'actions définies pour le moment
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F7FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'NunitoBold',
                fontSize: 16,
                color: Color(0xFF2F2F2F),
              ),
            ),
            const Text(
              '>',
              style: TextStyle(
                fontFamily: 'NunitoBold',
                fontSize: 18,
                color: Color(0xFF2F2F2F),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bouton action (activer / pause)
  Widget _buildActionButton(
    BuildContext context,
    String label,
    bool isActive, {
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: isActive ? onPressed : null,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  colors: [Color(0xFFB9ADFF), Color(0xFF9381FF)],
                )
              : null,
          color: isActive ? null : const Color(0xFFE0E0E0), 
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'NunitoBold',
              fontSize: 14,
              color: Color(0xFFFBFBFB),
            ),
          ),
        ),
      ),
    );
  }

  void showPauseHabitDialog(BuildContext context, String habitName) {
    String selectedPeriod = "15"; 

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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Mettre en pause',
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
                      const SizedBox(height: 20),

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

                      // Sélection de la période
                      const Text(
                        'Période',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Nunito',
                          color: Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButton<String>(
                        value: selectedPeriod,
                        isExpanded: true,
                        items: ["15", "30", "60", "90"].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text("$value jours"),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedPeriod = newValue!;
                          });
                        },
                      ),
                      const SizedBox(height: 30),

                      // Bouton "Mettre en pause"
                      Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                              // Mettre l'habitude en pause et revenir à l'écran principal
                              Navigator.of(context).pop(true); // Envoie la valeur true
                            },
                            child: const Text(
                              "Mettre en pause",
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
                            Navigator.of(context).pop(false); // Envoie false si annule
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
                  ),
                );
              },
            ),
          ),
        );
      },
    ).then((value) {
      // Si la valeur retournée est true, on met l'habitude en pause
      if (value != null && value) {
        setState(() {
          isActive = false; // Mettre l'habitude en pause
        });
      }
    });
  }
}
