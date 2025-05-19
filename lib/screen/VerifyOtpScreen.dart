import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import '../config.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String selectedLanguage;
  final Map<String, Map<String, String>> translations;
  final Map<String, dynamic> registrationData;
  
  const VerifyOtpScreen({
    super.key,
    required this.phoneNumber,
    required this.selectedLanguage,
    required this.translations,
    required this.registrationData,
  });

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _verifyOtp() async {
    if (_otpController.text.isEmpty || _otpController.text.length != 6) {
      setState(() {
        _errorMessage = widget.translations[widget.selectedLanguage]!['invalidOtp'] ?? 'Invalid OTP';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('${Config.apiUrl}/api/verify-otp/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': widget.phoneNumber,
          'otp': _otpController.text,
          ...widget.registrationData,
        }),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(responseData['user']));
        
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
      } else {
        final error = jsonDecode(response.body);
        setState(() {
          _errorMessage = error['error'] ?? 'Verification failed';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = widget.translations[widget.selectedLanguage]!['networkError'] ?? 'Network error';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text(
                widget.translations[widget.selectedLanguage]!['verifyOtp'] ?? 'Verify OTP',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                widget.translations[widget.selectedLanguage]!['otpSentTo']?.replaceFirst('{}', widget.phoneNumber) ?? 
                'OTP sent to ${widget.phoneNumber}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: widget.translations[widget.selectedLanguage]!['enterOtp'] ?? 'Enter OTP',
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
                style: const TextStyle(color: Colors.white, fontSize: 24),
                textAlign: TextAlign.center,
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
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
                  onPressed: _isLoading ? null : _verifyOtp,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(
                          widget.translations[widget.selectedLanguage]!['verify'] ?? 'Verify',
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
    );
  }
}