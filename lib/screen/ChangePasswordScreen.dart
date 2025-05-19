import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
class ChangePasswordScreen extends StatefulWidget {
  final String selectedLanguage;
  final Map<String, Map<String, String>> translations;
  
  const ChangePasswordScreen({
    super.key,
    required this.selectedLanguage,
    required this.translations,
  });

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _otpSent = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
String phone = _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '').trim();

      final response = await http.post(
        Uri.parse('${Config.apiUrl}/api/password-reset/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
        }),
      );

      if (response.statusCode == 200) {
        setState(() => _otpSent = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.translations[widget.selectedLanguage]!['otpSent'] ?? 'OTP sent successfully'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = widget.translations[widget.selectedLanguage]!['passwordMismatch'] ?? 'Passwords do not match');
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final response = await http.post(
        Uri.parse('${Config.apiUrl}/api/password-reset/confirm/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': '+222${_phoneController.text.replaceAll('+222', '').trim()}',
          'otp': _otpController.text,
          'new_password': _newPasswordController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.translations[widget.selectedLanguage]!['passwordChanged'] ?? 'Password changed successfully'),
          ),
        );
        Navigator.pop(context);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Password reset failed');
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
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
        title: Text(
          widget.translations[widget.selectedLanguage]!['changePassword'] ?? 'Change Password',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: widget.translations[widget.selectedLanguage]!['phoneNumber'] ?? 'Phone Number',
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixText: '+222 ',
                    prefixStyle: const TextStyle(color: Colors.white),
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
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return widget.translations[widget.selectedLanguage]!['phoneRequired'] ?? 'Phone number is required';
                    }
                    return null;
                  },
                  enabled: !_otpSent,
                ),
                
                if (_otpSent) ...[
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _otpController,
                    decoration: InputDecoration(
                      labelText: widget.translations[widget.selectedLanguage]!['otpCode'] ?? 'OTP Code',
                      labelStyle: const TextStyle(color: Colors.white70),
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
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return widget.translations[widget.selectedLanguage]!['otpRequired'] ?? 'OTP is required';
                      }
                      if (value.length != 6) {
                        return widget.translations[widget.selectedLanguage]!['otpLength'] ?? 'OTP must be 6 digits';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _newPasswordController,
                    decoration: InputDecoration(
                      labelText: widget.translations[widget.selectedLanguage]!['newPassword'] ?? 'New Password',
                      labelStyle: const TextStyle(color: Colors.white70),
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
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return widget.translations[widget.selectedLanguage]!['passwordRequired'] ?? 'Password is required';
                      }
                      if (value.length < 8) {
                        return widget.translations[widget.selectedLanguage]!['passwordLength'] ?? 'Password must be at least 8 characters';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: widget.translations[widget.selectedLanguage]!['confirmPassword'] ?? 'Confirm Password',
                      labelStyle: const TextStyle(color: Colors.white70),
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
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return widget.translations[widget.selectedLanguage]!['confirmPasswordRequired'] ?? 'Please confirm your password';
                      }
                      return null;
                    },
                  ),
                ],
                
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: _isLoading 
                        ? null 
                        : _otpSent ? _resetPassword : _sendOtp,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : Text(
                            _otpSent 
                                ? widget.translations[widget.selectedLanguage]!['resetPassword'] ?? 'Reset Password'
                                : widget.translations[widget.selectedLanguage]!['sendOtp'] ?? 'Send OTP',
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