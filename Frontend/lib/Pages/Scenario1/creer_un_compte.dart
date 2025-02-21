import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart'; //validation du format des emails

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
  final TextEditingController _confirmPasswordController = TextEditingController();


  //Variables pour valider les différents champs de saisie
  bool _acceptTerms = false;
  bool _isUsernameValid = false;
  bool _isEmailValid = false;
  bool _isPhoneValid = false;
  bool _isDobValid = false; 
  bool _isPasswordValid = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  //Expressions régulières pour valider les variables
  final RegExp _usernameRegExp = RegExp(r'^[a-zA-Z0-9_]{3,}$'); 
  final RegExp _phoneRegExp = RegExp(r'^\d{10}$');
  final RegExp _passwordRegExp = RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( //Header 
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
        backgroundColor:
            Colors.white, 
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            color: Colors.black, 
            thickness: 1,
            height: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(//possibilité de scroller l'écran
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
            const SizedBox(height: 20)
          ],
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
              border:
                  Border.all(color: const Color(0xFFEDEDED)),
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
                  _isEmailValid = EmailValidator.validate(value); //vérification et validation 
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
                initialDate: DateTime.now().subtract(const Duration(days: 365 * 15)), // Par défaut 15 ans en arrière
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
                  _isDobValid = age >= 15; //utilisateur minimum 15 ans
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
              _isDobValid ? '' : 'Vous devez avoir au moins 15 ans',
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
                suffixIcon: IconButton( //icône visibilité mot de passe 
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
                  _isPasswordValid = _passwordRegExp.hasMatch(value); //vérification format mot de passe
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
                  icon: Icon( //icône affichage du mot de passe
                      _isConfirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey),
                  onPressed: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible; //rendre le mot de passe visible
                    });
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {}); // Rafraîchir pour la validation en temps réel
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

  //Bouton inscription
  Widget _buildSignupButton() {
    return ElevatedButton(
      onPressed: (_acceptTerms && _isEmailValid)
          ? () => Navigator.pushNamed(context, '/questionnaire')
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
          child: const Text('Inscription',
              style: TextStyle(
                  fontSize: 15, fontFamily: 'Nunito', color: Colors.white)),
        ),
      ),
    );
  }
}
