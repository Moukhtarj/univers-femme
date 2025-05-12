import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'VerifyOtpScreen.dart';
import 'home_screen.dart';
import '../config.dart';

class RegisterScreen extends StatefulWidget {
  final String selectedLanguage;
  final Map<String, Map<String, String>> translations;
  
  const RegisterScreen({
    super.key,
    required this.selectedLanguage,
    required this.translations,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  
  final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  
  final RegExp _passwordRegex = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$',
  );

  bool _isLoading = false;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final registrationData = {
          'first_name': _firstNameController.text,
          'last_name': _lastNameController.text,
          'phone_number': _phoneController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
          'role': 'utilisateur', // Default role
        };

        final response = await http.post(
          Uri.parse('${Config.apiBaseUrl}/api/register/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(registrationData),
        );

        if (response.statusCode == 200) {
          // OTP sent successfully, navigate to verify screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VerifyOtpScreen(
                phoneNumber: _phoneController.text,
                selectedLanguage: widget.selectedLanguage,
                translations: widget.translations,
                registrationData: registrationData,
              ),
            ),
          );
        } else {
          final error = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error['error'] ?? 'Registration failed')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network error: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  
    super.dispose();
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return widget.selectedLanguage == 'Arabic'
          ? 'هذا الحقل مطلوب'
          : widget.selectedLanguage == 'French'
              ? 'Ce champ est obligatoire'
              : 'This field is required';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return widget.selectedLanguage == 'Arabic'
          ? 'البريد الإلكتروني مطلوب'
          : widget.selectedLanguage == 'French'
              ? 'L\'email est requis'
              : 'Email is required';
    }
    if (!_emailRegex.hasMatch(value)) {
      return widget.selectedLanguage == 'Arabic'
          ? 'بريد إلكتروني غير صالح'
          : widget.selectedLanguage == 'French'
              ? 'Email invalide'
              : 'Invalid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return widget.selectedLanguage == 'Arabic'
          ? 'كلمة المرور مطلوبة'
          : widget.selectedLanguage == 'French'
              ? 'Le mot de passe est requis'
              : 'Password is required';
    }
    if (!_passwordRegex.hasMatch(value)) {
      return widget.selectedLanguage == 'Arabic'
          ? 'يجب أن تحتوي كلمة المرور على 8 أحرف على الأقل وتحتوي على حروف وأرقام'
          : widget.selectedLanguage == 'French'
              ? 'Le mot de passe doit contenir au moins 8 caractères avec des lettres et des chiffres'
              : 'Password must be at least 8 characters with letters and numbers';
    }
    return null;
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: keyboardType == TextInputType.phone
            ? const Icon(Icons.phone, color: Colors.white70)
            : keyboardType == TextInputType.emailAddress
                ? const Icon(Icons.email, color: Colors.white70)
                : const Icon(Icons.person, color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 192, 203, 1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Text(
                  widget.translations[widget.selectedLanguage]!['registerTitle']!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                // Informations personnelles
                _buildTextFormField(
                  controller: _firstNameController,
                  labelText: widget.translations[widget.selectedLanguage]!['firstName'] ?? 'First Name',
                  validator: (value) => _validateRequired(value, 'firstName'),
                ),
                const SizedBox(height: 15),
                _buildTextFormField(
                  controller: _lastNameController,
                  labelText: widget.translations[widget.selectedLanguage]!['lastName'] ?? 'Last Name',
                  validator: (value) => _validateRequired(value, 'lastName'),
                ),
                const SizedBox(height: 15),
                _buildTextFormField(
                  controller: _phoneController,
                  labelText: widget.translations[widget.selectedLanguage]!['phone'] ?? 'Phone',
                  keyboardType: TextInputType.phone,
                  validator: (value) => _validateRequired(value, 'phone'),
                ),
                const SizedBox(height: 15),
                _buildTextFormField(
                  controller: _emailController,
                  labelText: widget.translations[widget.selectedLanguage]!['email'] ?? 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 15),
                _buildTextFormField(
                  controller: _passwordController,
                  labelText: widget.translations[widget.selectedLanguage]!['password'] ?? 'Password',
                  obscureText: true,
                  validator: _validatePassword,
                ),
                const SizedBox(height: 20),
               
                const SizedBox(height: 30),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: _isLoading ? null : _register,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : Text(
                            widget.translations[widget.selectedLanguage]!['register']!,
                            style: const TextStyle(
                              color: Color.fromRGBO(255, 192, 203, 1),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}