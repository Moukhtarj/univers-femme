import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/location_service.dart';
import 'package:location/location.dart' show LocationData;
import 'reservations_screen.dart';
import '../services/api_service.dart';
import 'command_screen.dart';
import '../widgets/review_section.dart';

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
  final LocationService _locationService = LocationService();
  List<dynamic> _hennaServices = [];
  bool _isLoading = true;
  String? _error;
  LocationData? _currentLocation;

  @override
  void initState() {
    super.initState();
    _loadHennaServices();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final location = await _locationService.getCurrentLocation();
      if (location == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.selectedLanguage == 'Arabic'
                    ? 'يرجى تفعيل خدمة الموقع لعرض المسافات'
                    : 'Please enable location services to show distances',
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
      setState(() {
        _currentLocation = location;
      });
    } catch (e) {
      print('Error getting location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.selectedLanguage == 'Arabic'
                  ? 'حدث خطأ في الحصول على الموقع'
                  : 'Error getting location',
            ),
          ),
        );
      }
    }
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

  Future<void> _openMaps(double lat, double lng, String label) async {
    try {
      final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.selectedLanguage == 'Arabic'
                    ? 'لا يمكن فتح الخريطة'
                    : 'Could not open maps',
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('Error opening maps: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.selectedLanguage == 'Arabic'
                  ? 'حدث خطأ في فتح الخريطة'
                  : 'Error opening maps',
            ),
          ),
        );
      }
    }
  }

  String _calculateDistance(double? lat, double? lng) {
    if (_currentLocation == null || lat == null || lng == null) {
      return widget.selectedLanguage == 'Arabic' ? 'المسافة غير متوفرة' : 'Distance unavailable';
    }

    try {
      double distanceInMeters = _locationService.calculateDistance(
        _currentLocation!.latitude!,
        _currentLocation!.longitude!,
        lat,
        lng,
      );

      return _locationService.formatDistance(distanceInMeters);
    } catch (e) {
      print('Error calculating distance: $e');
      return widget.selectedLanguage == 'Arabic' ? 'المسافة غير متوفرة' : 'Distance unavailable';
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
              : SizedBox(
                  height: MediaQuery.of(context).size.height - 100, // Account for app bar and padding
                  child: ListView.builder(
                    itemCount: _hennaServices.length,
                    itemBuilder: (context, index) {
                      final service = _hennaServices[index];
                      if (service == null) return const SizedBox.shrink();
                      
                      return _buildServiceCard(
                        context,
                        service['image']?.toString() ?? 'assets/images/henna1.jpg',
                        service['name']?.toString() ?? 'Henna Service',
                        service['phone']?.toString() ?? '+222 22134478',
                        service['id'] != null ? int.tryParse(service['id'].toString()) ?? 1 : 1,
                        service['price']?.toString() ?? '3500.0',
                        double.tryParse(service['latitude']?.toString() ?? ''),
                        double.tryParse(service['longitude']?.toString() ?? ''),
                      );
                    },
                  ),
                ),
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
    double? latitude,
    double? longitude,
  ) {
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
                    textDirection: widget.selectedLanguage == 'Arabic' 
                        ? TextDirection.rtl 
                        : TextDirection.ltr,
                    child: ReservationsScreen(
                      selectedLanguage: widget.selectedLanguage,
                      translations: widget.translations,
                      serviceType: 'henna',
                      serviceId: serviceId,
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
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
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.directions_walk, color: Color(0xFFE8AEC1), size: 16),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _calculateDistance(latitude, longitude),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (latitude != null && longitude != null)
                              TextButton(
                                onPressed: () => _openMaps(latitude, longitude, serviceName),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.map, color: Color(0xFFE8AEC1), size: 16),
                                    const SizedBox(width: 2),
                                    Text(
                                      widget.selectedLanguage == 'Arabic' ? 'عرض على الخريطة' : 'View on Map',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFFE8AEC1),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () => _launchPhoneCall(phoneNumber),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8AEC1).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
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
                                        child: ReservationsScreen(
                                          selectedLanguage: widget.selectedLanguage,
                                          translations: widget.translations,
                                          serviceType: 'henna',
                                          serviceId: serviceId,
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
          ReviewSection(
            serviceType: 'henna',
            serviceId: serviceId,
            serviceName: serviceName,
          ),
        ],
      ),
    );
  }
}