import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'ChangePasswordScreen.dart';
import 'home_screen.dart';
import 'fournisseur_dashboard_screen.dart';
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
  bool _obscurePassword = true;
  
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
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: widget.translations[widget.selectedLanguage]!['password']!,
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        color: Colors.white70,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
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
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          // Show loading indicator
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Color.fromRGBO(255, 192, 203, 1),
                                ),
                              );
                            },
                          );

                          print('Attempting login with phone: ${_usernameController.text}');
                          print('API URL: ${Config.apiUrl}');
                          print('Full endpoint: ${Config.apiUrl}/api/token/');
                          
                          // Test server connectivity first
                          try {
                            print('Testing server connectivity...');
                            final testResponse = await http.get(Uri.parse('${Config.apiUrl}'));
                            print('Server connectivity test: ${testResponse.statusCode}');
                          } catch (e) {
                            print('Server connectivity test failed: $e');
                          }
                          
                          // Try different endpoint variations
                          String endpoint = '/api/token/';
                          Map<String, dynamic> response;
                          
                          try {
                            // First try the current endpoint
                            response = await ApiService().post(endpoint, {
                              'phone': _usernameController.text,
                              'password': _passwordController.text,
                            });
                          } catch (e) {
                            print('First attempt failed: $e');
                            
                            // If 405 error, try alternative endpoints
                            if (e.toString().contains('405')) {
                              try {
                                // Try with auth prefix
                                endpoint = '/api/auth/token/';
                                print('Trying alternative endpoint: ${Config.apiUrl}$endpoint');
                                response = await ApiService().post(endpoint, {
                                  'phone': _usernameController.text,
                                  'password': _passwordController.text,
                                });
                              } catch (e2) {
                                print('Second attempt failed: $e2');
                                
                                // Try without trailing slash
                                try {
                                  endpoint = '/api/token';
                                  print('Trying endpoint without trailing slash: ${Config.apiUrl}$endpoint');
                                  response = await ApiService().post(endpoint, {
                                    'phone': _usernameController.text,
                                    'password': _passwordController.text,
                                  });
                                } catch (e3) {
                                  print('Third attempt failed: $e3');
                                  
                                  // Try with auth prefix and no trailing slash
                                  try {
                                    endpoint = '/api/auth/token';
                                    print('Trying auth prefix without trailing slash: ${Config.apiUrl}$endpoint');
                                    response = await ApiService().post(endpoint, {
                                      'phone': _usernameController.text,
                                      'password': _passwordController.text,
                                    });
                                  } catch (e4) {
                                    print('Fourth attempt failed: $e4');
                                    
                                    // Try GET request as last resort
                                    try {
                                      endpoint = '/api/token/';
                                      print('Trying GET request: ${Config.apiUrl}$endpoint');
                                      response = await ApiService().getAuth(endpoint, {
                                        'phone': _usernameController.text,
                                        'password': _passwordController.text,
                                      });
                                    } catch (e5) {
                                      print('Fifth attempt (GET) failed: $e5');
                                      
                                      // Try GET with auth prefix
                                      try {
                                        endpoint = '/api/auth/token/';
                                        print('Trying GET with auth prefix: ${Config.apiUrl}$endpoint');
                                        response = await ApiService().getAuth(endpoint, {
                                          'phone': _usernameController.text,
                                          'password': _passwordController.text,
                                        });
                                      } catch (e6) {
                                        print('All attempts failed. Throwing original error.');
                                        throw e; // Throw the original error
                                      }
                                    }
                                  }
                                }
                              }
                            } else {
                              // If it's not a 405 error, rethrow the original error
                              throw e;
                            }
                          }
                          
                          // Close loading dialog
                          Navigator.of(context).pop();
                          
                          // Save token and user data
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setString('token', response['access']);
                          await prefs.setString('user', jsonEncode(response));
                          
                          // Get user profile to check role
                          try {
                            final userProfileResponse = await ApiService().get('/api/users/profile/data/');
                            final userRole = userProfileResponse['role'] ?? 'utilisateur';
                            
                            // Debug logging
                            print('User profile response: $userProfileResponse');
                            print('User role: $userRole');
                            
                            // Navigate based on user role (case-insensitive comparison)
                            if (userRole.toString().toLowerCase() == 'fournisseur') {
                              print('Navigating to FournisseurDashboardScreen');
                              // Navigate to fournisseur dashboard
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Directionality(
                                    textDirection: widget.selectedLanguage == 'Arabic' 
                                        ? TextDirection.rtl 
                                        : TextDirection.ltr,
                                    child: const FournisseurDashboardScreen(),
                                  ),
                                ),
                              );
                            } else {
                              print('Navigating to ModernHomeScreen');
                              // Navigate to home screen for utilisateur
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
                            }
                          } catch (profileError) {
                            // If profile fetch fails, default to home screen
                            print('Error fetching user profile: $profileError');
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
                          }
                        } catch (e) {
                          // Close loading dialog if it's still open
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          }
                          
                          print('Login error: $e');
                          print('Error type: ${e.runtimeType}');
                          
                          String errorMessage = 'Login failed';
                          
                          if (e.toString().contains('405')) {
                            errorMessage = 'Server error: Method not allowed. Please contact support.';
                          } else if (e.toString().contains('401')) {
                            errorMessage = 'Invalid phone number or password';
                          } else if (e.toString().contains('404')) {
                            errorMessage = 'Login service not found. Please contact support.';
                          } else if (e.toString().contains('500')) {
                            errorMessage = 'Server error. Please try again later.';
                          } else if (e.toString().contains('timeout') || e.toString().contains('connection')) {
                            errorMessage = 'Connection error. Please check your internet connection.';
                          } else {
                            errorMessage = e.toString();
                          }
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(errorMessage),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 5),
                            ),
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