import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Questionnaire extends StatefulWidget {
  const Questionnaire({Key? key}) : super(key: key);

  @override
  _QuestionnaireState createState() => _QuestionnaireState();
}

class _QuestionnaireState extends State<Questionnaire> {
  PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalSections = 4;

  String getCoachImagePath(String coachName) {
    switch (coachName) {
      case "Coach Diplomate":
        return "../../../assets/images/coach/1.png";
      case "Coach Explorateur":
        return "../../../assets/images/coach/2.png";
      case "Coach Sentinelle":
        return "../../../assets/images/coach/3.png";
      case "Coach Analyste":
        return "../../../assets/images/coach/4.png";
      default:
        return "../../../assets/images/coach/1.png"; // fallback générique
    }
  }

  Map<int, bool?> responses = {}; // Stocke les réponses au questionnaire

  //Affirmations
  final List<String> section1Questions = [
    "J'ai besoin de temps seul pour me ressourcer après des interactions sociales.",
    "Je m'exprime facilement dans les discussions de groupe. ",
    "Je préfère les discussions profondes en tête-à-tête plutôt que les grandes réunions sociales.",
    "Je me sens énergisé après avoir passé du temps avec un groupe de personnes.",
    "Je me sens plus productif lorsque je travaille seul dans un environnement calme."
  ];

  final List<String> section2Questions = [
    "J'aime explorer de nouvelles idées et théories, même abstraites.",
    "Je préfère suivre des étapes précises et logiques dans mon travail. ",
    "J'aime imaginer des scénarios et explorer des perspectives nouvelles. ",
    "Je me sens plus à l'aise avec des informations concrètes et vérifiables. ",
    "Je fais souvent des liens entre des concepts qui semblent sans rapport. "
  ];

  final List<String> section3Questions = [
    "J'ai tendance à me laisser guider par mes sentiments dans mes choix importants.",
    "Je préfère dire la vérité même si elle peut blesser quelqu'un. ",
    "Je trouve important de valoriser les sentiments et le bien-être des autres.",
    "Je trouve important d'analyser les choses avec rigueur et rationalité. ",
    "Je prends en compte les émotions des autres avant de prendre une décision. "
  ];

  final List<String> section4Questions = [
    "Je me sens plus productif lorsque je peux explorer différentes approches et solutions.",
    "J'aime planifier les choses à l'avance et éviter les imprévus.",
    "Je me sens plus à l'aise quand j'ai plusieurs options ouvertes plutôt qu'un plan rigide.",
    "Je termine toujours mes tâches bien avant la date limite. ",
    "Je préfère expérimenter et ajuster au fur et à mesure plutôt que suivre des règles fixes. ",
  ];

  void _nextPage() {
    if (_currentPage < _totalSections) {
      _pageController.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
          duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  bool _allQuestionsAnswered(int sectionIndex) {
    int start = sectionIndex * 5;
    int end = start + 5;

    for (int i = start; i < end; i++) {
      if (responses[i] == null) {
        return false;
      }
    }
    return true;
  }

  bool _showError = false;

  String calculerMBTI(Map<int, bool?> responses) {
    List<String> questionTypes = [
      "I",
      "E",
      "I",
      "E",
      "I",
      "N",
      "S",
      "N",
      "S",
      "N",
      "F",
      "T",
      "F",
      "T",
      "F",
      "P",
      "J",
      "P",
      "J",
      "P"
    ];

    int E = 0, I = 0, S = 0, N = 0, T = 0, F = 0, J = 0, P = 0;

    for (int i = 0; i < 20; i++) {
      if (responses[i] == true) {
        switch (questionTypes[i]) {
          case "E":
            E++;
            break;
          case "I":
            I++;
            break;
          case "S":
            S++;
            break;
          case "N":
            N++;
            break;
          case "T":
            T++;
            break;
          case "F":
            F++;
            break;
          case "J":
            J++;
            break;
          case "P":
            P++;
            break;
        }
      } else {
        switch (questionTypes[i]) {
          case "E":
            I++;
            break;
          case "I":
            E++;
            break;
          case "S":
            N++;
            break;
          case "N":
            S++;
            break;
          case "T":
            F++;
            break;
          case "F":
            T++;
            break;
          case "J":
            P++;
            break;
          case "P":
            J++;
            break;
        }
      }
    }

    String typeMBTI = "";
    typeMBTI += (E > I) ? "E" : "I";
    typeMBTI += (S > N) ? "S" : "N";
    typeMBTI += (T > F) ? "T" : "F";
    typeMBTI += (J > P) ? "J" : "P";

    return typeMBTI;
  }

  String attribuerCoach(String mbti) {
    if (["INFJ", "INFP", "ENFJ", "ENFP"].contains(mbti)) {
      return "Coach Diplomate";
    } else if (["ISTP", "ISFP", "ESTP", "ESFP"].contains(mbti)) {
      return "Coach Explorateur";
    } else if (["ISTJ", "ISFJ", "ESTJ", "ESFJ"].contains(mbti)) {
      return "Coach Sentinelle";
    } else if (["INTJ", "INTP", "ENTJ", "ENTP"].contains(mbti)) {
      return "Coach Analyste";
    } else {
      return "Coach Inconnu";
    }
  }

  int coachNameToId(String coachName) {
    switch (coachName) {
      case "Coach Diplomate":
        return 1;
      case "Coach Explorateur":
        return 2;
      case "Coach Sentinelle":
        return 3;
      case "Coach Analyste":
        return 4;
      default:
        return 0;
    }
  }

  Future<void> updateCoach(String coachName) async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: "jwt_token");

    if (token == null) {
      print("❌ Aucun token trouvé.");
      return;
    }

    final coachId = coachNameToId(coachName);

    final Dio dio = Dio();
    try {
      final response = await dio.put(
        "http://localhost:8080/users/me/update",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
        data: {
          "coach_assigne": coachId,
        },
      );

      if (response.statusCode == 200) {
        print("Coach mis à jour avec succès !");
      } else {
        print("Erreur lors de la mise à jour : ${response.statusCode}");
      }
    } catch (e) {
      print("Erreur de requête : $e");
    }
  }

  void _showCompletionPopup(BuildContext context) async {
    String mbti = calculerMBTI(responses);
    String coach = attribuerCoach(mbti);

    await updateCoach(coach);
    String coachImage = getCoachImagePath(coach); // 👈 récupère le bon visuel

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(
              color: Color(0xFF9381FF),
              width: 1,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                coachImage, // 👈 image dynamique
                height: 110,
                width: 110,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 15),
              Text(
                "Un coach a bien été personnalisé:",
                style: TextStyle(
                  fontFamily: "NunitoBold",
                  fontSize: 18,
                  color: Color(0xFF2F2F2F),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              Text(
                coach,
                style: TextStyle(
                  fontFamily: "NunitoBold",
                  fontSize: 20,
                  color: Color(0xFF2F2F2F),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              Text(
                "Vous pourrez revenir sur votre choix plus tard",
                style: TextStyle(
                  fontFamily: "Nunito",
                  fontSize: 13,
                  color: Color.fromARGB(138, 47, 47, 47),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, "/accueil");
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFB9ADFF), Color(0xFF9381FF)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "OK",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: "Nunito",
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        children: [
          _buildWelcomePage(),
          _buildSectionPage("Extraversion (E) - Introversion (I)", 1,
              isFirstSection: true),
          _buildSectionPage("Sensation (S) - Intuition (N)", 2),
          _buildSectionPage("Pensée (T) - Sentiment (F)", 3),
          _buildSectionPage("Jugement (J) - Perception (P)", 4, isLast: true),
        ],
      ),
    );
  }

  //Page bienvenue
  Widget _buildWelcomePage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Bienvenue dans le questionnaire!",
              style: TextStyle(
                  fontFamily: "BricolageGrotesqueBold", fontSize: 24)),
          SizedBox(height: 16),
          Text("Nous allons vous poser 20 questions réparties en 4 catégories.",
              style: TextStyle(fontFamily: "Nunito", fontSize: 16)),
          SizedBox(height: 32),
          GestureDetector(
            onTap: _nextPage,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFB9ADFF), Color(0xFF9381FF)],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text("Commencer",
                  style: TextStyle(
                      color: Colors.white, fontFamily: "Nunito", fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }

  //Structure des pages du questionnaire
  Widget _buildSectionPage(String title, int sectionNumber,
      {bool isFirstSection = false, bool isLast = false}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: _previousPage,
              ),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.grey.shade300,
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: sectionNumber / _totalSections,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          gradient: LinearGradient(
                            colors: [Color(0xFFB9ADFF), Color(0xFF9381FF)],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Text("$sectionNumber/$_totalSections",
                  style: TextStyle(fontFamily: "Nunito")),
            ],
          ),
        ),
        Expanded(child: _buildQuestionsSection(sectionNumber - 1)),
        if (_showError) //Message d'erreur si on ne répond pas à toutes les affirmations
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              "Veuillez répondre à toutes les affirmations avant de continuer.",
              style: TextStyle(
                  color: Colors.red, fontSize: 14, fontFamily: "Nunito"),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(bottom: 32),
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (_allQuestionsAnswered(sectionNumber - 1)) {
                  _showError = false;
                  if (isLast) {
                    _showCompletionPopup(context);
                  } else {
                    _nextPage();
                  }
                } else {
                  _showError = true;
                }
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFB9ADFF), Color(0xFF9381FF)],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(isLast ? "Valider" : "Continuer",
                  style: TextStyle(
                      color: Colors.white, fontFamily: "Nunito", fontSize: 18)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionsSection(int sectionIndex) {
    final List<List<String>> allSections = [
      section1Questions,
      section2Questions,
      section3Questions,
      section4Questions,
    ];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            for (int i = 0; i < allSections[sectionIndex].length; i++)
              Column(
                children: [
                  SizedBox(height: 20),
                  Text(
                    allSections[sectionIndex][i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: "Nunito",
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio<bool>(
                        value: true,
                        groupValue: responses[sectionIndex * 5 + i],
                        onChanged: (bool? value) {
                          setState(() {
                            responses[sectionIndex * 5 + i] = value;
                          });
                        },
                      ),
                      Text("D'accord", style: TextStyle(fontSize: 13)),
                      SizedBox(width: 20),
                      Radio<bool>(
                        value: false,
                        groupValue: responses[sectionIndex * 5 + i],
                        onChanged: (bool? value) {
                          setState(() {
                            responses[sectionIndex * 5 + i] = value;
                          });
                        },
                      ),
                      Text("Pas d'accord", style: TextStyle(fontSize: 13)),
                    ],
                  ),
                ],
              ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
