import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'reservation_screen.dart';
import '../services/api_service.dart';
import 'command_screen.dart';

class HennaScreen extends StatefulWidget {
  final String selectedLanguage;
  final Map<String, Map<String, String>> translations;
  
  const HennaScreen({
    super.key,
    required this.selectedLanguage,
    required this.translations,
  });

  @override
  State<HennaScreen> createState() => _HennaScreenState();
}

class _HennaScreenState extends State<HennaScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _hennaServices = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHennaServices();
  }

  Future<void> _loadHennaServices() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      final services = await _apiService.getHennaOptions();
      
      setState(() {
        _hennaServices = services;
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.translations[widget.selectedLanguage]!['henna']!),
        backgroundColor: const Color(0xFFE8AEC1),
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
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE8AEC1)))
          : _error != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: $_error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadHennaServices,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE8AEC1),
                      ),
                      child: const Text('Retry', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              )
            : _hennaServices.isEmpty
              ? Center(
                  child: Text(
                    widget.selectedLanguage == 'Arabic'
                      ? 'لا توجد خدمات حناء متاحة حالياً'
                      : 'No henna services available',
                    style: const TextStyle(fontSize: 16),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: _hennaServices.length,
                    itemBuilder: (context, index) {
                      final service = _hennaServices[index];
                      return _buildServiceCard(
                        context,
                        service['image'] ?? 'assets/images/henna1.jpg',
                        service['name'] ?? 'Henna Service',
                        service['phone'] ?? '+222 22134478',
                        service['id'] ?? 1,
                        service['price']?.toString() ?? '3500.0',
                      );
                    },
                  ),
                ),
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, String imagePath, String serviceName, String phoneNumber, int serviceId, String price) {
    bool isNetworkImage = imagePath.startsWith('http');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
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
                textDirection: widget.selectedLanguage == 'Arabic' 
                    ? TextDirection.rtl 
                    : TextDirection.ltr,
                child: ReservationScreen(
                  productName: serviceName,
                  serviceId: serviceId,
                  selectedLanguage: widget.selectedLanguage,
                  translations: widget.translations,
                  serviceType: 'henna',
                ),
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFFF9FB),
                Color(0xFFFFF0F5),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              // Circular avatar with image
              Hero(
                tag: serviceName,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE8AEC1),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: isNetworkImage
                      ? Image.network(
                          imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Icon(
                              Icons.spa,
                              size: 30,
                              color: const Color(0xFFE8AEC1).withOpacity(0.6),
                            ),
                          ),
                        )
                      : Image.asset(
                          imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Icon(
                              Icons.spa,
                              size: 30,
                              color: const Color(0xFFE8AEC1).withOpacity(0.6),
                            ),
                          ),
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Service info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      serviceName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF880E4F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$price MRU',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFFE8AEC1),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // Call button
                        InkWell(
                          onTap: () => _launchPhoneCall(phoneNumber),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8AEC1).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.phone,
                                  size: 16,
                                  color: Color(0xFFE8AEC1),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.selectedLanguage == 'Arabic' ? 'اتصل الآن' : 'Call',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFE8AEC1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        
                        // Book button
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE8AEC1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Directionality(
                                    textDirection: widget.selectedLanguage == 'Arabic' 
                                        ? TextDirection.rtl 
                                        : TextDirection.ltr,
                                    child: ReservationScreen(
                                      productName: serviceName,
                                      serviceId: serviceId,
                                      selectedLanguage: widget.selectedLanguage,
                                      translations: widget.translations,
                                      serviceType: 'henna',
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              widget.selectedLanguage == 'Arabic' ? 'حجز' : 'Book',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}