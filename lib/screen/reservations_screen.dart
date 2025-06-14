import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/reservation.dart';
import 'package:intl/intl.dart';

class ReservationsScreen extends StatefulWidget {
  final String selectedLanguage;
  final Map<String, Map<String, String>> translations;
  final String? serviceType;
  final int? serviceId;
  
  const ReservationsScreen({
    Key? key,
    required this.selectedLanguage,
    required this.translations,
    this.serviceType,
    this.serviceId,
  }) : super(key: key);

  @override
  _ReservationsScreenState createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  
  bool _isSubmitting = false;
  String? _error;
  bool _isSuccess = false;
  bool _isUserLoggedIn = false;
  Map<String, dynamic>? _userData;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  List<Reservation> _reservations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadReservations();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _apiService.getCurrentUser();
      setState(() {
        _userData = userData;
        _isUserLoggedIn = userData != null;
        
        // Pre-fill name and phone if user is logged in
        if (_isUserLoggedIn && userData != null) {
          if (userData['first_name'] != null && userData['last_name'] != null) {
            _nameController.text = '${userData['first_name']} ${userData['last_name']}';
          }
          
          if (userData['phone'] != null) {
            _phoneController.text = userData['phone'];
          }
        }
      });
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  String _translate(String key) {
    return widget.translations[widget.selectedLanguage]?[key] ?? 
           widget.translations['English']?[key] ?? key;
  }

  Future<void> _loadReservations() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final response = await _apiService.getUserReservations();
      if (response == null) {
        throw Exception('Failed to load reservations');
      }
      setState(() {
        _reservations = response.map<Reservation>((json) => Reservation.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = picked.format(context);
      });
    }
  }

  Future<void> _submitReservation() async {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty || _dateController.text.isEmpty || _timeController.text.isEmpty) {
      setState(() {
        _error = widget.selectedLanguage == 'Arabic'
            ? 'يرجى ملء جميع الحقول المطلوبة'
            : 'Please fill all required fields';
      });
      return;
    }

    try {
      setState(() {
        _isSubmitting = true;
        _error = null;
      });

      // Get a valid service ID
      final serviceId = widget.serviceId ?? 1;
      final serviceType = widget.serviceType ?? 'hammam';

      // Parse the date and time
      final date = DateTime.parse(_dateController.text);
      final time = TimeOfDay.fromDateTime(DateTime.parse('2024-01-01 ${_timeController.text}'));
      
      // Combine date and time for start and end
      final dateDebut = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      
      // End time is 2 hours after start time (default duration)
      final dateFin = dateDebut.add(const Duration(hours: 2));

      // Build reservation data according to API requirements
      final reservationData = {
        'service_type': serviceType,
        'service_id': serviceId,
        'date_debut': DateFormat('yyyy-MM-dd').format(dateDebut),
        'date_fin': DateFormat('yyyy-MM-dd').format(dateFin),
        'commentaire': '', // Optional comment
      };

      print('Sending reservation data: $reservationData'); // Debug print

      // Send reservation data to API
      final response = await _apiService.createReservation(reservationData);
      
      if (response == null) {
        throw Exception('Failed to create reservation. Server returned null response.');
      }

      setState(() {
        _isSubmitting = false;
        _isSuccess = true;
      });

      // Show success notification
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.selectedLanguage == 'Arabic'
                ? 'تم إرسال الحجز بنجاح'
                : 'Reservation sent successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _error = e.toString();
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getServiceIcon(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'hammam':
        return Icons.spa;
      case 'melhfa':
        return Icons.checkroom;
      case 'henna':
        return Icons.back_hand;
      case 'makeup':
        return Icons.brush;
      case 'gym':
        return Icons.sports_gymnastics;
      case 'accessory':
        return Icons.diamond;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          widget.selectedLanguage == 'Arabic'
              ? 'حجز جديد'
              : 'New Reservation',
          style: const TextStyle(
            fontSize: 18,
          ),
        ),
        backgroundColor: const Color(0xFFF8BBD0),
        foregroundColor: Colors.white,
      ),
      body: _isSuccess
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: Colors.green[400],
                      ),
                      const SizedBox(height: 16),
                  Text(
                    widget.selectedLanguage == 'Arabic'
                        ? 'تم إرسال الحجز بنجاح'
                        : 'Your reservation has been sent successfully',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                          Text(
                    widget.selectedLanguage == 'Arabic'
                        ? 'سنتصل بك قريبًا'
                        : 'We\'ll contact you soon',
                            style: TextStyle(
                      fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Name field
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: widget.selectedLanguage == 'Arabic'
                          ? 'الاسم الكامل'
                          : 'Full Name',
                      border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                      prefixIcon: const Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Phone field
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: widget.selectedLanguage == 'Arabic'
                          ? 'رقم الهاتف'
                          : 'Phone Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),

                  // Date field
                  TextFormField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      labelText: widget.selectedLanguage == 'Arabic'
                          ? 'التاريخ'
                          : 'Date',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(context),
                  ),
                  const SizedBox(height: 16),

                  // Time field
                  TextFormField(
                    controller: _timeController,
                    decoration: InputDecoration(
                      labelText: widget.selectedLanguage == 'Arabic'
                          ? 'الوقت'
                          : 'Time',
                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                      prefixIcon: const Icon(Icons.access_time),
                    ),
                    readOnly: true,
                    onTap: () => _selectTime(context),
                  ),
                  const SizedBox(height: 24),

                  // Error message if any
                  if (_error != null) ...[
                    Card(
                      color: Colors.red[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red[700]),
                            const SizedBox(width: 12),
                            Expanded(
                                        child: Text(
                                _error!,
                                style: TextStyle(color: Colors.red[700]),
                                        ),
                                      ),
                                    ],
                                  ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Submit button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitReservation,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFFF06292),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.pink[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              widget.selectedLanguage == 'Arabic'
                                  ? 'تأكيد الحجز'
                                  : 'Confirm Reservation',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
                      ),
                    ),
    );
  }
} 