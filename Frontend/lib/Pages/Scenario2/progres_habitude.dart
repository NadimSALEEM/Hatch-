import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ProgressHabitude extends StatefulWidget {
  const ProgressHabitude({Key? key}) : super(key: key);

  @override
  _ProgressHabitudeState createState() => _ProgressHabitudeState();
}

class _ProgressHabitudeState extends State<ProgressHabitude> {
  
List<bool> _selectedPeriod = [true, false, false]; // Index : [Semaine, Mois, Année]


@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFfcfcff),
    appBar: _buildAppBar(),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildContainer(_buildStatsContainer()),
          const SizedBox(height: 16),
          
          // Section pour le BarChart
          _buildContainer(_buildBarChartSection()), 
          const SizedBox(height: 16), 
          
          // Section pour le LineChart
          _buildContainer(_buildLineChartSection()), 
          const SizedBox(height: 16),

          // Section du calendrier
          _buildContainer(_buildCalendarSection()), 
        ],
      ),
    ),
    bottomNavigationBar: _buildBottomNavigationBar(),
  );
}


  Widget _buildContainer(Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration(),
      child: child,
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF2F2F2F)),
        onPressed: () => Navigator.pop(context),
      ),
      elevation: 0,
      centerTitle: true,
      title: const Text(
        "Progrès",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2F2F2F)),
      ),
    );
  }

  Widget _buildStatsContainer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Progrès", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2F2F2F))),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildStatCard("15 jours", "Durée de la chaîne")),
            const SizedBox(width: 10),
            Expanded(child: _buildStatCard("60 %", "Avancée")),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildStatCard("2", "Objectifs complétés")),
            const SizedBox(width: 10),
            Expanded(child: _buildStatCard("11", "Jours parfaits")),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Color(0xFFAB96FF).withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Color(0xFFAB96FF).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFAB96FF))),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF2F2F2F))),
        ],
      ),
    );
  }


Widget _buildGraphContainers() {
  return Column(
    children: [
      // 📊 Container pour le BarChart (affecté par les boutons)
      Container(
        padding: const EdgeInsets.all(16),
        decoration: _boxDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Objectifs complétés", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildGraphForPeriod(), // Graphique qui change avec le bouton
          ],
        ),
      ),
      const SizedBox(height: 16), // Espacement entre les containers

      // 📈 Container pour le LineChart (affiché en permanence)
      Container(
        padding: const EdgeInsets.all(16),
        decoration: _boxDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Progression au fil du temps", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildLineChart(), // Graphique linéaire qui reste fixe
          ],
        ),
      ),
    ],
  );
}

Widget _buildBarChartSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildPeriodSelector(), // Sélecteur de période
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: _boxDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Objectifs complétés",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 220,
              child: _buildGraphForPeriod(), // ✅ Affiche TOUJOURS un BarChart
            ),
          ],
        ),
      ),
    ],
  );
}




Widget _buildLineChartSection() {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: _boxDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Progression au fil du temps",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 220,
          child: _buildLineChart(), // Graphique LineChart
        ),
      ],
    ),
  );
}


// Bouton de sélection pour changer la période
Widget _buildPeriodSelector() {
  List<String> periods = ["Cette semaine", "Ce mois", "Cette année"];

  return SingleChildScrollView(
    scrollDirection: Axis.horizontal, // Permet de scroller si dépassement
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ToggleButtons(
          borderRadius: BorderRadius.circular(10),
          borderWidth: 0, // Supprime la bordure
          selectedBorderColor: Colors.transparent,
          fillColor: const Color(0xFFAB96FF),
          selectedColor: Colors.white,
          color: const Color(0xFFAB96FF),
          constraints: const BoxConstraints(
            minHeight: 40, // Garde la hauteur constante
          ),
          isSelected: _selectedPeriod,
          onPressed: (index) {
            setState(() {
              for (int i = 0; i < _selectedPeriod.length; i++) {
                _selectedPeriod[i] = (i == index);
              }
            });
          },
          children: periods.map((e) {
            int index = periods.indexOf(e);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12), // Espacement entre les boutons
              child: Text(
                e,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: _selectedPeriod[index] ? Colors.white : const Color(0xFFAB96FF),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    ),
  );
}



// Affiche le graphique en fonction de la période sélectionnée
Widget _buildGraphForPeriod() {
  if (_selectedPeriod[0]) {
    return _buildBarChart(); // ✅ BarChart pour la semaine
  } else if (_selectedPeriod[1]) {
    return _buildMonthlyBarChart(); // ✅ BarChart pour le mois
  } else {
    return _buildYearlyBarChart(); // ✅ BarChart pour l'année
  }
}


// 📊 Graphique pour la SEMAINE
Widget _buildBarChart() {
  return SizedBox(
    height: 200,
    child: BarChart(
      BarChartData(
        barGroups: List.generate(7, (i) => BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: (i * 1.5 + 4).toDouble(),
              width: 16,
              color: const Color(0xFFAB96FF),
              borderRadius: BorderRadius.circular(4),
            )
          ],
        )),
        titlesData: FlTitlesData( // ✅ Correction ici
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                List<String> days = ["Lun", "Mar", "Mer", "Jeu", "Ven", "Sam", "Dim"];
                if (value.toInt() >= 0 && value.toInt() < days.length) {
                  return Text(days[value.toInt()], style: const TextStyle(fontSize: 12));
                }
                return const Text("");
              },
            ),
          ),
        ),
      ),
    ),
  );
}

// Graphique pour le MOIS
Widget _buildMonthlyBarChart() {
  List<double> weeklyData = [0, 0, 0, 0]; // 4 semaines

  // Génération des données pour chaque semaine (somme des jours)
  for (int i = 0; i < 30; i++) {
    int weekIndex = (i ~/ 7).clamp(0, 3); // Limite l'index de 0 à 3
    weeklyData[weekIndex] += (i % 10 + 2) * 1.5; // Simule les valeurs
  }

  return SizedBox(
    height: 200,
    child: BarChart(
      BarChartData(
        barGroups: List.generate(4, (i) => BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: weeklyData[i], // Affiche la somme des jours de la semaine
              width: 16,
              color: const Color(0xFFAB96FF),
              borderRadius: BorderRadius.circular(4),
            )
          ],
        )),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                List<String> weeks = ["Semaine 1", "Semaine 2", "Semaine 3", "Semaine 4"];
                if (value.toInt() >= 0 && value.toInt() < weeks.length) {
                  return Text(weeks[value.toInt()], style: const TextStyle(fontSize: 12));
                }
                return const Text("");
              },
            ),
          ),
        ),
      ),
    ),
  );
}



// Graphique pour l’ANNÉE
Widget _buildYearlyBarChart() {
  return SizedBox(
    height: 200,
    child: BarChart(
      BarChartData(
        barGroups: List.generate(12, (i) => BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: (i % 4 + 2) * 4.0.toDouble(),
              width: 16,
              color: const Color(0xFFAB96FF),
              borderRadius: BorderRadius.circular(4),
            )
          ],
        )),
        titlesData: FlTitlesData( // ✅ Correction ici
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTitlesWidget: (value, _) {
                List<String> months = ["J", "F", "M", "A", "M", "J", "J", "A", "S", "O", "N", "D"];
                if (value.toInt() >= 0 && value.toInt() < months.length) {
                  return Text(months[value.toInt()], style: const TextStyle(fontSize: 12));
                }
                return const Text("");
              },
            ),
          ),
        ),
      ),
    ),
  );
}


Widget _buildLineChart() {
  return SizedBox(
    height: 200,
    child: LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: const [FlSpot(0, 60), FlSpot(1, 80), FlSpot(2, 40), FlSpot(3, 60), FlSpot(4, 20), FlSpot(5, 100)],
            isCurved: true,
            color: const Color(0xFFAB96FF),
            barWidth: 3,
            isStrokeCapRound: true,
          )
        ],
      ),
    ),
  );
}

DateTime _selectedMonth = DateTime.now(); // Mois sélectionné

List<String> _months = [
  "Janvier", "Février", "Mars", "Avril", "Mai", "Juin",
  "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"
];

int _selectedYear = DateTime.now().year; // Année sélectionnée

List<int> _completedDays = [1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 13, 14, 15]; // Jours complétés (exemple)


Widget _buildCalendarSection() {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: _boxDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCalendarHeader(), // Sélecteur de mois
        const SizedBox(height: 10),
        _buildCalendarGrid(), // Calendrier avec cercles progressifs
      ],
    ),
  );
}

Widget _buildCalendarHeader() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      const Text(
        "Statistiques du mois",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      GestureDetector(
        onTap: _selectMonth, // Ouvre le DatePicker au clic
        child: Row(
          children: [
            Text(
              "${_getMonthName(_selectedMonth.month)} ${_selectedMonth.year}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFAB96FF),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Color(0xFFAB96FF)),
          ],
        ),
      ),
    ],
  );
}


// Fonction pour obtenir le nom du mois
String _getMonthName(int month) {
  List<String> months = [
    "Janvier", "Février", "Mars", "Avril", "Mai", "Juin",
    "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"
  ];
  return months[month - 1];
}

// Fonction pour sélectionner un mois
void _selectMonth() async {
  DateTime now = DateTime.now();
  DateTime initialDate = _selectedMonth;
  
  DateTime? picked = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: DateTime(now.year - 5, 1), // Permet de sélectionner un mois jusqu'à 5 ans en arrière
    lastDate: DateTime(now.year + 5, 12), // Permet de sélectionner un mois jusqu'à 5 ans en avant
    locale: const Locale("fr", "FR"), // Met le DatePicker en français
    builder: (context, child) {
      return Theme(
        data: ThemeData.light().copyWith(
          primaryColor: const Color(0xFFAB96FF),
          colorScheme: const ColorScheme.light(primary: Color(0xFFAB96FF)),
          buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
        ),
        child: child!,
      );
    },
  );

  if (picked != null) {
    setState(() {
      _selectedMonth = DateTime(picked.year, picked.month, 1); // Stocke uniquement mois & année
    });
  }
}


Widget _buildCalendarGrid() {
  int daysInMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
  int firstWeekday = DateTime(_selectedMonth.year, _selectedMonth.month, 1).weekday;

  List<Widget> days = [];

  // Jours vides avant le premier jour du mois
  for (int i = 0; i < firstWeekday - 1; i++) {
    days.add(Container());
  }

  // Ajoute les jours du mois
  for (int day = 1; day <= daysInMonth; day++) {
    bool isCompleted = _completedDays.contains(day);
    days.add(_buildCalendarDay(day, isCompleted));
  }

  return Column(
    children: [
      _buildWeekdayHeader(), // Jours de la semaine
      GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 7,
        children: days,
      ),
    ],
  );
}



// Entête des jours de la semaine
Widget _buildWeekdayHeader() {
  List<String> weekdays = ["lun.", "Mar.", "Mer.", "Jeu.", "Ven.", "Sam.", "Dim."];
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: weekdays.map((day) => Text(day, style: const TextStyle(fontWeight: FontWeight.bold))).toList(),
  );
}


Widget _buildCalendarDay(int day, bool isCompleted) {
  return Container(
    margin: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: isCompleted ? const Color(0xFFAB96FF) : Colors.grey.shade300, width: 2),
    ),
    child: Stack(
      alignment: Alignment.center,
      children: [
        // Cercle gris clair
        CircularProgressIndicator(
          value: isCompleted ? 0.75 : 0, // 75% de complétion
          strokeWidth: 4,
          backgroundColor: Colors.grey.shade300,
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFAB96FF)),
        ),
        // Texte du jour
        Text(
          "$day",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isCompleted ? const Color(0xFFAB96FF) : Colors.black,
          ),
        ),
      ],
    ),
  );
}


  int _selectedIndex = 0;

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