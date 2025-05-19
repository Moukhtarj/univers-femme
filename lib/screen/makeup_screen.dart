import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'reservation_screen.dart';
import 'command_screen.dart';
import '../services/api_service.dart';

class MakeupScreen extends StatefulWidget {
  final String selectedLanguage;
  final Map<String, Map<String, String>> translations;
  
  const MakeupScreen({
    super.key,
    required this.selectedLanguage,
    required this.translations,
  });

  @override
  State<MakeupScreen> createState() => _MakeupScreenState();
}

class _MakeupScreenState extends State<MakeupScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _makeupServices = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMakeupServices();
  }

  Future<void> _loadMakeupServices() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      final services = await _apiService.getMakeupServices();
      
      setState(() {
        _makeupServices = services;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _launchPhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    
    if (await canLaunch(launchUri.toString())) {
      await launch(launchUri.toString());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.selectedLanguage == 'Arabic'
                ? 'لا يمكن الاتصال'
                : 'Could not launch phone call',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isRTL = widget.selectedLanguage == 'Arabic';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.translations[widget.selectedLanguage]?['makeup'] ?? 'Makeup'),
        backgroundColor: Colors.pink[800],
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF9E8EF),
              Color(0xFFF5D6E3),
            ],
          ),
        ),
        child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFF06292)))
          : _error != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: $_error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadMakeupServices,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF06292),
                      ),
                      child: Text(
                        widget.selectedLanguage == 'Arabic' ? 'حاول مرة أخرى' : 'Try Again',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              )
            : _makeupServices.isEmpty
              ? Center(
                  child: Text(
                    widget.selectedLanguage == 'Arabic'
                      ? 'لا توجد خدمات مكياج متاحة حالياً'
                      : 'No makeup services available',
                    style: const TextStyle(fontSize: 16),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: _makeupServices.length,
                    itemBuilder: (context, index) {
                      final service = _makeupServices[index];
                      return _buildMakeupArtistCard(
                        context,
                        service['image'] ?? 'assets/images/makeup1.jpg',
                        service['name'] ?? 'Makeup Artist',
                        service['phone'] ?? '+222 12345678',
                        service['price']?.toString() ?? '1500.0',
                        service['id'] ?? 1,
                      );
                    },
                  ),
                ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_makeupServices.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Directionality(
                  textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                  child: CommandScreen(
                    productName: isRTL ? 'حجز مكياج' : 'Makeup Booking',
                    serviceId: _makeupServices.first['id'] ?? 1,
                    selectedLanguage: widget.selectedLanguage,
                    translations: widget.translations,
                    productImage: _makeupServices.first['image'] ?? 'assets/images/makeup1.jpg',
                    productPrice: double.tryParse(_makeupServices.first['price']?.toString() ?? '0.0') ?? 0.0,
                  ),
                ),
              ),
            );
          }
        },
        backgroundColor: Colors.pink[800],
        child: const Icon(Icons.calendar_today, color: Colors.white),
      ),
    );
  }

  Widget _buildMakeupArtistCard(
    BuildContext context,
    String imagePath,
    String salonName,
    String phoneNumber,
    String price,
    int serviceId,
  ) {
    bool isRTL = widget.selectedLanguage == 'Arabic';
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Directionality(
                textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                child: CommandScreen(
                  productName: salonName,
                  serviceId: serviceId,
                  selectedLanguage: widget.selectedLanguage,
                  translations: widget.translations,
                  productImage: imagePath,
                  productPrice: double.tryParse(price) ?? 0.0,
                ),
              ),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: AspectRatio(
                  aspectRatio: 16/9,
                  child: imagePath.toString().startsWith('http')
                    ? Image.network(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(Icons.face_retouching_natural, 
                                size: 40, color: Colors.grey),
                          ),
                        ),
                      )
                    : Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(Icons.face_retouching_natural, 
                                size: 40, color: Colors.grey),
                          ),
                        ),
                      ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                salonName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                isRTL ? 'السعر: $price MRU' : 'Price: $price MRU',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.pink[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.phone, size: 16),
                    label: Text(isRTL ? 'اتصل' : 'Call'),
                    onPressed: () => _launchPhoneCall(phoneNumber),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink[50],
                      foregroundColor: Colors.pink[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text(isRTL ? 'حجز' : 'Book'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Directionality(
                              textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                              child: CommandScreen(
                                productName: salonName,
                                serviceId: serviceId,
                                selectedLanguage: widget.selectedLanguage,
                                translations: widget.translations,
                                productImage: imagePath,
                                productPrice: double.tryParse(price) ?? 0.0,
                              ),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink[800],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
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
