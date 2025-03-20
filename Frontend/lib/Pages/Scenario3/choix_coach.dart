import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CoachListPage(),
    );
  }
}

class CoachListPage extends StatefulWidget {
  @override
  _CoachListPageState createState() => _CoachListPageState();
}

class _CoachListPageState extends State<CoachListPage> {
  final List<Map<String, dynamic>> coachs = [
    {'coachName': 'Albert', 'mbti': "INFP", 'id': 0},
    {'coachName': 'Activité physique', 'mbti': "INFJ", 'id': 1},
    {'coachName': 'Sommeil', 'mbti': "ESTJ", 'id': 2},
    {'coachName': 'Eren', 'mbti': "Jaeger", 'id': 3},
  ];

  final _storage = FlutterSecureStorage();
  final Dio _dio = Dio();

  Future<String?> _getToken() async {
    return await _storage.read(key: "jwt_token");
  }

  Future<void> assignCoach(int coachId) async {
    String? token = await _getToken();
    if (token == null) {
      print("Utilisateur non authentifié");
      return;
    }

    try {
      final response = await _dio.put(
        "http://localhost:8080/users/me/update",
        options: Options(headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        }),
        data: {"coach_assigne": coachId},
      );

      if (response.statusCode == 200) {
        print("Coach mis à jour avec succès");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Coach assigné avec succès!")),
        );
      } else {
        print("Erreur lors de la mise à jour : ${response.data}");
      }
    } catch (e) {
      print("Erreur de connexion : $e");
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF2F2F2F)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Liste des Coachs',
            style: TextStyle(fontSize: 20, fontFamily: 'NunitoBold', color: Color(0xFF2F2F2F))),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(color: Color(0xFFE0E0E0), thickness: 1, height: 1),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView.builder(
          itemCount: coachs.length,
          itemBuilder: (context, index) {
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              margin: EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                contentPadding: EdgeInsets.all(15),
                title: Text(
                  coachs[index]['coachName'],
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF2F2F2F)),
                ),
                subtitle: Text(
                  coachs[index]['mbti'],
                  style: TextStyle(fontSize: 14, color: Color(0xFF6F6F6F)),
                ),
                leading: CircleAvatar(
                  backgroundColor: Color(0xFFAB96FF),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.check, color: Color(0xFFAB96FF)),
                  onPressed: () => assignCoach(coachs[index]['id']),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
