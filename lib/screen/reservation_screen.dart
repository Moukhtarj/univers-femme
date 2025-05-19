import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class ReservationScreen extends StatefulWidget {
  final String productName;
  final int serviceId;
  final String selectedLanguage;
  final Map<String, Map<String, String>> translations;
  final String? serviceType;

  const ReservationScreen({
    super.key,
    required this.productName,
    required this.serviceId,
    required this.selectedLanguage,
    required this.translations,
    this.serviceType,
  });

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTime? _selectedDateTime;
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  // Expression régulière pour le nom (lettres, espaces et caractères arabes)
  final RegExp _nameRegExp = RegExp(r'^[\p{L}\s]+$', unicode: true);
  
  // Expression régulière pour le téléphone mauritanien (exactement 8 chiffres commençant par 2, 3, 4 ou 6)
  final RegExp _phoneRegExp = RegExp(r'^[234]\d{7}$');

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _checkUserLoginStatus();
  }

  Future<void> _loadUserData() async {
    final userData = await _apiService.getCurrentUser();
    if (userData != null && mounted) {
      setState(() {
        _nameController.text = '${userData['first_name'] ?? ''} ${userData['last_name'] ?? ''}'.trim();
        if (userData['phone'] != null) {
          // Remove country code if present
          String phone = userData['phone'];
          if (phone.startsWith('+222')) {
            phone = phone.substring(4);
          }
          _phoneController.text = phone;
        }
      });
    }
  }

  Future<void> _checkUserLoginStatus() async {
    bool isLoggedIn = await _apiService.isLoggedIn();
    if (!isLoggedIn && mounted) {
      // Delay showing the dialog until the widget is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showLoginRequiredDialog(context);
      });
    }
  }

  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            widget.selectedLanguage == 'Arabic' 
                ? 'تسجيل الدخول مطلوب' 
                : 'Connexion requise'
          ),
          content: Text(
            widget.selectedLanguage == 'Arabic'
                ? 'يجب تسجيل الدخول لإنشاء حجز'
                : 'Vous devez être connecté pour créer une réservation'
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Return to previous screen
                
                // Navigate to login screen
                Navigator.pushNamed(context, '/login');
              },
              child: Text(
                widget.selectedLanguage == 'Arabic' ? 'تسجيل الدخول' : 'Se connecter'
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Return to previous screen
              },
              child: Text(
                widget.selectedLanguage == 'Arabic' ? 'إلغاء' : 'Annuler'
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectedLanguage == 'Arabic' ? 'حجز' : 'Reservation'),
        backgroundColor: const Color.fromARGB(255, 226, 173, 191),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                widget.productName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: widget.selectedLanguage == 'Arabic' ? 'الاسم الكامل' : 'Nom complet',
                  border: const OutlineInputBorder(),
                  hintText: widget.selectedLanguage == 'Arabic' ? 'أدخل اسمك الكامل' : 'Entrez votre nom complet',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return widget.selectedLanguage == 'Arabic' 
                        ? 'الاسم مطلوب' 
                        : 'Le nom est requis';
                  }
                  if (!_nameRegExp.hasMatch(value)) {
                    return widget.selectedLanguage == 'Arabic'
                        ? 'الاسم يجب أن يحتوي على أحرف فقط'
                        : 'Le nom ne doit contenir que des lettres';
                  }
                  if (value.length < 3) {
                    return widget.selectedLanguage == 'Arabic'
                        ? 'الاسم يجب أن يكون على الأقل 3 أحرف'
                        : 'Le nom doit contenir au moins 3 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: widget.selectedLanguage == 'Arabic' ? 'رقم الهاتف' : 'Numéro de téléphone',
                  border: const OutlineInputBorder(),
                  hintText: widget.selectedLanguage == 'Arabic' ? 'مثال: 31234567' : 'Exemple: 31234567',
                  prefixText: '+222 ',
                ),
                keyboardType: TextInputType.phone,
                maxLength: 8,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return widget.selectedLanguage == 'Arabic' 
                        ? 'رقم الهاتف مطلوب' 
                        : 'Le numéro de téléphone est requis';
                  }
                  if (!_phoneRegExp.hasMatch(value)) {
                    return widget.selectedLanguage == 'Arabic'
                        ? 'يجب أن يبدأ رقم الهاتف بـ 2/3/4 ويتكون من 8 أرقام'
                        : 'Le numéro doit commencer par 2/3/4 et contenir 8 chiffres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  widget.selectedLanguage == 'Arabic' 
                      ? 'تاريخ ووقت الحجز' 
                      : 'Date et heure de réservation',
                ),
                subtitle: Text(
                  _selectedDateTime == null
                      ? widget.selectedLanguage == 'Arabic'
                          ? 'اختر التاريخ والوقت'
                          : 'Sélectionnez la date et l\'heure'
                      : DateFormat('dd-MM-yyyy HH:mm').format(_selectedDateTime!),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDateTime(context),
              ),
              const SizedBox(height: 24),
              _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 236, 169, 191),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (_selectedDateTime == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              widget.selectedLanguage == 'Arabic'
                                  ? 'الرجاء اختيار التاريخ والوقت'
                                  : 'Veuillez sélectionner une date et une heure',
                            ),
                          ),
                        );
                      } else {
                        _submitReservation();
                      }
                    }
                  },
                  child: Text(
                    widget.selectedLanguage == 'Arabic' ? 'تأكيد الحجز' : 'Confirmer la réservation',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitReservation() async {
    // Check if the user is logged in first
    bool isLoggedIn = await _apiService.isLoggedIn();
    if (!isLoggedIn) {
      _showLoginRequiredDialog(context);
      return;
    }
    
    // We've already checked if logged in, no need to check for user data structure
    // since the api_service will handle that
    
    setState(() {
      _isLoading = true;
    });

    try {
      // Format user details for notes
      String notes = 'Name: ${_nameController.text.trim()}, Phone: +222 ${_phoneController.text.trim()}, Mobile app reservation';
      
      // Debug log
      print('Submitting reservation: ${widget.serviceId}, ${_selectedDateTime!}, $notes');
      print('Service type: ${widget.serviceType ?? "not specified"}');
      
      // Add detailed service ID logging
      print('-------------- SERVICE RESERVATION DEBUG --------------');
      print('Service ID: ${widget.serviceId}');
      print('Service Type: ${widget.serviceType}');
      print('Service Name: ${widget.productName}');
      print('Date/Time: ${_selectedDateTime!.toIso8601String()}');
      print('Notes: $notes');
      print('Important: Using endpoint for ${widget.serviceType ?? "generic"} type reservation');
      print('For hammam this should use: /api/hammams/services/${widget.serviceId}/reserve/');
      print('For gym this should use: /api/gyms/services/${widget.serviceId}/reserve/');
      print('This serviceId should exist in the corresponding table (HammamService or GymService)');
      
      final result = await _apiService.createReservation(
        widget.serviceId, 
        _selectedDateTime!,
        notes: notes,
        serviceType: widget.serviceType,
      );
      
      print('Reservation created successfully: $result');
      print('-------------- END SERVICE RESERVATION DEBUG --------------');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.selectedLanguage == 'Arabic'
                ? 'تم تأكيد الحجز بنجاح!'
                : 'Réservation confirmée avec succès!',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      
      print('Reservation submission error: $e');
      print('-------------- RESERVATION ERROR DEBUG --------------');
      print('Error details: ${e.toString()}');
      print('-------------- END RESERVATION ERROR DEBUG --------------');
      
      // Check if the error is about login
      if (e.toString().contains('You must be logged in')) {
        _showLoginRequiredDialog(context);
      } 
      // Check if it's about the service
      else if (e.toString().contains('service') && e.toString().contains('object does not exist')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.selectedLanguage == 'Arabic'
                  ? 'الخدمة المحددة غير موجودة. الرجاء اختيار خدمة أخرى.'
                  : 'Selected service does not exist. Please try with a different service.',
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 5),
            action: SnackBarAction(
              label: widget.selectedLanguage == 'Arabic' ? 'حسنًا' : 'OK',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.selectedLanguage == 'Arabic'
                  ? 'فشل في إنشاء الحجز: ${e.toString()}'
                  : 'Failed to create reservation: ${e.toString()}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}