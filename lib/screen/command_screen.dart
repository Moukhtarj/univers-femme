import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class CommandScreen extends StatefulWidget {
  final String productName;
  final int serviceId;
  final String selectedLanguage;
  final Map<String, Map<String, String>> translations;
  final String? productImage;
  final double? productPrice;

  const CommandScreen({
    super.key,
    required this.productName,
    required this.serviceId,
    required this.selectedLanguage,
    required this.translations,
    this.productImage,
    this.productPrice,
  });

  @override
  State<CommandScreen> createState() => _CommandScreenState();
}

class _CommandScreenState extends State<CommandScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  
  bool _isSubmitting = false;
  String? _error;
  bool _isSuccess = false;
  bool _isUserLoggedIn = false;
  Map<String, dynamic>? _userData;
  int _quantity = 1;
  double _price = 0.0;
  double _totalPrice = 0.0;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
    _initializePrice();
  }

  void _initializePrice() {
    // Use the productPrice if provided, otherwise default to 0
    _price = widget.productPrice ?? 0.0;
    _calculateTotalPrice();
  }

  void _calculateTotalPrice() {
    setState(() {
      _totalPrice = _price * _quantity;
    });
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
      _calculateTotalPrice();
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
        _calculateTotalPrice();
      });
    }
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
    _addressController.dispose();
    super.dispose();
  }

  String _translate(String key) {
    return widget.translations[widget.selectedLanguage]?[key] ??
        widget.translations['English']?[key] ??
        key;
  }

  Future<void> _submitCommand() async {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty || _addressController.text.isEmpty) {
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
      final validServiceId = await _apiService.getValidServiceId(widget.serviceId);
      if (validServiceId == null) {
        throw Exception(widget.selectedLanguage == 'Arabic'
            ? 'لم يتم العثور على الخدمة المطلوبة'
            : 'Requested service not found');
      }

      // Format current date for API
      final now = DateTime.now();
      final formattedDate = DateFormat('yyyy-MM-dd').format(now);

      // Build command data with required fields
      final commandData = {
        'service_type': 'henna', // Use henna service type
        'service_id': validServiceId, // Keep as integer
        'date_debut': formattedDate, // Start date
        'date_fin': formattedDate, // End date (same as start for single-day commands)
        'montant_total': _totalPrice.toString(),
        'commentaire': _addressController.text, // Use address as comment
        'statut': 'pending', // Add status field
      };

      print('Sending command data: $commandData'); // Debug print

      // Send command data to API
      final response = await _apiService.createCommand(commandData);
      
      if (response == null) {
        throw Exception('Failed to create command. Server returned null response.');
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
                ? 'تم إرسال الطلب بنجاح'
                : 'Command sent successfully',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          widget.selectedLanguage == 'Arabic'
              ? 'طلب شراء: ${widget.productName}'
              : 'Order: ${widget.productName}',
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
                        ? 'تم إرسال الطلب بنجاح'
                        : 'Your command has been sent successfully',
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
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Product info card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Product image
                          if (widget.productImage != null) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: SizedBox(
                                height: 200,
                                width: double.infinity,
                                child: widget.productImage!.startsWith('http')
                                  ? Image.network(
                                      widget.productImage!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        color: Colors.grey[200],
                                        child: const Icon(
                                          Icons.image_not_supported,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    )
                                  : Image.asset(
                                      widget.productImage!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        color: Colors.grey[200],
                                        child: const Icon(
                                          Icons.image_not_supported,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          Text(
                            widget.productName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF880E4F),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          // Quantity selector
                          if (widget.productPrice != null) ...[
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  widget.selectedLanguage == 'Arabic'
                                      ? 'الكمية:'
                                      : 'Quantity:',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                IconButton(
                                  onPressed: _decrementQuantity,
                                  icon: const Icon(Icons.remove_circle_outline),
                                  color: Colors.pink[400],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.pink[200]!),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _quantity.toString(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: _incrementQuantity,
                                  icon: const Icon(Icons.add_circle_outline),
                                  color: Colors.pink[400],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${widget.selectedLanguage == 'Arabic' ? 'السعر: ' : 'Price: '} ${_totalPrice.toStringAsFixed(2)} MRU',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.pink[700],
                              ),
                            ),
                          ],
                          
                          const Divider(height: 24),
                          Text(
                            widget.selectedLanguage == 'Arabic'
                                ? 'الرجاء ملء المعلومات التالية لإتمام طلبك'
                                : 'Please fill in the following information to complete your order',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Form
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name field
                          Text(
                            widget.selectedLanguage == 'Arabic' ? 'الاسم' : 'Name',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              hintText: widget.selectedLanguage == 'Arabic'
                                  ? 'أدخل اسمك الكامل'
                                  : 'Enter your full name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Phone field
                          Text(
                            widget.selectedLanguage == 'Arabic' ? 'رقم الهاتف' : 'Phone Number',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              hintText: widget.selectedLanguage == 'Arabic'
                                  ? 'أدخل رقم هاتفك'
                                  : 'Enter your phone number',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Address field
                          Text(
                            widget.selectedLanguage == 'Arabic' ? 'العنوان' : 'Address',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _addressController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: widget.selectedLanguage == 'Arabic'
                                  ? 'أدخل عنوانك بالتفصيل'
                                  : 'Enter your detailed address',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Error message if exists
                  if (_error != null) ...[
                    const SizedBox(height: 16),
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
                  ],
                  
                  const SizedBox(height: 30),
                  
                  // Submit button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitCommand,
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
                                  ? 'تأكيد الطلب'
                                  : 'Confirm Order',
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