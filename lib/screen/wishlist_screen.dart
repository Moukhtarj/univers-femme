import 'package:flutter/material.dart';
import '../services/wishlist_service.dart';
import 'command_screen.dart';

class WishlistScreen extends StatefulWidget {
  final String selectedLanguage;
  final Map<String, Map<String, String>> translations;
  
  const WishlistScreen({
    super.key,
    required this.selectedLanguage,
    required this.translations,
  });

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final WishlistService _wishlistService = WishlistService();
  List<Map<String, dynamic>> _wishlistItems = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadWishlistItems();
  }
  
  Future<void> _loadWishlistItems() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final items = await _wishlistService.getWishlistItems();
      setState(() {
        _wishlistItems = items;
      });
    } catch (e) {
      // Handle error silently
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _removeFromWishlist(int index) async {
    final item = _wishlistItems[index];
    
    setState(() {
      _wishlistItems.removeAt(index);
    });
    
    try {
      await _wishlistService.removeFromWishlist(index);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.selectedLanguage == 'Arabic'
                ? 'تم إزالة العنصر من المفضلة'
                : 'Item removed from wishlist',
          ),
          action: SnackBarAction(
            label: widget.selectedLanguage == 'Arabic' ? 'تراجع' : 'Undo',
            onPressed: () async {
              setState(() {
                _wishlistItems.insert(index, item);
              });
              await _wishlistService.addToWishlist(item);
            },
          ),
        ),
      );
    } catch (e) {
      // Restore item if removal fails
      setState(() {
        _wishlistItems.insert(index, item);
      });
    }
  }
  
  String _translate(String key) {
    return widget.translations[widget.selectedLanguage]?[key] ?? 
           widget.translations['English']?[key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_translate('wishlist')),
        backgroundColor: Colors.pink[400],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _wishlistItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        widget.selectedLanguage == 'Arabic'
                            ? 'لا توجد عناصر في المفضلة'
                            : 'No items in your wishlist',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.selectedLanguage == 'Arabic'
                            ? 'اضغط على أيقونة القلب لإضافة العناصر إلى المفضلة'
                            : 'Tap on the heart icon to add items to your wishlist',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _wishlistItems.length,
                  itemBuilder: (context, index) {
                    final item = _wishlistItems[index];
                    final name = widget.selectedLanguage == 'Arabic'
                        ? item['arabic_name'] ?? item['name'] ?? 'Item'
                        : item['name'] ?? 'Item';
                    final price = item['price']?.toString() ?? '0.00';
                    final imagePath = item['image_url'] ?? 'assets/images/placeholder.jpg';
                    final isNetworkImage = imagePath.startsWith('http');
                    
                    return Dismissible(
                      key: Key(item['id']?.toString() ?? index.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.red,
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                        ),
                      ),
                      onDismissed: (direction) => _removeFromWishlist(index),
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CommandScreen(
                                  productName: name,
                                  serviceId: item['id'] ?? 1,
                                  selectedLanguage: widget.selectedLanguage,
                                  translations: widget.translations,
                                  productImage: imagePath,
                                  productPrice: double.tryParse(price) ?? 0.0,
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Row(
                            children: [
                              // Product image
                              ClipRRect(
                                borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                                child: SizedBox(
                                  width: 120,
                                  height: 120,
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
                              
                              // Product info
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '$price MRU',
                                        style: TextStyle(
                                          color: Colors.pink[700],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          OutlinedButton(
                                            onPressed: () => _removeFromWishlist(index),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: Colors.pink[400],
                                              side: BorderSide(color: Colors.pink[400]!),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              padding: const EdgeInsets.symmetric(horizontal: 8),
                                            ),
                                            child: Text(
                                              widget.selectedLanguage == 'Arabic' ? 'إزالة' : 'Remove',
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => CommandScreen(
                                                    productName: name,
                                                    serviceId: item['id'] ?? 1,
                                                    selectedLanguage: widget.selectedLanguage,
                                                    translations: widget.translations,
                                                    productImage: imagePath,
                                                    productPrice: double.tryParse(price) ?? 0.0,
                                                  ),
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.pink[400],
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              padding: const EdgeInsets.symmetric(horizontal: 8),
                                            ),
                                            child: Text(
                                              widget.selectedLanguage == 'Arabic' ? 'طلب' : 'Order',
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
} 