import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ParametresCompte extends StatefulWidget {
  const ParametresCompte({Key? key}) : super(key: key);

  @override
  _ParametresCompteState createState() => _ParametresCompteState();
}

class _ParametresCompteState extends State<ParametresCompte> {
  final storage = const FlutterSecureStorage();
  int _selectedIndex = 0;

  // Déconnecter l'utilisateur
  Future<void> logout() async {
    await storage.delete(key: "jwt_token");
    print("Déconnexion réussie");

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
          context, '/se_connecter', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF), // Fond clair
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Paramètres',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2F2F2F),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildSettingsContainer(),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // Conteneur principal des paramètres
  Widget _buildSettingsContainer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          const SizedBox(height: 10),

          // Liste des options
          _buildSettingsOption("Profil"),
          _buildSettingsOption("Style et Language"),
          _buildSettingsOption("Aide et Support"),
          _buildSettingsOption("À propos de l'application"),
          const SizedBox(height: 10),

          // Bouton Déconnexion
          _buildLogoutButton(),
        ],
      ),
    );
  }

  // Élément de menu des paramètres 
  Widget _buildSettingsOption(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () {
          
        if (title == "Profil") {
          Navigator.pushNamed(context, '/profil'); 
        }

        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF9F8FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'NunitoBold',
                    color: Color(0xFF2F2F2F),
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF2F2F2F)),
            ],
          ),
        ),
      ),
    );
  }


  // Bouton de déconnexion stylisé
  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: logout,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3F3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Déconnexion",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'NunitoBold',
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
  }


  // Style du conteneur principal
  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 2,
          blurRadius: 5,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  //  Barre de navigation en bas (Correction incluse)
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


}
