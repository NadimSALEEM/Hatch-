import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:email_validator/email_validator.dart';

class Profil extends StatefulWidget {
  const Profil({Key? key}) : super(key: key);

  @override
  _ProfilState createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  final _storage = const FlutterSecureStorage();
  final Dio _dio = Dio();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String? _errorMessage;
  final Map<String, String> _errorMessages = {};

  // Contrôleurs pour les champs modifiables
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _dateNaissanceController = TextEditingController();
  final TextEditingController _coachController = TextEditingController();

  // Valeurs précédentes des champs
  String _previousNom = '';
  String _previousBio = '';
  String _previousEmail = '';
  String _previousTelephone = '';
  String _previousDateNaissance = '';
  String _previousCoach = '';

  // Validation
  bool _isEmailValid = true;
  bool _isPhoneValid = true;
  bool _isBioValid = true;
  bool _isUsernameValid = true;
  bool _isBirthDateValid = true;
  final RegExp _phoneRegExp = RegExp(r'^\d{10}$');
  final RegExp _usernameRegExp = RegExp(r'^[a-zA-Z0-9_]{3,}$');

  // Gestion du champ en cours d'édition
  String? _editingField;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  // Récupère les données de l'utilisateur
  Future<void> _getUserData() async {
    try {
      String? token = await _storage.read(key: "jwt_token");
      if (token == null) {
        if (mounted) {
          setState(() {
            _errorMessage = "Utilisateur non authentifié";
            _isLoading = false;
          });
        }
        return;
      }

      final response = await _dio.get(
        'http://localhost:8080/users/me',
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _userData = response.data;
            _isLoading = false;
          });

          _nomController.text = _userData?['nom_utilisateur'] ?? '';
          _bioController.text = _userData?['biographie'] ?? '';
          _emailController.text = _userData?['email'] ?? '';
          _telephoneController.text = _userData?['telephone'] ?? '';
          _dateNaissanceController.text = _userData?['date_naissance'] ?? '';
          _coachController.text = _userData?['coach_assigne'] ?? '';
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = "Erreur de récupération des données";
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Impossible de charger les informations";
          _isLoading = false;
        });
      }
    }
  }

  // Met à jour un seul champ de l'utilisateur
  Future<void> _updateSingleField(String fieldName, dynamic value) async {
    try {
      String? token = await _storage.read(key: "jwt_token");
      if (token == null) return;

      final response = await _dio.put(
        'http://localhost:8080/users/me/update',
        options: Options(headers: {"Authorization": "Bearer $token"}),
        data: {
          fieldName: value, // Envoie uniquement le champ spécifié
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _userData = response.data; // Met à jour les données utilisateur
          _errorMessages.remove(fieldName); // Supprime l'erreur si la mise à jour réussit
          _editingField = null; // Quitte le mode édition uniquement si la mise à jour réussit
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Champ mis à jour avec succès !', style: TextStyle(color: Color(0xFF2F2F2F))),
            backgroundColor: Colors.white,
          ),
        );
      }
    } catch (e) {
      if (e is DioError) {
        // Extrait le message d'erreur de la clé "detail"
        final errorDetail = e.response?.data['detail'];
        final errorMessage = errorDetail is Map ? errorDetail['message'] : errorDetail ?? "Erreur inconnue";
        setState(() {
          _errorMessages[fieldName] = errorMessage; // Stocke le message d'erreur
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage, style: TextStyle(color: Color(0xFF2F2F2F))),
            backgroundColor: Colors.white,
          ),
        );
      } else {
        setState(() {
          _errorMessages[fieldName] = "Erreur lors de la mise à jour";
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la mise à jour', style: TextStyle(color: Color(0xFF2F2F2F))),
            backgroundColor: Colors.white,
          ),
        );
      }
    }
  }

  // Supprime le compte de l'utilisateur
  Future<void> _deleteAccount() async {
    try {
      String? token = await _storage.read(key: "jwt_token");
      if (token == null) return;

      final response = await _dio.delete(
        'http://localhost:8080/users/me/supprimer',
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        Navigator.of(context).pushReplacementNamed('/login');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Compte supprimé avec succès !', style: TextStyle(color: Color(0xFF2F2F2F))),
            backgroundColor: Colors.white,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Échec de la suppression du compte', style: TextStyle(color: Color(0xFF2F2F2F))),
          backgroundColor: Colors.white,
        ),
      );
    }
  }

  // Validation du nom d'utilisateur
  void _validateUsername(String value) {
    setState(() {
      _isUsernameValid = _usernameRegExp.hasMatch(value);
      if (!_isUsernameValid) {
        _errorMessages['nom_utilisateur'] = 'Seuls lettres, chiffres et _ sont autorisés (min. 3 caractères)';
      } else {
        _errorMessages.remove('nom_utilisateur');
      }
    });
  }

  // Validation de l'email
  void _validateEmail(String value) {
    setState(() {
      _isEmailValid = EmailValidator.validate(value);
      if (!_isEmailValid) {
        _errorMessages['email'] = 'Email invalide';
      } else {
        _errorMessages.remove('email');
      }
    });
  }

  // Validation du numéro de téléphone
  void _validatePhone(String value) {
    setState(() {
      _isPhoneValid = _phoneRegExp.hasMatch(value);
      if (!_isPhoneValid) {
        _errorMessages['telephone'] = 'Numéro invalide : doit contenir 10 chiffres';
      } else {
        _errorMessages.remove('telephone');
      }
    });
  }

  // Validation de la date de naissance
  void _validateBirthDate(String value) {
    setState(() {
      _isBirthDateValid = _isValidDate(value) && _isOver13(value);
      if (!_isBirthDateValid) {
        _errorMessages['date_naissance'] = 'Vous devez avoir au moins 13 ans';
      } else {
        _errorMessages.remove('date_naissance');
      }
    });
  }

  // Vérifie si l'utilisateur a plus de 13 ans
  bool _isOver13(String date) {
    try {
      DateTime birthDate = DateTime.parse(date);
      DateTime now = DateTime.now();
      int age = now.year - birthDate.year;
      if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
        age--;
      }
      return age >= 13;
    } catch (e) {
      return false;
    }
  }

  // Annule l'édition d'un champ
  void _cancelEdit(String fieldName) {
    setState(() {
      _editingField = null;
      switch (fieldName) {
        case 'nom_utilisateur':
          _nomController.text = _previousNom;
          break;
        case 'biographie':
          _bioController.text = _previousBio;
          break;
        case 'email':
          _emailController.text = _previousEmail;
          break;
        case 'telephone':
          _telephoneController.text = _previousTelephone;
          break;
        case 'date_naissance':
          _dateNaissanceController.text = _previousDateNaissance;
          break;
        case 'coach_assigne':
          _coachController.text = _previousCoach;
          break;
      }
    });
  }

  // Vérifie si une date est valide
  bool _isValidDate(String date) {
    try {
      DateTime.parse(date);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Affiche une popup de confirmation pour la suppression du compte
  void _showDeleteAccountPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/corbeille_suppression.png', width: 75, height: 75),
              const Text('Voulez-vous vraiment supprimer votre compte ?', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontFamily: 'NunitoBold')),
              const SizedBox(height: 10),
              _buildGradientButton(text: 'Annuler', onTap: () => Navigator.of(context).pop(), enabled: true),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  _deleteAccount();
                  Navigator.pushNamed(context, '/se_connecter');
                },
                child: const Text('Supprimer mon compte', style: TextStyle(fontSize: 14, fontFamily: 'NunitoBold', color: Colors.red)),
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
      backgroundColor: Color(0xFFfcfcff),
      appBar: _buildAppBar(context),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildProfileHeader(),
                      const SizedBox(height: 20),
                      _buildEditableField(
                        label: 'Nom d\'utilisateur',
                        controller: _nomController,
                        validate: _validateUsername,
                        fieldName: 'nom_utilisateur',
                      ),
                      _buildEditableTextArea(
                        label: 'Biographie',
                        controller: _bioController,
                        fieldName: 'biographie',
                      ),
                      _buildEditableField(
                        label: 'Email',
                        controller: _emailController,
                        validate: _validateEmail,
                        fieldName: 'email',
                      ),
                      _buildEditableField(
                        label: 'Téléphone',
                        controller: _telephoneController,
                        validate: _validatePhone,
                        fieldName: 'telephone',
                      ),
                      _buildEditableField(
                        label: 'Date de naissance',
                        controller: _dateNaissanceController,
                        validate: _validateBirthDate,
                        fieldName: 'date_naissance',
                      ),
                      _buildEditableField(
                        label: 'Coach Assigné',
                        controller: _coachController,
                        validate: (value) {}, // Fonction de validation vide
                        fieldName: 'coach_assigne',
                      ),
                      const SizedBox(height: 20),
                      _buildGradientButton(
                        text: 'Changer mot de passe',
                        onTap: () => Navigator.pushNamed(context, '/init_nouveau_mot_de_passe'),
                        enabled: true,
                      ),
                      const SizedBox(height: 20),
                      _buildGradientButton(
                        text: 'Supprimer mon compte',
                        onTap: () => _showDeleteAccountPopup(context),
                        enabled: true,
                        buttonColorStart: Color(0xFFfcfcff),
                        buttonColorEnd: Color(0xFFfcfcff),
                        textColor: Colors.red,
                      ),
                    ],
                  ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF2F2F2F)),
        onPressed: () => Navigator.pushReplacementNamed(context, '/accueil'),
      ),
      title: const Text('Profil', style: TextStyle(fontSize: 20, fontFamily: 'NunitoBold', color: Color(0xFF2F2F2F))),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(color: Color(0xFFE0E0E0), thickness: 1, height: 1),
      ),
    );
  }

  Widget _buildGradientButton({
    required String text,
    required VoidCallback onTap,
    bool enabled = true,
    Color? buttonColorStart, // Couleur de départ du dégradé
    Color? buttonColorEnd,   // Couleur de fin du dégradé
    Color? textColor,        // Couleur du texte
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: enabled
              ? LinearGradient(
                  colors: [
                    buttonColorStart ?? const Color(0xFFB9ADFF),
                    buttonColorEnd ?? const Color(0xFF9381FF),
                  ],
                )
              : LinearGradient(
                  colors: [Colors.grey[300]!, Colors.grey[400]!],
                ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 15,
            color: textColor ?? Colors.white, // Utilise la couleur du texte fournie ou blanc par défaut
          ),
        ),
      ),
    );
  }

  
  Widget _buildProfileHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: _userData?['photo_profil'] != null
              ? NetworkImage(_userData!['photo_profil'])
              : null,
          backgroundColor: Colors.grey[300],
          child: _userData?['photo_profil'] == null
              ? const Icon(Icons.person, size: 50, color: Colors.grey)
              : null,
        ),
        const SizedBox(height: 10),
        Text(
          _nomController.text,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2F2F2F)),
        ),
        const SizedBox(height: 5),
      ],
    );
  }

  // Construit un champ modifiable
  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required Function(String) validate,
    required String fieldName,
  }) {
    bool isEditing = _editingField == fieldName;
    String? errorMessage = _errorMessages[fieldName]; // Récupère le message d'erreur

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  readOnly: !isEditing,
                  onChanged: validate,
                  decoration: InputDecoration(
                    labelText: label,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    errorText: isEditing ? errorMessage : null, // Affiche le message d'erreur uniquement en mode édition
                  ),
                ),
              ),
              if (isEditing)
                IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.red, size: 28),
                  onPressed: () => _cancelEdit(fieldName),
                ),
              IconButton(
                icon: Icon(
                  isEditing ? Icons.check_circle : Icons.edit,
                  color: isEditing ? Colors.green : Color(0xFFAB96FF),
                  size: 28,
                ),
                onPressed: () {
                  if (isEditing) {
                    // Valider le champ avant de l'envoyer
                    if (_validateField(fieldName, controller.text)) {
                      _updateSingleField(fieldName, controller.text);
                    }
                  } else {
                    setState(() {
                      _previousNom = _nomController.text;
                      _previousBio = _bioController.text;
                      _previousEmail = _emailController.text;
                      _previousTelephone = _telephoneController.text;
                      _previousDateNaissance = _dateNaissanceController.text;
                      _previousCoach = _coachController.text;
                      _editingField = fieldName;
                    });
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Valide un champ spécifique
  bool _validateField(String fieldName, String value) {
    switch (fieldName) {
      case 'nom_utilisateur':
        _validateUsername(value);
        return _isUsernameValid;
      case 'email':
        _validateEmail(value);
        return _isEmailValid;
      case 'telephone':
        _validatePhone(value);
        return _isPhoneValid;
      case 'date_naissance':
        _validateBirthDate(value);
        return _isBirthDateValid;
      default:
        return true;
    }
  }

  // Construit une zone de texte modifiable
  Widget _buildEditableTextArea({
    required String label,
    required TextEditingController controller,
    required String fieldName,
  }) {
    bool isEditing = _editingField == fieldName;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              readOnly: !isEditing,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: label,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          IconButton(
            icon: Icon(isEditing ? Icons.check : Icons.edit,
            color: isEditing ? Colors.green : Color(0xFFAB96FF)
            ),
            onPressed: () {
              if (isEditing) {
                // Envoyer la mise à jour uniquement si le champ a été modifié
                if (controller.text != _userData?[fieldName]) {
                  _updateSingleField(fieldName, controller.text);
                }
                setState(() {
                  _editingField = null; // Quitte le mode édition
                });
              } else {
                setState(() {
                  _editingField = fieldName; // Active le mode édition pour ce champ
                });
              }
            },
          ),
        ],
      ),
    );
  }
}