import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; // Requêtes HTTP
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Stockage sécurisé
import 'package:logger/logger.dart';
import 'package:email_validator/email_validator.dart';

class CreerUnCompte extends StatefulWidget {
  const CreerUnCompte({Key? key}) : super(key: key);

  @override
  _CreerUnCompteState createState() => _CreerUnCompteState();
}

class _CreerUnCompteState extends State<CreerUnCompte> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Dio _dio = Dio(); // Client HTTP
  final Logger _logger = Logger(); // Logger pour debug

  //Variables pour valider les différents champs de saisie
  bool _acceptTerms = false;
  bool _isUsernameValid = true;
  bool _isEmailValid = true;
  bool _isPhoneValid = true;
  bool _isDobValid = true;
  bool _isPasswordValid = true;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  //Expressions régulières pour valider les variables
  final RegExp _usernameRegExp = RegExp(r'^[a-zA-ZÀ-ÖØ-öø-ÿ0-9_]{3,}$');
  final RegExp _phoneRegExp = RegExp(r'^\d{10}$');
  final RegExp _passwordRegExp =
      RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');

  bool _loading = false; // Indicateur de chargement

  //vérification de la validité du formulaire, chaque champ doit être rempli correctement
  bool _isFormValid() {
    return _acceptTerms &&
        _isUsernameValid &&
        _isEmailValid &&
        _isPhoneValid &&
        _isDobValid &&
        _isPasswordValid &&
        _passwordController.text == _confirmPasswordController.text &&
        _usernameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _dobController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty;
  }

  Future<void> _register() async {
    setState(() {
      _loading = true;
    });

    // Correction du format de la date (JJ/MM/AAAA → AAAA-MM-JJ)
    String formattedDate = _dobController.text.trim();
    List<String> parts = formattedDate.split('/');
    if (parts.length == 3) {
      formattedDate = "${parts[2]}-${parts[1]}-${parts[0]}";
    }

    // Correction des noms des variables pour correspondre au backend
    Map<String, dynamic> requestData = {
      "nom_utilisateur": _usernameController.text.trim(),
      "email": _emailController.text.trim(),
      "telephone": _phoneController.text.trim(),
      "mot_de_passe": _passwordController.text,
      "date_naissance": formattedDate,
    };

    _logger.i(
        "Requête envoyée par Flutter: $requestData"); // Log des données envoyées

    try {
      Response response = await _dio.post(
        'http://localhost:8080/auth/register',
        options: Options(contentType: Headers.jsonContentType),
        data: requestData,
      );

      _logger.i("Réponse API: ${response.data}");

      if (response.data.containsKey('message')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inscription réussie !')),
        );
        _showCoachSelectionPopup(); // Affichage popup choix du coach
      }
    } on DioError catch (e) {
      _logger.e("Erreur API: ${e.response?.data}");

      if (e.response?.data.containsKey('message')) {
        setState(() {});
      } else {
        setState(() {});
      }
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  //Pop-up choix du coach
  void _showCoachSelectionPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: BorderSide(color: Color(0xFF9381FF), width: 2),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                //Icon coach
                'images/coach_popup.png',
                height: 80,
              ),
              SizedBox(height: 5),
              Text(
                "Voulez-vous choisir votre coach?",
                style: TextStyle(
                    fontFamily: 'NunitoBold',
                    fontSize: 18,
                    color: Color(0xFF2F2F2F)),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                "Répondez à un court questionnaire afin de personnaliser votre coach!",
                style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    color: Color(0xFF2F2F2F)),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushNamed(context, '/questionnaire');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    backgroundColor: Color(0xFF9381FF),
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text(
                    'Choisir mon coach',
                    style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14,
                        color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 13),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushNamed(context, '/accueil');
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    side: BorderSide(color: Colors.black.withAlpha(128)),
                    backgroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text(
                    'Plus tard',
                    style: TextStyle(
                        fontFamily: 'NunitoBold',
                        fontSize: 14,
                        color: Color(0xFF2F2F2F)),
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
      appBar: AppBar(
        //Header
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushNamed(context, '/se_connecter'),
        ),
        title: const Text(
          'Inscription',
          style: TextStyle(fontFamily: 'BricolageGrotesqueBold', fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            color: Colors.black,
            thickness: 1,
            height: 1,
          ),
        ),
      ),
      body: AbsorbPointer(
        //pas d'interactions possibles pendant le chargement
        absorbing: _loading,
        child: SingleChildScrollView(
          //possibilité de scroller l'écran
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildUsernameField(),
              _buildEmailField(),
              _buildPhoneField(),
              _buildDobField(),
              _buildPasswordField(),
              _buildConfirmPasswordField(),
              _buildTermsCheckbox(),
              const SizedBox(height: 20),
              _buildSignupButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  //Saisie du nom d'utilisateur
  Widget _buildUsernameField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nom d\'Utilisateur',
            style: TextStyle(
                fontSize: 13, fontFamily: 'Nunito', color: Color(0xFF666666)),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFEDEDED)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _usernameController,
              style: const TextStyle(
                  fontFamily: 'Nunito', fontSize: 15, color: Color(0xFF666666)),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: (value) {
                setState(() {
                  _isUsernameValid = _usernameRegExp.hasMatch(value);
                  _isFormValid();
                });
              },
            ),
          ),
          // Message d'erreur si nom invalide
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 5),
            child: Text(
              _isUsernameValid
                  ? '' // Pas de message si valide
                  : 'Seuls lettres, chiffres et _ sont autorisés (min. 3 caractères)',
              style: const TextStyle(
                  fontSize: 12, fontFamily: 'Nunito', color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  //Saisie du mail
  Widget _buildEmailField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Email',
              style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Nunito',
                  color: Color(0xFF666666))),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Color(0xFFEDEDED)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _emailController,
              style: const TextStyle(
                  fontFamily: 'Nunito', fontSize: 15, color: Color(0xFF666666)),
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: (value) {
                setState(() {
                  _isEmailValid = EmailValidator.validate(
                      value); //vérification et validation
                  _isFormValid();
                });
              },
            ),
          ),
          // Message d'erreur affiché si invalide
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 5),
            child: Text(
              _isEmailValid ? '' : 'Email invalide',
              style: const TextStyle(
                  fontSize: 12, fontFamily: 'Nunito', color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // Saisie du numéro de téléphone
  Widget _buildPhoneField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Téléphone',
              style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Nunito',
                  color: Color(0xFF666666))),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Color(0xFFEDEDED)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(
                  fontFamily: 'Nunito', fontSize: 13, color: Color(0xFF666666)),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: (value) {
                setState(() {
                  _isPhoneValid = _phoneRegExp.hasMatch(value);
                  _isFormValid();
                });
              },
            ),
          ),
          // Message d'erreur
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 5),
            child: Text(
              _isPhoneValid
                  ? ''
                  : 'Numéro invalide : doit contenir 10 chiffres',
              style: const TextStyle(
                  fontSize: 12, fontFamily: 'Nunito', color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  //Saisie de la date de naissance
  Widget _buildDobField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Date de Naissance',
              style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Nunito',
                  color: Color(0xFF666666))),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now().subtract(const Duration(
                    days: 365 * 13)), // Par défaut 15 ans en arrière
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              //Vérification de la date de naissance
              if (pickedDate != null) {
                setState(() {
                  _dobController.text =
                      "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";

                  int age = DateTime.now().year - pickedDate.year;
                  if (DateTime.now().month < pickedDate.month ||
                      (DateTime.now().month == pickedDate.month &&
                          DateTime.now().day < pickedDate.day)) {
                    age--;
                  }
                  _isDobValid = age >= 13; //utilisateur minimum 13 ans
                  _isFormValid();
                });
              }
            },
            child: AbsorbPointer(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Color(0xFFEDEDED)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _dobController,
                  keyboardType: TextInputType.none, // Désactive le clavier
                  style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13,
                      color: Color(0xFF666666)),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                    suffixIcon: Icon(Icons.calendar_today,
                        color: Colors.grey), // Icône calendrier
                  ),
                ),
              ),
            ),
          ),
          // Message d'erreur
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 5),
            child: Text(
              _isDobValid ? '' : 'Vous devez avoir au moins 13 ans',
              style: const TextStyle(
                  fontSize: 12, fontFamily: 'Nunito', color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  //Saisie mot de passe
  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Mot de Passe',
              style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Nunito',
                  color: Color(0xFF666666))),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Color(0xFFEDEDED)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              style: const TextStyle(
                  fontFamily: 'Nunito', fontSize: 13, color: Color(0xFF666666)),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                suffixIcon: IconButton(
                  //icône visibilité mot de passe
                  icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _isPasswordValid = _passwordRegExp
                      .hasMatch(value); //vérification format mot de passe
                  _isFormValid();
                });
              },
            ),
          ),
          // Message d'erreur
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 5),
            child: Text(
              _isPasswordValid
                  ? ''
                  : 'Min. 8 caractères, 1 majuscule, 1 chiffre, 1 caractère spécial',
              style: const TextStyle(
                  fontSize: 12, fontFamily: 'Nunito', color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  //Saisie confirmation du mot de passe
  Widget _buildConfirmPasswordField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Confirmation du Mot de Passe',
              style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Nunito',
                  color: Color(0xFF666666))),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Color(0xFFEDEDED)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _confirmPasswordController,
              obscureText: !_isConfirmPasswordVisible,
              style: const TextStyle(
                  fontFamily: 'Nunito', fontSize: 13, color: Color(0xFF666666)),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                suffixIcon: IconButton(
                  icon: Icon(
                      //icône affichage du mot de passe
                      _isConfirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey),
                  onPressed: () {
                    setState(() {
                      _isConfirmPasswordVisible =
                          !_isConfirmPasswordVisible; //rendre le mot de passe visible
                    });
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _isFormValid();
                }); // Rafraîchir pour la validation en temps réel
              },
            ),
          ),
          // Vérification de la correspondance des mots de passe
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 5),
            child: Text(
              _confirmPasswordController.text.isEmpty ||
                      _passwordController.text ==
                          _confirmPasswordController.text
                  ? ''
                  : 'Les mots de passe ne correspondent pas',
              style: const TextStyle(
                  fontSize: 12, fontFamily: 'Nunito', color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  //Case à cocher conditions d'utilisation
  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _acceptTerms,
          onChanged: (bool? value) => setState(() => _acceptTerms = value!),
          activeColor: const Color(0xFF9381FF),
          checkColor: Colors.white,
        ),
        const Expanded(
          child: Text("J'accepte les conditions d'utilisation",
              style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Nunito',
                  color: Color(0xFF666666))),
        ),
      ],
    );
  }

  // Bouton inscription
  Widget _buildSignupButton() {
    return ElevatedButton(
      onPressed:
          (_isFormValid() && //bouton cliquable uniquement si le formulaire est rempli correctement
                  !_loading) //pour éviter double clic
              ? _register //fonction d'inscription
              : null,
      style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero, backgroundColor: Colors.transparent),
      child: Ink(
        decoration: BoxDecoration(
          gradient: (_acceptTerms && _isEmailValid)
              ? const LinearGradient(
                  colors: [Color(0xFFB9ADFF), Color(0xFF9381FF)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight)
              : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 130),
          child: _loading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Inscription',
                  style: TextStyle(
                      fontSize: 15, fontFamily: 'Nunito', color: Colors.white)),
        ),
      ),
    );
  }
}
