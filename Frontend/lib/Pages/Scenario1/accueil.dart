import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Accueil extends StatefulWidget {
  const Accueil({Key? key}) : super(key: key);

  @override
  _AccueilState createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {
  String username = "Utilisateur";
  final Dio _dio = Dio();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchUsername();
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFfcfcff),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildImageContainer(),
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

  Widget _buildImageContainer() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      width: double.infinity,
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: _boxDecoration(),
      child: Image.asset(
        'assets/images/dragons_welcome.png',
        width: MediaQuery.of(context).size.width * 0.8,
        fit: BoxFit.contain,
      ),
    );
  }

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
              Text(
                'Habitudes',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2F2F2F)),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/toutes_les_habitudes'),
                child: Text(
                  'Tout',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFFAB96FF)),
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

  Widget _buildHabitList() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        String status = index % 3 == 0
            ? 'En cours'
            : index % 3 == 1
                ? 'En pause'
                : 'Obtenue';

        Color statusColor = status == 'En pause'
            ? Colors.black
            : (status == 'Obtenue' ? Color(0xFFAB96FF) : Colors.black);
        Color cardColor =
            status == 'En cours' ? Color(0xFFEDE7FF) : Colors.white;
        FontWeight titleWeight =
            status == 'En pause' ? FontWeight.normal : FontWeight.bold;

        Icon statusIcon = status == 'En cours'
            ? Icon(Icons.play_circle_fill, color: Colors.orange, size: 28)
            : status == 'En pause'
                ? Icon(Icons.pause_circle_filled, color: Colors.grey, size: 28)
                : Icon(Icons.check_circle, color: Color(0xFFAB96FF), size: 28);

        return Card(
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
                          'Habitude ${index + 1}',
                          style: TextStyle(
                            color: status == 'En pause'
                                ? Colors.black
                                : Color(0xFFAB96FF),
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
                    '${(index + 1) * 5} jours enchaînés',
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
        );
      },
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
      selectedItemColor: Color(0xFFAB96FF),
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

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
    );
  }
}
