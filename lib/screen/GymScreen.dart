import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GymScreen extends StatelessWidget {
  final String selectedLanguage;
  final Map<String, Map<String, String>> translations;
  
  const GymScreen({
    super.key,
    required this.selectedLanguage,
    required this.translations,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          translations[selectedLanguage]!['gym']!,
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
                  selectedLanguage: selectedLanguage,
                  translations: translations,
                ),
              );
            },
          ),
        ],
      ),
       body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          _buildGymCard(
            context,
            'assets/images/gim2.jpeg',
            4.5,
            translations[selectedLanguage]!['viking_gym'] ?? 'Viking Fitness Club',
            translations[selectedLanguage]!['tevragh_location'] ?? 'Nouakchott, Tevragh Zeina',
            '80 MRU',
            '1500 MRU',
            ['24/7', 'Pool', 'Sauna'],
          ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1),
          const SizedBox(height: 16),
          _buildGymCard(
            context,
            'assets/images/gim.jpg',
            4.2,
            translations[selectedLanguage]!['golden_gym'] ?? 'Golden Power Gym',
            translations[selectedLanguage]!['riyadh_location'] ?? 'Nouakchott, El Riyadh',
            '80 MRU',
            '1500 MRU',
            ['24/7', 'Pool', 'Sauna'],
          ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1),
          const SizedBox(height: 16), 
            _buildGymCard(
            context,
            'assets/images/gim.jpg',
            4.2,
            translations[selectedLanguage]!['golden_gym'] ?? 'Golden Power Gym',
            translations[selectedLanguage]!['riyadh_location'] ?? 'Nouakchott, El Riyadh',
            '80 MRU',
            '1500 MRU',
            ['24/7', 'Pool', 'Sauna'],
          ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1),

    ]),
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
              imagePath: imagePath,
              rating: rating,
              name: name,
              location: location,
              dailyPrice: dailyPrice,
              monthlyPrice: monthlyPrice,
              amenities: amenities,
              selectedLanguage: selectedLanguage,
              translations: translations,
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
                    image: DecorationImage(
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
                          Icon(Icons.location_on, size: 16, color: Colors.pink[300]),
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
                        spacing: 8,
                        runSpacing: 8,
                        children: amenities.take(2).map((amenity) => _buildAmenityChip(amenity)).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPriceTag(
                  translations[selectedLanguage]!['day'] ?? 'Day',
                  dailyPrice,
                ),
                _buildPriceTag(
                  translations[selectedLanguage]!['month'] ?? 'Month',
                  monthlyPrice,
                ),
                SizedBox(
                  width: 100,
                  height: 36,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SubscriptionScreen(
                            gymName: name,
                            dailyPrice: dailyPrice,
                            monthlyPrice: monthlyPrice,
                            selectedLanguage: selectedLanguage,
                            translations: translations,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      translations[selectedLanguage]!['subscribe'] ?? 'Subscribe',
                      style: const TextStyle(
                        fontSize: 12,
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
    ),
  );
}
  Widget _buildRatingBadge(double rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 16, color: Colors.amber),
          const SizedBox(width: 4),
          Text(
            rating.toString(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenityChip(String amenity) {
    return Chip(
      label: Text(
        amenity,
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: Colors.grey[100],
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildPriceTag(String duration, String price) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          duration,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Text(
          price,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.pink[800],
          ),
        ),
      ],
    );
  }
}

class GymDetailsScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(
                imagePath,
                fit: BoxFit.cover,
              ),
            ),
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {},
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildRatingBadge(rating),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.pink[300]),
                      const SizedBox(width: 4),
                      Text(
                        location,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    translations[selectedLanguage]!['about'] ?? 'About this gym',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    translations[selectedLanguage]!['gym_description'] ?? 
                    'Modern fitness center with state-of-the-art equipment and professional trainers. Suitable for all fitness levels.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    translations[selectedLanguage]!['amenities'] ?? 'Amenities',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: amenities.map((amenity) => _buildAmenityChip(amenity)).toList(),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildPriceOption(
                        translations[selectedLanguage]!['day_pass'] ?? 'Day Pass',
                        dailyPrice,
                      ),
                      _buildPriceOption(
                        translations[selectedLanguage]!['monthly'] ?? 'Monthly',
                        monthlyPrice,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink[400],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubscriptionScreen(
                              gymName: name,
                              dailyPrice: dailyPrice,
                              monthlyPrice: monthlyPrice,
                              selectedLanguage: selectedLanguage,
                              translations: translations,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        translations[selectedLanguage]!['subscribe_now'] ?? 'Subscribe Now',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
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

  Widget _buildRatingBadge(double rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 16, color: Colors.amber),
          const SizedBox(width: 4),
          Text(
            rating.toString(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenityChip(String amenity) {
    return Chip(
      label: Text(amenity),
      backgroundColor: Colors.grey[100],
      avatar: Icon(
        _getAmenityIcon(amenity),
        size: 16,
        color: Colors.pink,
      ),
    );
  }

  IconData _getAmenityIcon(String amenity) {
    switch (amenity.toLowerCase()) {
      case 'pool':
        return Icons.pool;
      case 'sauna':
        return Icons.thermostat;
      case 'personal trainer':
        return Icons.person;
      case 'yoga':
        return Icons.self_improvement;
      case 'spa':
        return Icons.spa;
      case 'café':
        return Icons.local_cafe;
      case 'parking':
        return Icons.local_parking;
      case '24/7':
        return Icons.access_time;
      default:
        return Icons.check;
    }
  }

  Widget _buildPriceOption(String title, String price) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.pink[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            price,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.pink[800],
            ),
          ),
        ],
      ),
    );
  }
}

class GymSearchDelegate extends SearchDelegate {
  final String selectedLanguage;
  final Map<String, Map<String, String>> translations;

  GymSearchDelegate({
    required this.selectedLanguage,
    required this.translations,
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
        close(context, null);
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
    final List<Map<String, dynamic>> gyms = [
      {
        'name': translations[selectedLanguage]!['viking_gym'] ?? 'Viking Fitness Club',
        'location': translations[selectedLanguage]!['tevragh_location'] ?? 'Nouakchott, Tevragh Zeina',
        'image': 'assets/images/gim2.jpeg',
        'rating': 4.5,
      },
      {
        'name': translations[selectedLanguage]!['golden_gym'] ?? 'Golden Power Gym',
        'location': translations[selectedLanguage]!['riyadh_location'] ?? 'Nouakchott, El Riyadh',
        'image': 'assets/images/gim.jpg',
        'rating': 4.2,
      },
      {
        'name': translations[selectedLanguage]!['fitness_center'] ?? 'Fitness Center',
        'location': translations[selectedLanguage]!['ksar_location'] ?? 'Nouakchott, El Ksar',
        'image': 'assets/images/gim3.jpg',
        'rating': 4.8,
      },
    ];

    final List<Map<String, dynamic>> results = query.isEmpty
        ? gyms
        : gyms.where((gym) => gym['name'].toLowerCase().contains(query.toLowerCase())).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final gym = results[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: AssetImage(gym['image']),
          ),
          title: Text(gym['name']),
          subtitle: Text(gym['location']),
          trailing: Chip(
            label: Text(gym['rating'].toString()),
            avatar: const Icon(Icons.star, size: 16),
          ),
          onTap: () {
            close(context, null);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GymDetailsScreen(
                  imagePath: gym['image'],
                  rating: gym['rating'],
                  name: gym['name'],
                  location: gym['location'],
                  dailyPrice: '80 MRU',
                  monthlyPrice: '1500 MRU',
                  amenities: ['24/7', 'Pool', 'Sauna'],
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

// Keep your existing SubscriptionScreen class as is

class SubscriptionScreen extends StatefulWidget {
  final String gymName;
  final String dailyPrice;
  final String monthlyPrice;
  final String selectedLanguage;
  final Map<String, Map<String, String>> translations;

  const SubscriptionScreen({
    super.key,
    required this.gymName,
    required this.dailyPrice,
    required this.monthlyPrice,
    required this.selectedLanguage,
    required this.translations,
  });

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  String _subscriptionType = 'daily';
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.pink[400]!,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(widget.translations[widget.selectedLanguage]!['success'] ?? 'Success'),
            content: Text(
              '${widget.translations[widget.selectedLanguage]!['subscription_success'] ?? 'Subscription successful for'} ${widget.gymName}',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Return to previous screen
                },
                child: Text(widget.translations[widget.selectedLanguage]!['ok'] ?? 'OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = widget.selectedLanguage == 'Arabic';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.translations[widget.selectedLanguage]!['subscription'] ?? 'Subscription'),
        backgroundColor: const Color(0xFFF8BBD0),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gym name header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                )],
                ),
                child: Row(
                  children: [
                    Icon(Icons.fitness_center, color: Colors.pink[400]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.gymName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Subscription type
              Text(
                widget.translations[widget.selectedLanguage]!['subscription_type'] ?? 'Subscription Type',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    RadioListTile(
                      title: Text(
                        '${widget.translations[widget.selectedLanguage]!['one_day'] ?? '1 Day'} (${widget.dailyPrice})',
                      ),
                      value: 'daily',
                      groupValue: _subscriptionType,
                      activeColor: Colors.pink[400],
                      onChanged: (value) {
                        setState(() {
                          _subscriptionType = value.toString();
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                    const Divider(height: 1),
                    RadioListTile(
                      title: Text(
                        '${widget.translations[widget.selectedLanguage]!['one_month'] ?? '1 Month'} (${widget.monthlyPrice})',
                      ),
                      value: 'monthly',
                      groupValue: _subscriptionType,
                      activeColor: Colors.pink[400],
                      onChanged: (value) {
                        setState(() {
                          _subscriptionType = value.toString();
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Personal information
              Text(
                widget.translations[widget.selectedLanguage]!['personal_info'] ?? 'Personal Information',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: widget.translations[widget.selectedLanguage]!['full_name'] ?? 'Full Name',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return widget.translations[widget.selectedLanguage]!['name_required'] ?? 'Name is required';
                        }
                        if (value.length < 3) {
                          return widget.translations[widget.selectedLanguage]!['name_length'] ?? 'Name too short';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: widget.translations[widget.selectedLanguage]!['phone'] ?? 'Phone Number',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.phone_outlined),
                        prefixText: isArabic ? null : '+222 ',
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return widget.translations[widget.selectedLanguage]!['phone_required'] ?? 'Phone is required';
                        }
                        if (!RegExp(r'^[234]\d{7}$').hasMatch(value)) {
                          return widget.translations[widget.selectedLanguage]!['phone_invalid'] ?? 'Invalid phone number';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Start date
              Text(
                widget.translations[widget.selectedLanguage]!['start_date'] ?? 'Start Date',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: widget.translations[widget.selectedLanguage]!['select_date'] ?? 'Select Date',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return widget.translations[widget.selectedLanguage]!['date_required'] ?? 'Date is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _submitForm,
                  child: Text(
                    widget.translations[widget.selectedLanguage]!['confirm_subscription'] ?? 'Confirm Subscription',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}