import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'reservation_scre.dart';
import 'command_screen.dart';

class AccessoriesScreen extends StatefulWidget {
  final String selectedLanguage;
  final Map<String, Map<String, String>> translations;
  
  const AccessoriesScreen({
    super.key,
    required this.selectedLanguage,
    required this.translations,
  });

  @override
  State<AccessoriesScreen> createState() => _AccessoriesScreenState();
}

class _AccessoriesScreenState extends State<AccessoriesScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _accessories = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  final List<Map<String, dynamic>> _cartItems = [];

  @override
  void initState() {
    super.initState();
    _loadAccessories();
  }

  String _translate(String key) {
    return widget.translations[widget.selectedLanguage]?[key] ?? 
           widget.translations['English']?[key] ?? key;
  }

  Future<void> _loadAccessories() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      final accessories = await _apiService.getAccessories();
      
      setState(() {
        _accessories = accessories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<dynamic> get _filteredProducts {
    if (_accessories.isEmpty) return [];
    
    return _accessories.where((product) {
      final name = product['name']?.toString() ?? '';
      final category = product['category']?.toString() ?? '';
      
      final matchesSearch = _searchQuery.isEmpty ||
          name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' || 
          category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(_translate('accessories')),
        backgroundColor: Colors.pink[400],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: AccessoriesSearchDelegate(
                  language: widget.selectedLanguage,
                  products: _accessories,
                  onProductSelected: (product) {
                    _showAddToCartDialog(context, product);
                  },
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartScreen(
                    cartItems: _cartItems,
                    selectedLanguage: widget.selectedLanguage,
                    translations: widget.translations,
                  ),
                ),
              );
            },
          ),
        ],
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
                    onPressed: _loadAccessories,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink[400],
                    ),
                    child: Text(
                      _translate('try_again'),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            )
          : _accessories.isEmpty
            ? Center(
                child: Text(
                  widget.selectedLanguage == 'Arabic'
                    ? 'لا توجد اكسسوارات متاحة حالياً'
                    : 'No accessories available',
                  style: const TextStyle(fontSize: 16),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category filters
                    SizedBox(
                      height: 50,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildCategoryChip('All', widget.selectedLanguage == 'Arabic' ? 'الكل' : 'All'),
                          ..._getCategoriesFromProducts().map((category) => 
                            _buildCategoryChip(
                              category, 
                              widget.selectedLanguage == 'Arabic' 
                                ? _getArabicCategory(category) 
                                : category
                            )
                          ).toList(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Featured section
                    Text(
                      widget.selectedLanguage == 'Arabic' ? 'منتجات مميزة' : 'Featured Products',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    // Products grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.55,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        return _buildProductCard(context, product);
                      },
                    ),
                  ],
                ),
              ),
    );
  }

  List<String> _getCategoriesFromProducts() {
    final categories = _accessories
        .map((product) => product['category']?.toString() ?? '')
        .where((category) => category.isNotEmpty)
        .toSet()
        .toList();
    return categories;
  }

  String _getArabicCategory(String englishCategory) {
    final categoryMap = {
      'Jewelry': 'مجوهرات',
      'Bags': 'حقائب',
      'Scarves': 'أوشحة',
      'Hair': 'إكسسوارات شعر',
    };
    return categoryMap[englishCategory] ?? englishCategory;
  }

  Widget _buildCategoryChip(String category, String label) {
    final isSelected = _selectedCategory == category;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (bool selected) {
          setState(() {
            _selectedCategory = selected ? category : 'All';
          });
        },
        backgroundColor: Colors.grey[200],
        selectedColor: Colors.pink[100],
        checkmarkColor: Colors.pink[700],
        labelStyle: TextStyle(
          color: isSelected ? Colors.pink[700] : Colors.grey[800],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, dynamic product) {
    final name = widget.selectedLanguage == 'Arabic'
        ? product['arabic_name']?.toString() ?? product['name']?.toString() ?? 'Product'
        : product['name']?.toString() ?? 'Product';
    
    final description = widget.selectedLanguage == 'Arabic'
        ? product['arabic_description']?.toString() ?? product['description']?.toString() ?? ''
        : product['description']?.toString() ?? '';
    
    final price = product['price']?.toString() ?? '0.00';
    final imagePath = product['image_url']?.toString() ?? 'assets/images/placeholder.jpg';
    final isNew = product['is_new'] == true;
    final isNetworkImage = imagePath.startsWith('http');
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showProductDetails(context, product),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with "New" badge if applicable
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: SizedBox(
                    height: 120,
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
                if (isNew)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red[400],
                        borderRadius: BorderRadius.circular(4),
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
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          '$price MRU',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.pink[700],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add_shopping_cart, color: Colors.pink[400], size: 20),
                        onPressed: () => _showAddToCartDialog(context, product),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
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

  void _showProductDetails(BuildContext context, dynamic product) {
    final name = widget.selectedLanguage == 'Arabic'
        ? product['arabic_name']?.toString() ?? product['name']?.toString() ?? 'Product'
        : product['name']?.toString() ?? 'Product';
    
    final description = widget.selectedLanguage == 'Arabic'
        ? product['arabic_description']?.toString() ?? product['description']?.toString() ?? ''
        : product['description']?.toString() ?? '';
    
    final price = product['price']?.toString() ?? '0.00';
    final imagePath = product['image_url']?.toString() ?? 'assets/images/placeholder.jpg';
    final productId = product['id'] != null ? int.tryParse(product['id'].toString()) ?? 1 : 1;
    final isNetworkImage = imagePath.startsWith('http');
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Close handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            // Product image
            SizedBox(
              height: 250,
              child: isNetworkImage
                  ? Image.network(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported, size: 80),
                      ),
                    )
                  : Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported, size: 80),
                      ),
                    ),
            ),
            
            // Product info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
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
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.pink[50],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '$price MRU',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.pink[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.selectedLanguage == 'Arabic' ? 'الوصف:' : 'Description:',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.shopping_cart),
                            label: Text(
                              widget.selectedLanguage == 'Arabic' ? 'إضافة إلى السلة' : 'Add to Cart'
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink[400],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              _showAddToCartDialog(context, product);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.shopping_bag),
                            label: Text(
                              widget.selectedLanguage == 'Arabic' ? 'شراء الآن' : 'Buy Now'
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink[700],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Directionality(
                                    textDirection: widget.selectedLanguage == 'Arabic'
                                        ? TextDirection.rtl
                                        : TextDirection.ltr,
                                    child: CommandScreen(
                                      productName: name,
                                      serviceId: productId,
                                      selectedLanguage: widget.selectedLanguage,
                                      translations: widget.translations,
                                      productImage: imagePath,
                                      productPrice: double.tryParse(price) ?? 0.0,
                                    ),
                                  ),
                                ),
                              );
                            },
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
    );
  }

  void _showAddToCartDialog(BuildContext context, dynamic product) {
    final name = widget.selectedLanguage == 'Arabic'
        ? product['arabic_name']?.toString() ?? product['name']?.toString() ?? 'Product'
        : product['name']?.toString() ?? 'Product';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          widget.selectedLanguage == 'Arabic' ? 'إضافة إلى السلة' : 'Add to Cart',
        ),
        content: Text(
          widget.selectedLanguage == 'Arabic'
              ? 'هل تريد إضافة $name إلى سلة التسوق؟'
              : 'Do you want to add $name to your cart?',
        ),
        actions: [
          TextButton(
            child: Text(
              widget.selectedLanguage == 'Arabic' ? 'إلغاء' : 'Cancel',
              style: TextStyle(color: Colors.grey[700]),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink[400],
            ),
            child: Text(
              widget.selectedLanguage == 'Arabic' ? 'إضافة' : 'Add',
              style: const TextStyle(color: Colors.white),
            ),
            onPressed: () {
              _addToCart(product);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    widget.selectedLanguage == 'Arabic'
                        ? 'تمت إضافة $name إلى السلة'
                        : '$name added to cart',
                  ),
                  backgroundColor: Colors.green[700],
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _addToCart(dynamic product) {
    final existingItemIndex = _cartItems.indexWhere((item) => 
      item['id'].toString() == product['id'].toString());
    
    if (existingItemIndex != -1) {
      setState(() {
        _cartItems[existingItemIndex]['quantity'] = 
            (_cartItems[existingItemIndex]['quantity'] as int) + 1;
      });
    } else {
      setState(() {
        _cartItems.add({
          'id': product['id'],
          'name': product['name'],
          'arabic_name': product['arabic_name'],
          'price': product['price'],
          'image': product['image'],
          'quantity': 1,
        });
      });
    }
  }
}

class AccessoriesSearchDelegate extends SearchDelegate<String> {
  final String language;
  final List<dynamic> products;
  final Function(dynamic) onProductSelected;

  AccessoriesSearchDelegate({
    required this.language,
    required this.products,
    required this.onProductSelected,
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
    final filteredProducts = products.where((product) {
      final name = language == 'Arabic'
          ? product['arabic_name']?.toString() ?? product['name']?.toString() ?? ''
          : product['name']?.toString() ?? '';
      
      return name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    if (filteredProducts.isEmpty) {
      return Center(
        child: Text(
          language == 'Arabic'
            ? 'لا توجد نتائج'
            : 'No results found',
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        final name = language == 'Arabic'
            ? product['arabic_name']?.toString() ?? product['name']?.toString() ?? 'Product'
            : product['name']?.toString() ?? 'Product';
        
        final price = product['price']?.toString() ?? '0.00';
        final imagePath = product['image_url']?.toString() ?? 'assets/images/placeholder.jpg';
        final isNetworkImage = imagePath.startsWith('http');
        
        return ListTile(
          leading: SizedBox(
            width: 50,
            height: 50,
            child: isNetworkImage
                ? Image.network(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, size: 24),
                    ),
                  )
                : Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, size: 24),
                    ),
                  ),
          ),
          title: Text(name),
          subtitle: Text('$price MRU'),
          onTap: () {
            close(context, product['id']?.toString() ?? '1');
            onProductSelected(product);
          },
        );
      },
    );
  }
}

class CartScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final String selectedLanguage;
  final Map<String, Map<String, String>> translations;

  const CartScreen({
    super.key,
    required this.cartItems,
    required this.selectedLanguage,
    required this.translations,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String _translate(String key) {
    return widget.translations[widget.selectedLanguage]?[key] ?? 
           widget.translations['English']?[key] ?? key;
  }

  double get _totalPrice {
    double total = 0;
    for (var item in widget.cartItems) {
      final price = double.tryParse(item['price']?.toString() ?? '0') ?? 0;
      final quantity = item['quantity'] as int;
      total += price * quantity;
    }
    return total;
  }

  void _updateQuantity(int index, int delta) {
    setState(() {
      final newQty = (widget.cartItems[index]['quantity'] as int) + delta;
      if (newQty <= 0) {
        widget.cartItems.removeAt(index);
      } else {
        widget.cartItems[index]['quantity'] = newQty;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_translate('cart')),
        backgroundColor: Colors.pink[400],
        foregroundColor: Colors.white,
      ),
      body: widget.cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    widget.selectedLanguage == 'Arabic' ? 'سلة التسوق فارغة' : 'Your cart is empty',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.cartItems.length,
                    itemBuilder: (context, index) {
                      final item = widget.cartItems[index];
                      final name = widget.selectedLanguage == 'Arabic'
                          ? item['arabic_name']?.toString() ?? item['name']?.toString() ?? 'Product'
                          : item['name']?.toString() ?? 'Product';
                      
                      final price = double.tryParse(item['price']?.toString() ?? '0') ?? 0;
                      final quantity = item['quantity'] as int;
                      final imagePath = item['image']?.toString() ?? 'assets/images/placeholder.jpg';
                      final isNetworkImage = imagePath.startsWith('http');

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              // Product image
                              SizedBox(
                                width: 70,
                                height: 70,
                                child: isNetworkImage
                                    ? Image.network(
                                        imagePath,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          color: Colors.grey[200],
                                          child: const Icon(Icons.image_not_supported, size: 30),
                                        ),
                                      )
                                    : Image.asset(
                                        imagePath,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          color: Colors.grey[200],
                                          child: const Icon(Icons.image_not_supported, size: 30),
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 16),
                              
                              // Product details
                              Expanded(
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
                                      '${price.toStringAsFixed(2)} MRU',
                                      style: TextStyle(
                                        color: Colors.pink[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Quantity controls
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline),
                                        onPressed: () => _updateQuantity(index, -1),
                                        color: Colors.grey[600],
                                        iconSize: 20,
                                      ),
                                      Text(
                                        quantity.toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle_outline),
                                        onPressed: () => _updateQuantity(index, 1),
                                        color: Colors.pink[400],
                                        iconSize: 20,
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${(price * quantity).toStringAsFixed(2)} MRU',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Order summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.selectedLanguage == 'Arabic' ? 'المجموع:' : 'Total:',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${_totalPrice.toStringAsFixed(2)} MRU',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.pink[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () {
                            // Implement checkout
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  widget.selectedLanguage == 'Arabic'
                                      ? 'تم تقديم الطلب بنجاح'
                                      : 'Order placed successfully',
                                ),
                                backgroundColor: Colors.green[700],
                              ),
                            );
                            
                            // Clear cart and go back
                            setState(() {
                              widget.cartItems.clear();
                            });
                            
                            Future.delayed(const Duration(seconds: 2), () {
                              Navigator.pop(context);
                            });
                          },
                          child: Text(
                            widget.selectedLanguage == 'Arabic' ? 'إتمام الشراء' : 'Checkout',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
