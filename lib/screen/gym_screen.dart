import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/location_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:location/location.dart' show LocationData;
import '../services/api_service.dart';
import 'reservations_screen.dart';
import '../widgets/review_section.dart';

class GymScreen extends StatefulWidget {
  final String selectedLanguage;
  final Map<String, Map<String, String>> translations;

  const GymScreen({
    super.key,
    required this.selectedLanguage,
    required this.translations,
  });

  @override
  State<GymScreen> createState() => _GymScreenState();
}

class _GymScreenState extends State<GymScreen> {
  final ApiService _apiService = ApiService();
  final LocationService _locationService = LocationService();
  List<dynamic> _gyms = [];
  bool _isLoading = true;
  String? _error;
  LocationData? _currentLocation;

  @override
  void initState() {
    super.initState();
    _loadGyms();
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

  String _translate(String key) {
    return widget.translations[widget.selectedLanguage]?[key] ??
        widget.translations['English']?[key] ??
        key;
  }

  Future<void> _loadGyms() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final gyms = await _apiService.getGyms();

      setState(() {
        _gyms = gyms;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          _translate('gym'),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFFF8BBD0),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: GymSearchDelegate(
                  selectedLanguage: widget.selectedLanguage,
                  translations: widget.translations,
                  gyms: _gyms,
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFF8BBD0)))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadGyms,
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
              : _gyms.isEmpty
                  ? Center(
                      child: Text(
                        widget.selectedLanguage == 'Arabic'
                            ? 'لا توجد صالات رياضية متاحة حالياً'
                            : 'No gyms available',
                        style: const TextStyle(fontSize: 16),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: _gyms.length,
                        itemBuilder: (context, index) {
                          final gym = _gyms[index];
                          return _buildGymCard(
                            context,
                            gym['image']?.toString() ?? 'assets/images/gym_nil.jpg',
                            gym['name']?.toString() ?? 'Gym',
                            gym['location']?.toString() ?? _translate('main_street_nouakchott'),
                            (gym['rating'] != null) ? double.tryParse(gym['rating'].toString()) ?? 4.5 : 4.5,
                            gym['daily_price']?.toString() ?? '0.0',
                            gym['monthly_price']?.toString() ?? '0.0',
                            gym['amenities']?.toString() ?? '',
                            gym['id'] != null ? int.tryParse(gym['id'].toString()) ?? 1 : 1,
                            double.tryParse(gym['latitude']?.toString() ?? ''),
                            double.tryParse(gym['longitude']?.toString() ?? ''),
                          )
                              .animate()
                              .fadeIn(duration: 300.ms)
                              .slideX(begin: 0.1);
                        },
                      ),
                    ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, bool selected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (bool value) {},
        selectedColor: Colors.pink[100],
        checkmarkColor: Colors.pink,
        labelStyle: TextStyle(
          color: selected ? Colors.pink : Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildGymCard(
    BuildContext context,
    String imagePath,
    String name,
    String location,
    double rating,
    String dailyPrice,
    String monthlyPrice,
    String amenities,
    int gymId,
    double? latitude,
    double? longitude,
  ) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      elevation: 4,
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GymDetailsScreen(
                gymId: gymId,
                imagePath: imagePath,
                rating: rating,
                name: name,
                location: location,
                dailyPrice: dailyPrice,
                monthlyPrice: monthlyPrice,
                amenities: amenities.split(','),
                selectedLanguage: widget.selectedLanguage,
                translations: widget.translations,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: imagePath.startsWith('http')
                  ? Image.network(
                      imagePath,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.fitness_center, size: 60, color: Colors.grey),
                        ),
                      ),
                    )
                  : Image.asset(
                      imagePath,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.fitness_center, size: 60, color: Colors.grey),
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
                            fontSize: 20,
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.selectedLanguage == 'Arabic' ? 'السعر اليومي' : 'Daily Price',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              dailyPrice,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF880E4F),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.selectedLanguage == 'Arabic' ? 'السعر الشهري' : 'Monthly Price',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              monthlyPrice,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF880E4F),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: amenities.split(',').map((amenity) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8BBD0).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          amenity,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF880E4F),
                          ),
                        ),
                      );
                    }).toList(),
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

class GymSearchDelegate extends SearchDelegate<String> {
  final String selectedLanguage;
  final Map<String, Map<String, String>> translations;
  final List<dynamic> gyms;

  GymSearchDelegate({
    required this.selectedLanguage,
    required this.translations,
    required this.gyms,
  });

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final filteredGyms = gyms
        .where((gym) => (gym['name']?.toString().toLowerCase() ?? '')
            .contains(query.toLowerCase()))
        .toList();

    if (filteredGyms.isEmpty) {
      return Center(
        child: Text(
          selectedLanguage == 'Arabic' ? 'لا توجد نتائج' : 'No results found',
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredGyms.length,
      itemBuilder: (context, index) {
        final gym = filteredGyms[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: AssetImage(
                gym['image']?.toString() ?? 'assets/images/gim2.jpeg'),
          ),
          title: Text(gym['name']?.toString() ?? 'Gym Name'),
          subtitle: Text(gym['location']?.toString() ?? 'Location'),
          trailing: Text('${gym['daily_price']?.toString() ?? '80'} MRU'),
          onTap: () {
            close(context, gym['id']?.toString() ?? '1');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GymDetailsScreen(
                  gymId: gym['id'] != null
                      ? int.tryParse(gym['id'].toString()) ?? 1
                      : 1,
                  imagePath:
                      gym['image']?.toString() ?? 'assets/images/gim2.jpeg',
                  rating: double.tryParse(gym['rating']?.toString() ?? '4.5') ??
                      4.5,
                  name: gym['name']?.toString() ?? 'Gym Name',
                  location: gym['location']?.toString() ?? 'Nouakchott',
                  dailyPrice: '${gym['daily_price']?.toString() ?? '80'} MRU',
                  monthlyPrice:
                      '${gym['monthly_price']?.toString() ?? '1500'} MRU',
                  amenities: gym['amenities']?.split(',') ?? ['24/7', 'Equipment'],
                  selectedLanguage: selectedLanguage,
                  translations: translations,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class GymDetailsScreen extends StatefulWidget {
  final int gymId;
  final String imagePath;
  final double rating;
  final String name;
  final String location;
  final String dailyPrice;
  final String monthlyPrice;
  final List<String> amenities;
  final String selectedLanguage;
  final Map<String, Map<String, String>> translations;

  const GymDetailsScreen({
    super.key,
    required this.gymId,
    required this.imagePath,
    required this.rating,
    required this.name,
    required this.location,
    required this.dailyPrice,
    required this.monthlyPrice,
    required this.amenities,
    required this.selectedLanguage,
    required this.translations,
  });

  @override
  State<GymDetailsScreen> createState() => _GymDetailsScreenState();
}

class _GymDetailsScreenState extends State<GymDetailsScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  List<dynamic> _gymServices = [];
  bool _isLoading = true;
  String? _error;
  int _selectedTab = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _loadGymServices();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTab = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _translate(String key) {
    return widget.translations[widget.selectedLanguage]?[key] ??
        widget.translations['English']?[key] ??
        key;
  }

  Future<void> _loadGymServices() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final services = await _apiService.getGymServices(widget.gymId);

      setState(() {
        _gymServices = services;
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
    bool isNetworkImage = widget.imagePath.startsWith('http');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 2),
                      blurRadius: 4,
                      color: Color.fromRGBO(0, 0, 0, 0.5),
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  isNetworkImage
                      ? Image.network(
                          widget.imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset(
                            'assets/images/gim2.jpeg',
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.asset(
                          widget.imagePath,
                          fit: BoxFit.cover,
                        ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                size: 16, color: Colors.pink[300]),
                            const SizedBox(width: 4),
                            Text(
                              widget.location,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              widget.rating.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.pink[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  widget.selectedLanguage == 'Arabic'
                                      ? 'اليومي'
                                      : 'Day Pass',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  widget.dailyPrice,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.pink[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.pink[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  widget.selectedLanguage == 'Arabic'
                                      ? 'الشهري'
                                      : 'Monthly Pass',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  widget.monthlyPrice,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.pink[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.selectedLanguage == 'Arabic'
                          ? 'الميزات:'
                          : 'Amenities:',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.amenities
                          .map((amenity) => Chip(
                                label: Text(amenity),
                                backgroundColor: Colors.grey[100],
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        labelColor: Colors.pink[800],
                        unselectedLabelColor: Colors.grey[600],
                        indicator: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        tabs: [
                          Tab(
                              text: widget.selectedLanguage == 'Arabic'
                                  ? 'الخدمات'
                                  : 'Services'),
                          Tab(
                              text: widget.selectedLanguage == 'Arabic'
                                  ? 'الجدول'
                                  : 'Schedule'),
                          Tab(
                              text: widget.selectedLanguage == 'Arabic'
                                  ? 'المراجعات'
                                  : 'Reviews'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_error != null)
                      Center(
                        child: Column(
                          children: [
                            Text('Error: $_error'),
                            ElevatedButton(
                              onPressed: _loadGymServices,
                              child: Text(_translate('try_again')),
                            ),
                          ],
                        ),
                      )
                    else if (_selectedTab == 0)
                      _buildServicesTab()
                    else if (_selectedTab == 1)
                      _buildScheduleTab()
                    else
                      ReviewSection(
                        serviceType: 'gym',
                        serviceId: widget.gymId,
                        serviceName: widget.name,
                      )
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_gymServices.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReservationsScreen(
                  selectedLanguage: widget.selectedLanguage,
                  translations: widget.translations,
                  serviceType: 'gym',
                  serviceId: _gymServices[0]['id'],
                ),
              ),
            );
          }
        },
        backgroundColor: Colors.pink[800],
        label: Text(
            widget.selectedLanguage == 'Arabic' ? 'احجز الآن' : 'Book Now'),
        icon: const Icon(Icons.fitness_center),
      ),
    );
  }

  Widget _buildServicesTab() {
    if (_gymServices.isEmpty) {
      return Center(
        child: Text(
          widget.selectedLanguage == 'Arabic'
              ? 'لا توجد خدمات متاحة'
              : 'No services available',
          style: const TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _gymServices.length,
      itemBuilder: (context, index) {
        final service = _gymServices[index];
        return _buildServiceCard(
          context,
          service['image']?.toString() ?? 'assets/images/gim2.jpeg',
          service['name']?.toString() ?? 'Service',
          service['phone']?.toString() ?? '',
          service['id'] != null ? int.tryParse(service['id'].toString()) ?? 1 : 1,
          '${service['price']?.toString() ?? '0'} MRU',
          service,
        );
      },
    );
  }

  Widget _buildServiceCard(BuildContext context, String imagePath, String serviceName, String phoneNumber, int serviceId, String price, Map<String, dynamic> service) {
    bool isNetworkImage = imagePath.startsWith('http');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GymDetailsScreen(
                    gymId: serviceId,
                    imagePath: imagePath,
                    rating: double.tryParse(service['rating']?.toString() ?? '4.5') ?? 4.5,
                    name: serviceName,
                    location: service['location']?.toString() ?? 'Nouakchott',
                    dailyPrice: price,
                    monthlyPrice: service['monthly_price']?.toString() ?? '1500 MRU',
                    amenities: service['amenities']?.split(',') ?? ['24/7', 'Equipment'],
                    selectedLanguage: widget.selectedLanguage,
                    translations: widget.translations,
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
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
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
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          phoneNumber,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    price,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF06292),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTab() {
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    final daysArabic = [
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد'
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: days.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.selectedLanguage == 'Arabic'
                      ? daysArabic[index]
                      : days[index],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text('06:00 - 22:00'),
              ],
            ),
          ),
        );
      },
    );
  }
}
