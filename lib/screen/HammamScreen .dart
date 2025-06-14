import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../services/location_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:location/location.dart' show LocationData;
import 'reservations_screen.dart';
import '../services/api_service.dart';
import '../widgets/review_section.dart';

class HammamListScreen extends StatefulWidget {
  final String selectedLanguage;
  final Map<String, Map<String, String>> translations;
  
  const HammamListScreen({
    super.key,
    required this.selectedLanguage,
    required this.translations,
  });

  @override
  State<HammamListScreen> createState() => _HammamListScreenState();
}

class _HammamListScreenState extends State<HammamListScreen> {
  final ApiService _apiService = ApiService();
  final LocationService _locationService = LocationService();
  List<dynamic> _hammams = [];
  bool _isLoading = true;
  String? _error;
  LocationData? _currentLocation;

  // Helper method to get translated text with fallback
  String _translate(String key) {
    return widget.translations[widget.selectedLanguage]?[key] ?? widget.translations['English']?[key] ?? key;
  }

  @override
  void initState() {
    super.initState();
    _loadHammams();
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

  Future<void> _loadHammams() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      final hammams = await _apiService.getHammams();
      
      setState(() {
        _hammams = hammams;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
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
      backgroundColor: const Color(0xFFFDF2F5),
      appBar: AppBar(
        title: Text(
          _translate('hamam'),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: const Color(0xFFF8BBD0),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFF8BBD0)))
        : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: $_error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadHammams,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF8BBD0),
                    ),
                    child: Text(
                      _translate('try_again'),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            )
          : _hammams.isEmpty
            ? Center(
                child: Text(
                  widget.selectedLanguage == 'Arabic'
                    ? 'لا توجد حمامات متاحة حالياً'
                    : 'No hammams available',
                  style: const TextStyle(fontSize: 16),
                ),
              )
            : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: ListView(
                children: [
                  const SizedBox(height: 10),
                  _buildCategoryHeader(context, _translate('hammams')),
                  const SizedBox(height: 15),
                  ..._hammams.map((hammam) => _buildHammamCard(
                    context,
                    hammam['image']?.toString() ?? 'assets/images/hammam_nil.jpg',
                    hammam['name']?.toString() ?? 'Hammam',
                    hammam['location']?.toString() ?? _getTranslatedAddress('main_street_nouakchott'),
                    (hammam['rating'] != null) ? double.tryParse(hammam['rating'].toString()) ?? 4.5 : 4.5,
                    hammam['hours']?.toString() ?? _getOperatingHours('8_22'),
                    hammam['id'] != null
                        ? int.tryParse(hammam['id'].toString()) ?? 1
                        : 1,
                    double.tryParse(hammam['latitude']?.toString() ?? ''),
                    double.tryParse(hammam['longitude']?.toString() ?? ''),
                  )).toList(),
                ],
              ),
            ),
    );
  }

  // Helper methods for translations
  String _getTranslatedAddress(String key) {
    switch (widget.selectedLanguage) {
      case 'Arabic':
        return {
          'main_street_nouakchott': 'الشارع الرئيسي، نواكشوط',
          'tevragh_zeina_nouakchott': 'حي تفرغ زينة، نواكشوط',
          'abdel_nasser_street_nouakchott': 'شارع عبد الناصر، نواكشوط',
          'ksar_district_nouakchott': 'حي لكصر، نواكشوط',
        }[key] ?? '';
      case 'French':
        return {
          'main_street_nouakchott': 'Rue principale, Nouakchott',
          'tevragh_zeina_nouakchott': 'Tevragh Zeina, Nouakchott',
          'abdel_nasser_street_nouakchott': 'Rue Abdel Nasser, Nouakchott',
          'ksar_district_nouakchott': 'Quartier Ksar, Nouakchott',
        }[key] ?? '';
      default: // English
        return {
          'main_street_nouakchott': 'Main Street, Nouakchott',
          'tevragh_zeina_nouakchott': 'Tevragh Zeina, Nouakchott',
          'abdel_nasser_street_nouakchott': 'Abdel Nasser Street, Nouakchott',
          'ksar_district_nouakchott': 'Ksar District, Nouakchott',
        }[key] ?? '';
    }
  }

  String _getOperatingHours(String key) {
    switch (widget.selectedLanguage) {
      case 'Arabic':
        return {
          '8_22': '8:00 - 22:00',
          '7_23': '7:00 - 23:00',
          '7.5_23.5': '7:30 - 23:30',
        }[key] ?? '';
      case 'French':
        return {
          '8_22': '8h - 22h',
          '7_23': '7h - 23h',
          '7.5_23.5': '7h30 - 23h30',
        }[key] ?? '';
      default: // English
        return {
          '8_22': '8:00 - 22:00',
          '7_23': '7:00 - 23:00',
          '7.5_23.5': '7:30 - 23:30',
        }[key] ?? '';
    }
  }

  Widget _buildCategoryHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Container(
            height: 24,
            width: 6,
            decoration: BoxDecoration(
              color: const Color(0xFFF06292),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF880E4F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHammamCard(
    BuildContext context,
    String imagePath,
    String name,
    String location,
    double rating,
    String hours,
    int hammamId,
    double? latitude,
    double? longitude,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Directionality(
                textDirection: widget.selectedLanguage == 'Arabic' 
                    ? TextDirection.rtl 
                    : TextDirection.ltr,
                child: HammamDetailScreen(
                  hammamId: hammamId,
                  hammamName: name,
                  selectedLanguage: widget.selectedLanguage,
                  translations: widget.translations,
                ),
              ),
            ),
          );
        },
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              child: imagePath.startsWith('http')
                ? Image.network(
                    imagePath,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 180,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.spa, size: 60, color: Colors.grey),
                      ),
                    ),
                  )
                : Image.asset(
                    imagePath,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 180,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.spa, size: 60, color: Colors.grey),
                      ),
                    ),
                  ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF880E4F),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8BBD0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              rating.toString(),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Color(0xFFF06292), size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Color(0xFFF06292), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        hours,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.directions_walk, color: Color(0xFFF06292), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        _calculateDistance(latitude, longitude),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const Spacer(),
                      if (latitude != null && longitude != null)
                        TextButton.icon(
                          onPressed: () => _openMaps(latitude, longitude, name),
                          icon: const Icon(Icons.map, color: Color(0xFFF06292), size: 16),
                          label: Text(
                            widget.selectedLanguage == 'Arabic' ? 'عرض على الخريطة' : 'View on Map',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFFF06292),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF06292),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Directionality(
                                  textDirection: widget.selectedLanguage == 'Arabic' 
                                      ? TextDirection.rtl 
                                      : TextDirection.ltr,
                                  child: HammamDetailScreen(
                                    hammamId: hammamId,
                                    hammamName: name,
                                    selectedLanguage: widget.selectedLanguage,
                                    translations: widget.translations,
                                  ),
                                ),
                              ),
                            );
                          },
                          child: Text(
                            widget.selectedLanguage == 'Arabic' ? 'عرض الخدمات' : 'View Services',
                            style: const TextStyle(color: Colors.white),
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
    );
  }
}

class HammamDetailScreen extends StatefulWidget {
  final int hammamId;
  final String hammamName;
  final String selectedLanguage;
  final Map<String, Map<String, String>> translations;

  const HammamDetailScreen({
    super.key,
    required this.hammamId,
    required this.hammamName,
    required this.selectedLanguage,
    required this.translations,
  });

  @override
  State<HammamDetailScreen> createState() => _HammamDetailScreenState();
}

class _HammamDetailScreenState extends State<HammamDetailScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _hammamServices = [];
  bool _isLoading = true;
  String? _error;

  String _translate(String key) {
    return widget.translations[widget.selectedLanguage]?[key] ?? widget.translations['English']?[key] ?? key;
  }

  @override
  void initState() {
    super.initState();
    _loadHammamServices();
  }

  Future<void> _loadHammamServices() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      final services = await _apiService.getHammamServices(widget.hammamId);
      
      setState(() {
        _hammamServices = services;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F5),
      appBar: AppBar(
        title: Text(
          widget.hammamName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: const Color(0xFFF8BBD0),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFF8BBD0)))
        : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: $_error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadHammamServices,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF8BBD0),
                    ),
                    child: Text(
                      _translate('try_again'),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            )
          : _hammamServices.isEmpty
            ? Center(
                child: Text(
                  widget.selectedLanguage == 'Arabic'
                    ? 'لا توجد خدمات متاحة لهذا الحمام'
                    : 'No services available for this hammam',
                  style: const TextStyle(fontSize: 16),
                ),
              )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCategoryHeader(context, _translate('available_services')),
                        const SizedBox(height: 15),
                        ..._hammamServices.map((service) => _buildServiceCard(
                          context,
                          service['image']?.toString() ?? 'assets/images/hammam_nil.jpg',
                          service['name']?.toString() ?? 'Hammam Service',
                          service['phone']?.toString() ?? 'No phone',
                          service['id'] != null ? int.tryParse(service['id'].toString()) ?? 1 : 1,
                          service['price']?.toString() ?? '0.0',
                        )).toList(),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCategoryHeader(context, _translate('reviews')),
                        const SizedBox(height: 15),
                        ReviewSection(
                          serviceType: 'hammam',
                          serviceId: widget.hammamId,
                          serviceName: widget.hammamName,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCategoryHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Container(
            height: 24,
            width: 6,
            decoration: BoxDecoration(
              color: const Color(0xFFF06292),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF880E4F),
            ),
          ),
        ],
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
                child: ReservationsScreen(
                  selectedLanguage: widget.selectedLanguage,
                  translations: widget.translations,
                  serviceType: 'hammam',
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
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    image: isNetworkImage
                        ? DecorationImage(
                            image: NetworkImage(imagePath),
                            fit: BoxFit.cover,
                            onError: (exception, stackTrace) => Container(),
                          )
                        : DecorationImage(
                            image: AssetImage(imagePath),
                            fit: BoxFit.cover,
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF880E4F),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8BBD0).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$price MRU',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF880E4F),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8BBD0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}