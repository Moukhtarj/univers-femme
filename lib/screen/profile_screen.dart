import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  final String selectedLanguage;
  final Map<String, Map<String, String>> translations;

  const ProfileScreen({
    Key? key,
    required this.selectedLanguage,
    required this.translations,
  }) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  Map<String, dynamic>? _userData;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _loadUserData();
  }

  // Helper method to safely get translations
  String _getTranslation(String key, String fallback) {
    try {
      return widget.translations[widget.selectedLanguage]?[key] ?? fallback;
    } catch (e) {
      return fallback;
    }
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user');
    if (userStr != null) {
      setState(() {
        _userData = json.decode(userStr);
        _firstNameController.text = _userData?['first_name'] ?? '';
        _lastNameController.text = _userData?['last_name'] ?? '';
        _emailController.text = _userData?['email'] ?? '';
        _phoneController.text = _userData?['phone'] ?? '';
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await ApiService().put('api/auth/users/profile/', {
          'first_name': _firstNameController.text,
          'last_name': _lastNameController.text,
          'email': _emailController.text,
        });

        if (_userData != null) {
          _userData!['first_name'] = _firstNameController.text;
          _userData!['last_name'] = _lastNameController.text;
          _userData!['email'] = _emailController.text;

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user', json.encode(_userData));
        }

        setState(() {
          _isEditing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _getTranslation('profileUpdated', 'Profile updated successfully'),
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getTranslation('profile', 'Profile'),
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromRGBO(255, 192, 203, 1),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _updateProfile();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Color.fromRGBO(255, 192, 203, 1),
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _firstNameController,
                enabled: _isEditing,
                decoration: InputDecoration(
                  labelText: _getTranslation('firstName', 'First Name'),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return _getTranslation('requiredField', 'This field is required');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                enabled: _isEditing,
                decoration: InputDecoration(
                  labelText: _getTranslation('lastName', 'Last Name'),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return _getTranslation('requiredField', 'This field is required');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                enabled: _isEditing,
                decoration: InputDecoration(
                  labelText: _getTranslation('email', 'Email'),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return _getTranslation('invalidEmail', 'Invalid email format');
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                enabled: false, // Phone number cannot be edited
                decoration: InputDecoration(
                  labelText: _getTranslation('phone', 'Phone'),
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
} 