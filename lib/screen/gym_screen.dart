import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/api_service.dart';
import 'reservation_screen.dart';

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
  List<dynamic> _gyms = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGyms();
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
                            gym['image']?.toString() ??
                                'assets/images/gim2.jpeg',
                            double.tryParse(
                                    gym['rating']?.toString() ?? '4.5') ??
                                4.5,
                            gym['name']?.toString() ?? 'Gym Name',
                            gym['location']?.toString() ?? 'Nouakchott',
                            '${gym['daily_price']?.toString() ?? '80'} MRU',
                            '${gym['monthly_price']?.toString() ?? '1500'} MRU',
                            (gym['amenities'] as List?)
                                    ?.map((e) => e.toString())
                                    .toList() ??
                                ['24/7', 'Equipment'],
                            gym['id'] != null
                                ? int.tryParse(gym['id'].toString()) ?? 1
                                : 1,
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
    double rating,
    String name,
    String location,
    String dailyPrice,
    String monthlyPrice,
    List<String> amenities,
    int gymId,
  ) {
    bool isNetworkImage = imagePath.startsWith('http');

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
                amenities: amenities,
                selectedLanguage: widget.selectedLanguage,
                translations: widget.translations,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gym image
                  Container(
                    width: 100,
                    height: 100,
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
                  // Gym details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            _buildRatingBadge(rating),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                size: 16, color: Colors.pink[300]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                location,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          children: amenities
                              .take(3)
                              .map((amenity) => Chip(
                                    label: Text(
                                      amenity,
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                    backgroundColor: Colors.grey[100],
                                    padding: EdgeInsets.zero,
                                    labelPadding: const EdgeInsets.symmetric(
                                        horizontal: 6),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Prices and visit button
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.selectedLanguage == 'Arabic'
                              ? 'سعر اليوم:'
                              : 'Day Pass:',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          dailyPrice,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF06292),
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
                          widget.selectedLanguage == 'Arabic'
                              ? 'الاشتراك الشهري:'
                              : 'Monthly:',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          monthlyPrice,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF06292),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF06292),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
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
                            amenities: amenities,
                            selectedLanguage: widget.selectedLanguage,
                            translations: widget.translations,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      widget.selectedLanguage == 'Arabic' ? 'زيارة' : 'Visit',
                      style: const TextStyle(
                        color: Colors.white,
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

  Widget _buildRatingBadge(double rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 2),
          Text(
            rating.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
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
                  amenities: (gym['amenities'] as List?)
                          ?.map((e) => e.toString())
                          .toList() ??
                      ['24/7', 'Equipment'],
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
                                        Container(                      decoration: BoxDecoration(                        color: Colors.grey[200],                        borderRadius: BorderRadius.circular(8),                      ),                      child: TabBar(                        controller: _tabController,                        labelColor: Colors.pink[800],                        unselectedLabelColor: Colors.grey[600],                        indicator: BoxDecoration(                          color: Colors.white,                          borderRadius: BorderRadius.circular(8),                          boxShadow: [                            BoxShadow(                              color: Colors.grey.withOpacity(0.2),                              blurRadius: 4,                              offset: const Offset(0, 2),                            ),                          ],                        ),
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
                      _buildReviewsTab(),
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
                builder: (context) => ReservationScreen(
                  productName:
                      '${widget.name} - ${widget.selectedLanguage == 'Arabic' ? 'اشتراك' : 'Membership'}',
                  serviceId: _gymServices.isNotEmpty
                      ? (_gymServices[0]['id'] != null
                          ? int.tryParse(_gymServices[0]['id'].toString()) ?? 1
                          : 1)
                      : 1,
                  selectedLanguage: widget.selectedLanguage,
                  translations: widget.translations,
                  serviceType: 'gym',
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
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(service['name']?.toString() ?? 'Service'),
            subtitle: Text(service['description']?.toString() ?? ''),
            trailing: Text(
              '${service['price']?.toString() ?? '0'} MRU',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.pink[800],
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReservationScreen(
                    productName: service['name']?.toString() ?? 'Service',
                    serviceId: service['id'] != null
                        ? int.tryParse(service['id'].toString()) ?? 1
                        : 1,
                    selectedLanguage: widget.selectedLanguage,
                    translations: widget.translations,
                    serviceType: 'gym',
                  ),
                ),
              );
            },
          ),
        );
      },
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

  Widget _buildReviewsTab() {
    final reviews = [
      {
        'name': 'Mohammed',
        'rating': 5,
        'comment': widget.selectedLanguage == 'Arabic'
            ? 'صالة ممتازة مع معدات حديثة'
            : 'Excellent gym with modern equipment',
        'date': '2023-09-15',
      },
      {
        'name': 'Sara',
        'rating': 4,
        'comment': widget.selectedLanguage == 'Arabic'
            ? 'المدربين محترفون ولكن ساعات العمل قصيرة جدًا'
            : 'Professional trainers but somewhat limited hours',
        'date': '2023-08-22',
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      review['name'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < (review['rating'] as int)
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(review['comment'] as String),
                const SizedBox(height: 4),
                Text(
                  DateFormat('yyyy-MM-dd')
                      .format(DateTime.parse(review['date'] as String)),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
