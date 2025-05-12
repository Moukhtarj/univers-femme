import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'ChangePasswordScreen.dart';
import 'home_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class LoginScreen extends StatefulWidget {
  final String selectedLanguage;
  final Map<String, Map<String, String>> translations;
  
  const LoginScreen({
    super.key,
    required this.selectedLanguage,
    required this.translations,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  final RegExp _passwordRegex = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$',
  );

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _changeLanguage(String language) {
    setState(() {
      widget.translations['selectedLanguage'] = language as Map<String, String>;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 192, 203, 1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [],
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromRGBO(255, 192, 203, 1),
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ExpansionTile(
              title: Text(widget.translations[widget.selectedLanguage]!['language'] ?? 'Language'),
              children: [
                ListTile(
                  title: const Text('العربية'),
                  onTap: () => _changeLanguage('Arabic'),
                ),
                ListTile(
                  title: const Text('English'),
                  onTap: () => _changeLanguage('English'),
                ),
                ListTile(
                  title: const Text('Français'),
                  onTap: () => _changeLanguage('French'),
                ),
              ],
            ),
          ],
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
                  widget.translations[widget.selectedLanguage]!['loginTitle']!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: widget.translations[widget.selectedLanguage]!['username'] ?? 'Username',
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.person, color: Colors.white70),
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return widget.selectedLanguage == 'Arabic' 
                          ? 'اسم المستخدم مطلوب'
                          : widget.selectedLanguage == 'French'
                              ? 'Le nom d\'utilisateur est requis'
                              : 'Username is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: widget.translations[widget.selectedLanguage]!['password']!,
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.lock, color: Colors.white70),
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
                  validator: (value) {
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
                  },
                ),
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
                  // Update your login screen's onPressed handler
onPressed: () async {
  if (_formKey.currentState!.validate()) {
    try {
      final response = await ApiService().post('api/token/', {
        'phone_number': _usernameController.text,
        'password': _passwordController.text,
      });
      
      // Save token and user data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', response['access']);
      await prefs.setString('user', jsonEncode(response));
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Directionality(
            textDirection: widget.selectedLanguage == 'Arabic' 
                ? TextDirection.rtl 
                : TextDirection.ltr,
            child: ModernHomeScreen(
              selectedLanguage: widget.selectedLanguage,
              translations: widget.translations,
            ),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
},
                    child: Text(
                      widget.translations[widget.selectedLanguage]!['login']!,
                      style: const TextStyle(
                        color: Color.fromRGBO(255, 192, 203, 1),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangePasswordScreen(
          selectedLanguage: widget.selectedLanguage,
          translations: widget.translations,
        ),
      ),
    );
  },
  child: Text(
    widget.translations[widget.selectedLanguage]!['forgotPassword'] ?? 'Forgot Password?',
    style: TextStyle(
      color: Colors.white,
      decoration: TextDecoration.underline,
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