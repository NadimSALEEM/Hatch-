import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

class CoachListPage extends StatefulWidget {
  const CoachListPage({Key? key}) : super(key: key);

  @override
  _ChoixCoachPageState createState() => _ChoixCoachPageState();
}

class _ChoixCoachPageState extends State<CoachListPage> {
  final storage = const FlutterSecureStorage();
  List<Map<String, dynamic>> coachList = [];
  int? currentCoachId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCoachData();
  }

  Future<void> loadCoachData() async {
    String? token = await storage.read(key: "jwt_token");
    if (token != null) {
      try {
        final data = await fetchCoachList(token);
        final userData = await fetchUserData(token);
        setState(() {
          coachList = data;
          currentCoachId = userData["coach_assigne"];
          isLoading = false;
        });
      } catch (e) {
        print("Erreur chargement coachs : $e");
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<List<Map<String, dynamic>>> fetchCoachList(String token) async {
    final Dio dio = Dio();
    final response = await dio.get(
      "http://localhost:8080/coach/",
      options: Options(
        headers: {"Authorization": "Bearer $token"},
      ),
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(response.data);
    } else {
      throw Exception("Erreur lors de la récupération des coachs : ${response.statusCode}");
    }
  }

  Future<Map<String, dynamic>> fetchUserData(String token) async {
    final Dio dio = Dio();
    final response = await dio.get(
      "http://localhost:8080/users/me",
      options: Options(
        headers: {"Authorization": "Bearer $token"},
      ),
    );
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(response.data);
    } else {
      throw Exception("Erreur lors de la récupération de l'utilisateur");
    }
  }

  void assignCoach(int coachId) async {
    String? token = await storage.read(key: "jwt_token");
    if (token == null) return;

    try {
      final Dio dio = Dio();
      await dio.put(
        "http://localhost:8080/users/me/update",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
        data: {
          "coach_id": coachId,
        },
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Coach assigné avec succès !")),
        );
        loadCoachData();
      }
    } catch (e) {
      print("Erreur assignation coach : $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors de l'assignation du coach.")),
        );
      }
    }
  }

  void _showConfirmationDialog(String currentCoachName, String newCoachName, int newCoachId) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.swap_horiz, size: 48),
                const SizedBox(height: 20),
                Text(
                  "Voulez-vous changer\n$currentCoachName pour $newCoachName ?",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Vous pourrez revenir sur\nvotre choix plus tard",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8F7CF8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      assignCoach(newCoachId);
                    },
                    child: const Text("Confirmer", style: TextStyle(color: Colors.white)),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Annuler", style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildCoachCard(Map<String, dynamic> coach, {bool isCurrent = false}) {
    final coachId = coach['id'];
    final image = Image.asset(
      '../../../assets/images/coach/$coachId.png',
      width: 80,
      height: 80,
      fit: BoxFit.cover,
    );

    final backgroundColor = isCurrent ? const Color(0xFF7E1E2A) : Colors.grey.shade100;
    final textColor = isCurrent ? Colors.white : Colors.black;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          image,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coach['nom'] ?? 'Coach inconnu',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  coach['desc'] ?? 'Pas de description.',
                  style: TextStyle(color: textColor),
                ),
                if (!isCurrent) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      onPressed: () {
                        _showConfirmationDialog("votre coach actuel", coach['nom'], coachId);
                      },
                      child: const Text("Choisir ce coach"),
                    ),
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentCoach = coachList.where((c) => c['id'] == currentCoachId).toList();
    final otherCoaches = coachList.where((c) => c['id'] != currentCoachId).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Changement de coach")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text("Votre coach actuel :", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  if (currentCoach.isNotEmpty) buildCoachCard(currentCoach.first, isCurrent: true),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: Text("Autres coachs disponibles :", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  ...otherCoaches.map((c) => buildCoachCard(c)).toList(),
                ],
              ),
            ),
    );
  }
}
