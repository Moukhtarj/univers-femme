import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import '../config.dart';
import '../services/api_service.dart';

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
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _isResending = false;
  String? _errorMessage;
  int _timeLeft = 120; // 2 minutes in seconds
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _resendOtp() async {
    if (!_canResend) return;

    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    try {
      await _apiService.register(
        widget.registrationData['first_name'],
        widget.registrationData['last_name'],
        widget.registrationData['phone'],
        widget.registrationData['password'],
        email: widget.registrationData['email'],
        role: widget.registrationData['role'],
      );

      setState(() {
        _canResend = false;
        _timeLeft = 120;
      });
      _startTimer();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _getTranslation('otpResent'),
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = _getTranslation('resendFailed');
      });
    } finally {
      setState(() {
        _isResending = false;
      });
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.isEmpty || _otpController.text.length != 6) {
      setState(() {
        _errorMessage = _getTranslation('invalidOtp');
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('=== VERIFY OTP DEBUG ===');
      print('Phone: ${widget.phoneNumber}');
      print('OTP: ${_otpController.text}');
      print('Registration data: ${widget.registrationData}');

      final response = await _apiService.verifyOTP(
        widget.phoneNumber,
        _otpController.text,
        widget.registrationData,
      );

      print('Verify OTP response: $response');

      // Save user data and navigate to home
      final prefs = await SharedPreferences.getInstance();
      if (response['user'] != null) {
        await prefs.setString('user', jsonEncode(response['user']));
      }
      if (response['access'] != null) {
        await prefs.setString('token', response['access']);
      }
      if (response['refresh'] != null) {
        await prefs.setString('refresh_token', response['refresh']);
      }
      
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
      print('Verify OTP error: $e');
      setState(() {
        _errorMessage = _getTranslation('verificationFailed');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getTranslation(String key) {
    return widget.translations[widget.selectedLanguage]?[key] ?? 
           widget.translations['English']?[key] ?? key;
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
                _getTranslation('verifyOtp'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                _getTranslation('otpSentTo').replaceFirst('{}', widget.phoneNumber),
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
                  labelText: _getTranslation('enterOtp'),
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
                          _getTranslation('verify'),
                          style: const TextStyle(
                            color: Color.fromRGBO(255, 192, 203, 1),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              // Timer and resend section
              Column(
                children: [
                  if (!_canResend)
                    Text(
                      '${_getTranslation('resendIn')} ${_formatTime(_timeLeft)}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  if (_canResend)
                    TextButton(
                      onPressed: _isResending ? null : _resendOtp,
                      child: _isResending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              _getTranslation('resendOtp'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}