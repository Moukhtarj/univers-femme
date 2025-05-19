import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import 'command_screen.dart';

class MelhfaScreen extends StatefulWidget {
  final String selectedLanguage;
  final Map<String, Map<String, String>> translations;
  
  const MelhfaScreen({
    super.key,
    required this.selectedLanguage,
    required this.translations,
  });

  @override
  State<MelhfaScreen> createState() => _MelhfaScreenState();
}

class _MelhfaScreenState extends State<MelhfaScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _melhfaTypes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchMelhfaTypes();
  }

  Future<void> _fetchMelhfaTypes() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final types = await _apiService.getMelhfaTypes();
      
      // Process types to ensure image URLs are complete
      for (var type in types) {
        if (type['image'] != null && type['image'].toString().isNotEmpty && !type['image'].toString().startsWith('http')) {
          // If the image path doesn't start with http, assume it's a relative path and prepend the base URL
          type['image'] = '${_apiService.baseUrl}${type['image']}';
        }
      }

      setState(() {
        _melhfaTypes = types;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
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
          widget.translations[widget.selectedLanguage]?['melhfa'] ?? 'Melhfa',
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
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFF06292)))
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchMelhfaTypes,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF06292),
                        ),
                        child: Text(
                          widget.translations[widget.selectedLanguage]?['tryAgain'] ?? 'Try Again',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: ListView(
                    children: [
                      const SizedBox(height: 10),
                      _buildCategoryHeader(context, widget.selectedLanguage == 'Arabic' ? 'أنواع الملاحف' : 'Types of Melhfas'),
                      const SizedBox(height: 15),
                      ..._melhfaTypes.map((type) => _buildMelhfaTypeCard(
                        context,
                        type['image']?.toString() ?? 'assets/images/m1.jpg',
                        type['name']?.toString() ?? 'Melhfa',
                        type['rating'] != null ? double.tryParse(type['rating'].toString()) ?? 4.5 : 4.5,
                        type['id'] != null ? int.tryParse(type['id'].toString()) ?? 1 : 1,
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

  Widget _buildMelhfaTypeCard(BuildContext context, String imagePath, String name, double rating, int typeId) {
    bool isNetworkImage = imagePath.startsWith('http');
    
    // Map the name to the type display name based on Django model choice field
    String typeDisplay = name;
    String description = '';
    
    // Map to the TYPE_CHOICES from the Django model
    if (name.toLowerCase() == 'gaz') {
      typeDisplay = widget.selectedLanguage == 'Arabic' ? 'غاز' : 'Gaz';
      description = widget.selectedLanguage == 'Arabic' ? 'ملحفة غاز تقليدية' : 'Traditional Gaz melhfa';
    } else if (name.toLowerCase() == 'karra') {
      typeDisplay = widget.selectedLanguage == 'Arabic' ? 'كرة' : 'Karra';
      description = widget.selectedLanguage == 'Arabic' ? 'ملحفة كرة مميزة' : 'Special Karra melhfa';
    } else if (name.toLowerCase() == 'khyata') {
      typeDisplay = widget.selectedLanguage == 'Arabic' ? 'خياطة' : 'Khyata';
      description = widget.selectedLanguage == 'Arabic' ? 'ملحفة خياطة فاخرة' : 'Luxury Khyata melhfa';
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
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
              builder: (context) => MelhfaListScreen(
                melhfaType: typeDisplay,
                typeId: typeId,
                selectedLanguage: widget.selectedLanguage,
                translations: widget.translations,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFF8BBD0).withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: isNetworkImage
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported, size: 25, color: Colors.grey),
                        ),
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported, size: 25, color: Colors.grey),
                        ),
                      ),
                    ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      typeDisplay,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF880E4F),
                      )),
                    const SizedBox(height: 4),
                    if (description.isNotEmpty)
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        RatingBarIndicator(
                          rating: rating,
                          itemBuilder: (context, index) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          itemCount: 5,
                          itemSize: 16,
                          direction: Axis.horizontal,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          rating.toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFFF06292)),
            ],
          ),
        ),
      ),
    );
  }
}

class MelhfaListScreen extends StatefulWidget {
  final String melhfaType;
  final int typeId;
  final String selectedLanguage;
  final Map<String, Map<String, String>> translations;
  
  const MelhfaListScreen({
    super.key,
    required this.melhfaType,
    required this.typeId,
    required this.selectedLanguage,
    required this.translations,
  });

  @override
  State<MelhfaListScreen> createState() => _MelhfaListScreenState();
}

class _MelhfaListScreenState extends State<MelhfaListScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _melhfaModels = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchMelhfaModels();
  }

  Future<void> _fetchMelhfaModels() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final models = await _apiService.getMelhfaModels(widget.typeId);
      
      // Process models to ensure image URLs are complete
      for (var model in models) {
        if (model['image'] != null && model['image'].toString().isNotEmpty && !model['image'].toString().startsWith('http')) {
          // If the image path doesn't start with http, assume it's a relative path and prepend the base URL
          model['image'] = '${_apiService.baseUrl}${model['image']}';
        }
      }

      setState(() {
        _melhfaModels = models;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
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
          widget.melhfaType,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
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
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFF06292)))
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchMelhfaModels,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF06292),
                        ),
                        child: Text(
                          widget.translations[widget.selectedLanguage]?['tryAgain'] ?? 'Try Again',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: ListView(
                    children: [
                      const SizedBox(height: 10),
                      _buildCategoryHeader(context, widget.selectedLanguage == 'Arabic' ? 'موديلات متوفرة' : 'Available Models'),
                      const SizedBox(height: 15),
                      ..._melhfaModels.map((model) => _buildMelhfaModelCard(
                        context,
                        model['image']?.toString() ?? 'assets/images/placeholder.jpg',
                        model['name']?.toString() ?? 'Melhfa Model',
                        model['price']?.toString() ?? '0',
                        model['id'] != null ? int.tryParse(model['id'].toString()) ?? 1 : 1,
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

  Widget _buildMelhfaModelCard(BuildContext context, String imagePath, String name, String price, int id) {
    bool isNetworkImage = imagePath.startsWith('http');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
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
              builder: (context) => CommandScreen(
                productName: name,
                serviceId: id,
                selectedLanguage: widget.selectedLanguage,
                translations: widget.translations,
                productImage: imagePath,
                productPrice: double.tryParse(price) ?? 0.0,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              child: isNetworkImage
                ? Image.network(
                    imagePath,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                    ),
                  )
                : Image.asset(
                    imagePath,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                    ),
                  ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF880E4F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.selectedLanguage == 'Arabic' ? 'السعر: ' : 'Price: '} $price MRU',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.pink[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CommandScreen(
                              productName: name,
                              serviceId: id,
                              selectedLanguage: widget.selectedLanguage,
                              translations: widget.translations,
                              productImage: imagePath,
                              productPrice: double.tryParse(price) ?? 0.0,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF06292),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        widget.selectedLanguage == 'Arabic' ? 'طلب شراء' : 'Order Now',
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
          ],
        ),
      ),
    );
  }
}