import 'package:flutter/material.dart';

class Questionnaire extends StatefulWidget {
  const Questionnaire({Key? key}) : super(key: key);

  @override
  _QuestionnaireState createState() => _QuestionnaireState();
}

class _QuestionnaireState extends State<Questionnaire> {
  PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalSections = 4;

  Map<int, bool?> responses = {}; // Stocke les réponses au questionnaire

  final List<String> section1Questions = [
    "Affirmation 1",
    "Affirmation 2",
    "Affirmation 3",
    "Affirmation 4",
    "Affirmation 5"
  ];

  final List<String> section2Questions = [
    "Affirmation 6",
    "Affirmation 7",
    "Affirmation 8",
    "Affirmation 9",
    "Affirmation 10"
  ];

  final List<String> section3Questions = [
    "Affirmation 11",
    "Affirmation 12",
    "Affirmation 13",
    "Affirmation 14",
    "Affirmation 15"
  ];

  final List<String> section4Questions = [
    "Affirmation 16",
    "Affirmation 17",
    "Affirmation 18",
    "Affirmation 19",
    "Affirmation 20",
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

  void _showCompletionPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Questionnaire Terminé'),
          content: const Text('Merci d\'avoir complété le questionnaire !'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
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
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: "BricolageGrotesqueBold",
              fontSize: 22,
            ),
          ),
        ),
        Expanded(child: _buildQuestionsSection(sectionNumber - 1)),

        if (_showError)
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
      child: Column(
        children: [
          for (int i = 0; i < allSections[sectionIndex].length; i++)
            Column(
              children: [
                SizedBox(height: 20),
                Text(allSections[sectionIndex][i],
                    style: TextStyle(fontFamily: "Nunito", fontSize: 18)),
                SizedBox(height: 10),
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
                    Text("D'accord"),
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
                    Text("Pas d'accord"),
                  ],
                ),
              ],
            ),
          SizedBox(height: 40),
        ],
      ),
    );
  }
}
