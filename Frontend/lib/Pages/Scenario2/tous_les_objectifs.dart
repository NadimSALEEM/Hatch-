import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TousLesObjectifs extends StatefulWidget {
  final int habitId;

  const TousLesObjectifs({Key? key, required this.habitId}) : super(key: key);

  @override
  _TousLesObjectifsState createState() => _TousLesObjectifsState();
}

class _TousLesObjectifsState extends State<TousLesObjectifs> {
  final Dio _dio = Dio();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  List<dynamic> _objectifs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchObjectives();
  }

  Future<void> fetchObjectives() async {
    try {
      String? token = await _secureStorage.read(key: "jwt_token");
      if (token == null) {
        print("Erreur : Token JWT non trouvé.");
        return;
      }

      final response = await _dio.get(
        "http://localhost:8080/habits/${widget.habitId}/objectifs",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _objectifs = response.data;
           _objectifs.sort((a, b) => b["statut"].compareTo(a["statut"])); // Trie les actifs en premier
          _isLoading = false;
        });
      } else {
        print("Erreur HTTP ${response.statusCode} : ${response.data}");
      }
    } catch (e) {
      print("Erreur lors du chargement des objectifs : $e");
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
          "Tous les objectifs",
          style: TextStyle(fontSize: 20, fontFamily: 'NunitoBold', color: Color(0xFF2F2F2F)),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(color: Color(0xFFE0E0E0), thickness: 1, height: 1),
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _buildObjectivesContainer()),
        ],
      ),
    );
  }

  // Conteneur des objectifs
  Widget _buildObjectivesContainer() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre avec le nombre d'objectifs
          Text(
            'Objectifs (${_objectifs.length})',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2F2F2F)),
          ),
          SizedBox(height: 7),
          Expanded(child: _buildObjectiveList()),
        ],
      ),
    );
  }

  // Liste des objectifs
  Widget _buildObjectiveList() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_objectifs.isEmpty) {
      return Center(
        child: Text(
          "Aucun objectif trouvé.",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: _objectifs.length,
      itemBuilder: (context, index) {
        var objectif = _objectifs[index];

        double progressValue = objectif["compteur"] / objectif["total"];

        // Définition du statut et des couleurs
        bool isActif = objectif["statut"] == 1;
        String statusText = isActif ? "Actif" : "Non actif";
        Color statusColor = isActif ? Colors.green : Colors.grey;
        Color cardColor = isActif ? Color(0xFF9381FF).withOpacity(0.1) : Colors.grey.shade50;

        Icon statusIcon = isActif
            ? Icon(Icons.play_circle_fill, color: Colors.green, size: 28)
            : Icon(Icons.pause_circle_filled, color: Colors.grey, size: 28);

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      statusIcon,
                      SizedBox(width: 12),
                      Text(
                        objectif["nom"],
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'NunitoBold',
                          color: Color(0xFF2F2F2F),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, color: Color(0xFF9381FF)),
                    onPressed: () {
                      // Ajouter ici la navigation vers la modification
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progressValue,
                backgroundColor: Colors.grey.shade300,
                color: Color(0xFF9381FF),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${objectif["compteur"]} / ${objectif["total"]} ${objectif["unite_compteur"]}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Nunito',
                      color: Color(0xFF2F2F2F),
                    ),
                  ),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'NunitoBold',
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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
