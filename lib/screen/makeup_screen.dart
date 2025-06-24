import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'reservation_scre.dart';
import 'command_screen.dart';
import '../services/api_service.dart';
import '../widgets/review_section.dart';

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
                      return _buildServiceCard(
                        context,
                        service['image_url'] ?? 'assets/images/makeup1.jpg',
                        service['name'] ?? 'Makeup Artist',
                        service['phone'] ?? '+222 12345678',
                        service['id'] ?? 1,
                        service['price']?.toString() ?? '1500.0',
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
                    productImage: _makeupServices.first['image_url'] ?? 'assets/images/makeup1.jpg',
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

  Widget _buildServiceCard(
    BuildContext context,
    String imagePath,
    String serviceName,
    String phoneNumber,
    int serviceId,
    String price,
  ) {
    bool isRTL = widget.selectedLanguage == 'Arabic';
    bool isNetworkImage = imagePath.startsWith('http');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Directionality(
                    textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                    child: CommandScreen(
                      productName: serviceName,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: isNetworkImage
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          serviceName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isRTL ? 'السعر: $price MRU' : 'Price: $price MRU',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.pink[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => _launchPhoneCall(phoneNumber),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.phone, size: 16, color: Colors.pink[800]),
                              const SizedBox(width: 4),
                              Text(
                                phoneNumber,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.pink[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          ReviewSection(
            serviceType: 'makeup',
            serviceId: serviceId,
            serviceName: serviceName,
          ),
        ],
      ),
    );
  }
}
