import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ToutesLesHabitudes extends StatefulWidget {
  const ToutesLesHabitudes({Key? key}) : super(key: key);

  @override
  _ToutesLesHabitudesState createState() => _ToutesLesHabitudesState();
}

class _ToutesLesHabitudesState extends State<ToutesLesHabitudes> {
  final Dio _dio = Dio();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  List<dynamic> _habits = [];
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchHabits();
  }

  Future<void> fetchHabits() async {
    try {
      String? token = await _secureStorage.read(key: "jwt_token");
      if (token == null) {
        print("Erreur : Token JWT non trouvé.");
        return;
      }

      final response = await _dio.get(
        "http://localhost:8080/habits/",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _habits = response.data; // Récupère toutes les habitudes SANS FILTRE
          _isLoading = false;
        });
      } else {
        print("Erreur HTTP ${response.statusCode} : ${response.data}");
      }
    } catch (e) {
      print("Erreur lors de la récupération des habitudes : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFfcfcff),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF2F2F2F)),
        title: const Text(
          "Toutes les habitudes",
          style: TextStyle(fontSize: 20, fontFamily: 'NunitoBold', color: Color(0xFF2F2F2F)),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(color: Color(0xFFE0E0E0), thickness: 1, height: 1),
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _buildHabitsContainer()), // Conteneur des habitudes
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // Conteneur des habitudes (même design que l'accueil)
  Widget _buildHabitsContainer() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre avec nombre d’habitudes
          Text(
            'Habitudes (${_habits.length})',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2F2F2F)),
          ),
          SizedBox(height: 7),
          Expanded(child: _buildHabitList()), // Liste des habitudes
        ],
      ),
    );
  }

  // Liste des habitudes (garde le même style que l’accueil)
  Widget _buildHabitList() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_habits.isEmpty) {
      return Center(
        child: Text(
          "Aucune habitude trouvée.",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: _habits.length,
      itemBuilder: (context, index) {
        var habit = _habits[index];

        // Définition du statut
        String status = habit["statut"] == 1
            ? "En cours"
            : habit["statut"] == 0
                ? "En pause"
                : "Terminée";
        Color statusColor = habit["statut"] == 1
            ? Colors.orange
            : habit["statut"] == 0
                ? Colors.grey
                : Colors.green;
        Color cardColor = habit["statut"] == 1 ? Color(0xFFEDE7FF) : Colors.white;
        FontWeight titleWeight = habit["statut"] == 0 ? FontWeight.normal : FontWeight.bold;

        Icon statusIcon = habit["statut"] == 1
            ? Icon(Icons.play_circle_fill, color: Colors.orange, size: 28)
            : habit["statut"] == 0
                ? Icon(Icons.pause_circle_filled, color: Colors.grey, size: 28)
                : Icon(Icons.check_circle, color: Colors.green, size: 28);

        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/habitude',
              arguments: {'habitId': habit["id"]},
            );
          },
          child: Card(
            elevation: 4,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            color: cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            shadowColor: Colors.grey.shade300,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          statusIcon,
                          SizedBox(width: 12),
                          Text(
                            habit["nom"],
                            style: TextStyle(
                              color: Color(0xFFAB96FF),
                              fontWeight: titleWeight,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (habit["statut"] == 1) ...[
                    SizedBox(height: 6),
                    Text(
                      '${habit["nb_jours_consecutifs"] ?? 0} jours enchaînés',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

    //  Barre de navigation en bas
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        // Vérifie si on est déjà sur la page sélectionnée
        if (_selectedIndex == index) return;

        setState(() {
          _selectedIndex = index;
        });

        // Navigation uniquement pour Accueil et Coach pour l'instant
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
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Coach'),
        BottomNavigationBarItem(icon: Icon(Icons.storefront), label: 'Magasin'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Social'),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Messages'),
      ],
    );
  }

  // Style du conteneur
  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
    );
  }
}
