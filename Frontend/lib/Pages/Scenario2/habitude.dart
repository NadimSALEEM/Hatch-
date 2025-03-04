import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class Habitude extends StatefulWidget {
  const Habitude({Key? key}) : super(key: key);

  @override
  _HabitudeState createState() => _HabitudeState();
}

class _HabitudeState extends State<Habitude> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFfcfcff),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHabitCard(),
            const SizedBox(height: 20),
            _buildNotesSection(),
            const SizedBox(height: 20),
            _buildProgressSection(),
            const SizedBox(height: 20),
            _buildObjectivesSection(),
            const SizedBox(height: 20),
            _buildResourcesSection(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF2F2F2F)),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Faire du sport régulièrement',
        style: TextStyle(fontSize: 18, fontFamily: 'NunitoBold', color: Color(0xFF2F2F2F)),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings, color: Color(0xFF2F2F2F)),
          onPressed: () {},
        ),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(color: Color(0xFFE0E0E0), thickness: 1, height: 1),
      ),
    );
  }

Widget _buildHabitCard() {
  return Stack(
    children: [
      Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        color: Color(0xFFE0E4C7),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image du dragon
              Image.asset(
                'images/Habitude/dragon1.png',
                height: 120,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10),

              // Informations du dragon
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Midgardsormr',
                    style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'NunitoBold',
                        color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4.0),
                  const Text(
                    'Jeune dragon',
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'NunitoSemiBold',
                        color: Colors.orange),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Tags en bas
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTag('gym'),
                  _buildTag('sport'),
                ],
              ),
            ],
          ),
        ),
      ),
      
      // Tag de priorité en haut à droite
      Positioned(
        top: 10,
        right: 10,
        child: _buildPriorityTag('moyenne'),
      ),
    ],
  );
}

Widget _buildTag(String label, {bool isPrimary = false}) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: isPrimary ? Colors.orange.shade200 : Colors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontFamily: 'Nunito',
        color: isPrimary ? Colors.black : Colors.black54,
      ),
      textAlign: TextAlign.center,
    ),
  );
}

Widget _buildPriorityTag(String label) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF2E0),
      borderRadius: BorderRadius.circular(7),
      border: Border.all(color: const Color(0xFFFFD9A5), width: 1),
    ),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontFamily: 'Nunito',
        color: Colors.black,
      ),
      textAlign: TextAlign.center,
    ),
  );
}


Widget _buildNotesSection() {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    elevation: 4,
    shadowColor: Colors.grey.shade300,
    color: Color(0xFFFFFFFF),
    child: ListTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notes',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'NunitoBold',
              color: Color(0xFF2F2F2F),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Écrivez vos nouvelles idées, nouveaux notes et plus',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Nunito',
              color: Color(0xFF666666),
            ),
          ),
        ],
      ),
      trailing: const Icon(Icons.edit, color: Color(0xFF9381FF)),
      onTap: () {},
    ),
  );
}


Widget _buildProgressSection() {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    elevation: 4,
    shadowColor: Colors.grey.shade300,
    color: Color(0xFFFFFFFF),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progrès',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'NunitoBold',
                  color: Color(0xFF2F2F2F),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/progres_habitude');
                },
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      colors: [Color(0xFFB9ADFF), Color(0xFF9381FF)],
                    ).createShader(bounds);
                  },
                  child: const Text(
                    'Tout',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'NunitoBold',
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              CircularPercentIndicator(
                radius: 50.0,
                lineWidth: 10.0,
                percent: 0.6,
                center: const Text(
                  '60%',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Nunito',
                    color: Color(0xFF2F2F2F),
                  ),
                ),
                linearGradient: const LinearGradient(
                  colors: [Color(0xFFB9ADFF), Color(0xFF9381FF)],
                ),
                backgroundColor: Color(0xFFE0E0E0),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Résultats par rapport à vos objectifs de durée',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Nunito',
                        color: Color(0xFF2F2F2F),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: const Color(0xFF9381FF),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: const LinearProgressIndicator(
                          value: 0.5,
                          backgroundColor: Color(0xFFE0E0E0),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      '5/10 Jours réussis',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Nunito',
                        color: Color(0xFF9381FF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}


Widget _buildObjectivesSection() {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 4,
    shadowColor: Colors.grey.shade300,
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Objectifs',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'NunitoBold',
                  color: Color(0xFF2F2F2F),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'Tout',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'NunitoBold',
                    color: Color(0xFF9381FF),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Column(
            children: List.generate(3, (index) {
              double progressValue = 0.3 + (index * 0.2);
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFFF3F2FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Objectif ${index + 1}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'NunitoBold',
                            color: Color(0xFF2F2F2F),
                          ),
                        ),
                        Icon(
                          Icons.edit,
                          color: Color(0xFF9381FF),
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
                          '${(index + 1) * 5} / 30 Jours',
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'Nunito',
                            color: Color(0xFF2F2F2F),
                          ),
                        ),
                        Text(
                          'Tous les jours',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'NunitoBold',
                            color: Color(0xFF9381FF),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          // Bouton avec LinearGradient
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: const LinearGradient(
                colors: [Color(0xFFB9ADFF), Color(0xFF9381FF)],
              ),
            ),
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Ajouter un objectif',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'NunitoBold',
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}



  Widget _buildResourcesSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 4,
      shadowColor: Colors.grey.shade300,
      color: Color(0xFFFFFFFF),
      child: ListTile(
        title: const Text('Ressources', style: TextStyle(fontSize: 18, fontFamily: 'NunitoBold', color: Color(0xFF2F2F2F))),
        subtitle: const Text('Rechercher des articles liés à votre habitude', style: TextStyle(fontSize: 14, fontFamily: 'Nunito', color: Color(0xFF666666))),
        trailing: const Icon(Icons.search, color: Color(0xFF9381FF)),
        onTap: () {},
      ),
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
      selectedItemColor: const Color(0xFF9381FF),
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