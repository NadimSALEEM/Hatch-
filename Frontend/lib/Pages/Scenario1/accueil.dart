import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Accueil extends StatefulWidget {
  const Accueil({Key? key}) : super(key: key);

  @override
  _AccueilState createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {
  
  // Nom d'utilisateur par défaut
  String username = "Utilisateur";
  final Dio _dio = Dio();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  List<dynamic> _habits = [];

  // Index de la page actuelle pour le bas de navigation
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchUsername();
    fetchHabits();
  }

  // Récupérer le nom d'utilisateur
  Future<void> fetchUsername() async {
    try {
      String? token = await _secureStorage.read(key: "jwt_token");
      if (token == null) return;

      final response = await _dio.get(
        "http://localhost:8080/users/me",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        setState(() {
          username = response.data["nom_utilisateur"] ?? "Utilisateur";
        });
      }
    } catch (e) {
      print("Erreur lors de la récupération du nom d'utilisateur : $e");
    }
  }

  Future<void> fetchHabits() async {
    try {
      String? token = await _secureStorage.read(key: "jwt_token");
      if (token == null) return;

      final response = await _dio.get(
        "http://localhost:8080/habits/",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        List<dynamic> allHabits = response.data;

        // Filtrer uniquement les habitudes "En cours" (1) et "En pause" (0)
        List<dynamic> filteredHabits = allHabits.where((habit) {
          return habit["statut"] == 1 || habit["statut"] == 0;
        }).toList();

        // Trier : "En cours" (1) en haut, "En pause" (0) en bas
        filteredHabits.sort((a, b) => b["statut"].compareTo(a["statut"]));

        setState(() {
          _habits = filteredHabits;
        });
      }
    } catch (e) {
      print("Erreur lors de la récupération des habitudes : $e");
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFfcfcff),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildImageContainer(context),
          Expanded(flex: 3, child: _buildHabitsContainer()),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/creer_une_habitude');
        },
        backgroundColor: Color(0xFFAB96FF),
        child: Icon(Icons.add, size: 32, color: Colors.white),
        shape: CircleBorder(),
        elevation: 6,
      ),
    );
  }

  // Barre d'application
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: "Salut, ",
              style: TextStyle(fontSize: 20, fontFamily: 'NunitoBold', color: Color(0xFF2F2F2F)),
            ),
            TextSpan(
              text: username,
              style: TextStyle(fontSize: 20, fontFamily: 'NunitoBold', color: Color(0xFFAB96FF)),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings, color: Color(0xFF2F2F2F)),
          onPressed: () => Navigator.pushNamed(context, '/parametres_compte'),
        ),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(color: Color(0xFFE0E0E0), thickness: 1, height: 1),
      ),
    );
  }

// Conteneur de l'image
Widget _buildImageContainer(BuildContext context) {
  return Container(
    height: MediaQuery.of(context).size.height * 0.3,
    width: double.infinity,
    margin: EdgeInsets.all(16),
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Color(0xFFAB96FF).withOpacity(0.1), // Lueur violette autour
          blurRadius: 20,
          spreadRadius: 5,
          offset: Offset(0, 5),
        ),
      ],
    ),
    child: Column(
      children: [
        Text(
          "🔥Tes habitudes forgent des dragons légendaires🔥",
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'NunitoSemiBold',
            fontWeight: FontWeight.w500,
            color: Colors.orange,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10), // Espacement avant l'image
        Image.asset(
          'assets/images/dragons_welcome.png',
          width: MediaQuery.of(context).size.width * 0.5,
          fit: BoxFit.contain,
        ),
      ],
    ),
  );
}


  // Conteneur des habitudes
  Widget _buildHabitsContainer() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Habitudes (${_habits.length})', // Ajoute le nombre d’habitudes
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2F2F2F)),
                  ),
                ],
              ),

              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/toutes_les_habitudes'),
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
            ],
          ),
          SizedBox(height: 7),
          Expanded(child: _buildHabitList()),
        ],
      ),
    );
  }

  // Liste des habitudes
  Widget _buildHabitList() {
    if (_habits.isEmpty) {
      return Center(
        child: Text(
          "Aucune habitude en cours ou en pause.",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: _habits.length,
      itemBuilder: (context, index) {
        var habit = _habits[index];

        String status = habit["statut"] == 1 ? "En cours" : "En pause";
        Color statusColor = status == 'En pause' ? Colors.grey : Colors.orange;
        Color cardColor = status == 'En cours' ? Color(0xFFEDE7FF) : Colors.white;
        FontWeight titleWeight = status == 'En pause' ? FontWeight.normal : FontWeight.bold;

        Icon statusIcon = status == 'En cours'
            ? Icon(Icons.play_circle_fill, color: Colors.orange, size: 28)
            : Icon(Icons.pause_circle_filled, color: Colors.grey, size: 28);

        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/habitude',
              arguments: {'habitId': habit["id"]}, // Utiliser l'ID réel de l'habitude
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
                  if (status == 'En cours') ...[
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


  // Décoration de la boîte
  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
    );
  }

}
