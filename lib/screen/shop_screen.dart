import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/wishlist_service.dart';
import 'AccessoriesScreen.dart';
import 'MlahfaScreen.dart';
import 'makeup_screen.dart';
import 'command_screen.dart';

class ShopScreen extends StatefulWidget {
  final String selectedLanguage;
  final Map<String, Map<String, String>> translations;
  
  const ShopScreen({
    super.key,
    required this.selectedLanguage,
    required this.translations,
  });

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final WishlistService _wishlistService = WishlistService();
  late TabController _tabController;
  bool _isLoading = true;
  List<dynamic> _melhfaItems = [];
  List<dynamic> _accessoryItems = [];
  List<dynamic> _makeupItems = [];
  // Track wishlist item IDs for UI updates
  Set<String> _wishlistItemIds = {};
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
    _loadWishlistIds();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Load all data in parallel
      final melhfaFuture = _apiService.getMelhfaTypes();
      final accessoriesFuture = _apiService.getAccessories();
      final makeupFuture = _apiService.getMakeupServices();
      
      // Wait for all futures to complete
      final results = await Future.wait([
        melhfaFuture,
        accessoriesFuture,
        makeupFuture,
      ]);
      
      setState(() {
        _melhfaItems = results[0];
        _accessoryItems = results[1];
        _makeupItems = results[2];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      // Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading items: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Load wishlist IDs for heart icon display
  Future<void> _loadWishlistIds() async {
    try {
      final wishlistItems = await _wishlistService.getWishlistItems();
      setState(() {
        _wishlistItemIds = wishlistItems
            .where((item) => item['id'] != null)
            .map((item) => item['id'].toString())
            .toSet();
      });
    } catch (e) {
      // Handle silently
    }
  }

  // Add item to wishlist
  Future<void> _addToWishlist(Map<String, dynamic> item) async {
    try {
      final success = await _wishlistService.addToWishlist(item);
      
      if (success) {
        setState(() {
          _wishlistItemIds.add(item['id'].toString());
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.selectedLanguage == 'Arabic'
                    ? 'تمت إضافة العنصر إلى المفضلة'
                    : 'Item added to wishlist',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Remove item from wishlist
  Future<void> _removeFromWishlist(dynamic id) async {
    try {
      final success = await _wishlistService.removeItemById(id);
      
      if (success) {
        setState(() {
          _wishlistItemIds.remove(id.toString());
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.selectedLanguage == 'Arabic'
                    ? 'تمت إزالة العنصر من المفضلة'
                    : 'Item removed from wishlist',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      // Handle error silently
    }
  }

  // Toggle wishlist status
  Future<void> _toggleWishlist(Map<String, dynamic> item) async {
    final id = item['id'].toString();
    
    if (_wishlistItemIds.contains(id)) {
      await _removeFromWishlist(id);
    } else {
      await _addToWishlist(item);
    }
  }

  String _translate(String key) {
    return widget.translations[widget.selectedLanguage]?[key] ?? 
           widget.translations['English']?[key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = widget.selectedLanguage == 'Arabic';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_translate('shop')),
        backgroundColor: Colors.pink[400],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          tabs: [
            Tab(text: _translate('mlahfa')),
            Tab(text: _translate('accessories')),
            Tab(text: _translate('makeup')),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Melhfa tab
                _buildMelhfaTab(),
                
                // Accessories tab
                _buildAccessoriesTab(),
                
                // Makeup tab
                _buildMakeupTab(),
              ],
            ),
    );
  }
  
  Widget _buildMelhfaTab() {
    return _melhfaItems.isEmpty
        ? Center(child: Text(_translate('no_items')))
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.59,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _melhfaItems.length,
              itemBuilder: (context, index) {
                final item = _melhfaItems[index];
                return _buildProductCard(
                  item['name'] ?? 'Melhfa',
                  item['arabic_name'] ?? item['name'] ?? 'ملحفة',
                  item['price']?.toString() ?? '0.00',
                  item['image'] ?? 'assets/images/placeholder.jpg',
                  item['id'] ?? 1,
                  true, // isNew
                );
              },
            ),
          );
  }
  
  Widget _buildAccessoriesTab() {
    return _accessoryItems.isEmpty
        ? Center(child: Text(_translate('no_items')))
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.59,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _accessoryItems.length,
              itemBuilder: (context, index) {
                final item = _accessoryItems[index];
                return _buildProductCard(
                  item['name'] ?? 'Accessory',
                  item['arabic_name'] ?? item['name'] ?? 'إكسسوار',
                  item['price']?.toString() ?? '0.00',
                  item['image_url'] ?? 'assets/images/placeholder.jpg',
                  item['id'] ?? 1,
                  false, // isNew
                );
              },
            ),
          );
  }
  
  Widget _buildMakeupTab() {
    return _makeupItems.isEmpty
        ? Center(child: Text(_translate('no_items')))
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.59,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _makeupItems.length,
              itemBuilder: (context, index) {
                final item = _makeupItems[index];
                return _buildProductCard(
                  item['name'] ?? 'Makeup',
                  item['arabic_name'] ?? item['name'] ?? 'مكياج',
                  item['price']?.toString() ?? '0.00',
                  item['image_url'] ?? 'assets/images/placeholder.jpg',
                  item['id'] ?? 1,
                  false, // isNew
                );
              },
            ),
          );
  }
  
  Widget _buildProductCard(
    String name,
    String arabicName,
    String price,
    String imagePath,
    int id,
    bool isNew,
  ) {
    final displayName = widget.selectedLanguage == 'Arabic' ? arabicName : name;
    final isNetworkImage = imagePath.startsWith('http');
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CommandScreen(
                productName: displayName,
                serviceId: id,
                selectedLanguage: widget.selectedLanguage,
                translations: widget.translations,
                productImage: imagePath,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image with wishlist icon
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: SizedBox(
                    height: 140,
                    width: double.infinity,
                    child: isNetworkImage
                        ? Image.network(
                            imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.image_not_supported, size: 40),
                            ),
                          )
                        : Image.asset(
                            imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.image_not_supported, size: 40),
                            ),
                          ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      _toggleWishlist({
                        'id': id,
                        'name': name,
                        'arabic_name': arabicName,
                        'price': price,
                        'image': imagePath,
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _wishlistItemIds.contains(id.toString())
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 20,
                        color: Colors.pink[400],
                      ),
                    ),
                  ),
                ),
                if (isNew)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.pink[400],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.selectedLanguage == 'Arabic' ? 'جديد' : 'NEW',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            
            // Product info
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$price MRU',
                    style: TextStyle(
                      color: Colors.pink[700],
                      fontWeight: FontWeight.bold,
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