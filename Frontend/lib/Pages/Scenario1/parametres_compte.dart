import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ParametresCompte extends StatelessWidget {
  ParametresCompte({Key? key}) : super(key: key);

  final storage = const FlutterSecureStorage();
 
  // Déconnecter l'utilisateur
  Future<void> logout(BuildContext context) async {
    await storage.delete(key: "jwt_token"); // Supprime le token JWT
    print("Déconnexion réussie");

    // Redirige vers la page de connexion et empêche de revenir en arrière
    Navigator.pushNamedAndRemoveUntil(context, '/se_connecter', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildSettingsOption(context, "Profil"),
            _buildSettingsOption(context, "Style et Language"),
            _buildSettingsOption(context, "Aide et Support"),
            _buildSettingsOption(context, "À propos de l'application"),
            const SizedBox(height: 20),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsOption(BuildContext context, String title) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Colors.grey.shade100,
      child: ListTile(
        title: Text(title, style: const TextStyle(fontSize: 16)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Ajouter la navigation en fonction du paramètre sélectionné
          print("$title sélectionné");
        },
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Colors.red.shade50,
      child: ListTile(
        title: const Text(
          "Déconnexion",
          style: TextStyle(color: Colors.red, fontSize: 16),
        ),
        onTap: () => logout(context),
      ),
    );
  }
}
