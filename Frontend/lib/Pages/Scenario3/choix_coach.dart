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
        setState(() {
          coachList = data;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Choisir un coach")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: coachList.length,
              itemBuilder: (context, index) {
                final coach = coachList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(coach['nom'] ?? 'Coach inconnu'),
                    subtitle: Text("${coach['mbti'] ?? 'N/A'}\n${coach['desc'] ?? 'N/A'}"),
                    trailing: ElevatedButton(
                      child: const Text("Choisir"),
                      onPressed: () => assignCoach(coach['id']),
                    ),
                  ),
                );
              },
            ),
    );
  }
}