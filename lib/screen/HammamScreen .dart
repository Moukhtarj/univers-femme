import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'reservation_screen.dart';
import '../services/api_service.dart';

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
  List<dynamic> _hammams = [];
  bool _isLoading = true;
  String? _error;

  // Helper method to get translated text with fallback
  String _translate(String key) {
    return widget.translations[widget.selectedLanguage]?[key] ?? widget.translations['English']?[key] ?? key;
  }

  @override
  void initState() {
    super.initState();
    _loadHammams();
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
                  _buildCategoryHeader(context, _translate('mauritanian_hammams')),
                  const SizedBox(height: 15),
                  ..._hammams.map((hammam) => _buildHammamCard(
                    context,
                    hammam['image']?.toString() ?? 'assets/images/hammam_nil.jpg',
                    hammam['name']?.toString() ?? 'Hammam',
                    hammam['location']?.toString() ?? _getTranslatedAddress('main_street_nouakchott'),
                    (hammam['rating'] != null) ? double.tryParse(hammam['rating'].toString()) ?? 4.5 : 4.5,
                    hammam['hours']?.toString() ?? _getOperatingHours('8_22'),
                    hammam['id'] != null ? int.tryParse(hammam['id'].toString()) ?? 1 : 1,
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
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: ListView(
                children: [
                  const SizedBox(height: 10),
                  _buildCategoryHeader(context, _translate('available_services')),
                  const SizedBox(height: 15),
                  ..._hammamServices.map((service) => _buildServiceCard(
                    context,
                    service['name']?.toString() ?? 'Hammam Service',
                    service['description']?.toString() ?? 'No description',
                    service['price']?.toString() ?? '0.0',
                    service['duration']?.toString() ?? '60',
                    service['id'] != null ? int.tryParse(service['id'].toString()) ?? 1 : 1,
                  )).toList(),
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
    String name,
    String description,
    String price,
    String duration,
    int serviceId,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
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
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8BBD0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$price MRU',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.timer, color: Color(0xFFF06292), size: 16),
                const SizedBox(width: 4),
                Text(
                  widget.selectedLanguage == 'Arabic' 
                      ? '$duration دقيقة' 
                      : '$duration minutes',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF06292),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
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
                          productName: name,
                          serviceId: serviceId,
                          selectedLanguage: widget.selectedLanguage,
                          translations: widget.translations,
                          serviceType: 'hammam',
                        ),
                      ),
                    ),
                  );
                },
                child: Text(
                  widget.selectedLanguage == 'Arabic' ? 'حجز' : 'Book Now',
                  style: const TextStyle(
                    color: Colors.white,
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