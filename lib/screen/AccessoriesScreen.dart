import 'package:flutter/material.dart';

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
  String _searchQuery = '';
  String _selectedCategory = 'All';
  final List<Map<String, dynamic>> _cartItems = [];

 Map<String, Map<String, String>> get _completeTranslations {
    return {
      'English': {
        'accessories': 'Accessories',
        'shop': 'Shop',
        'cart': 'Cart',
        'add_to_cart': 'Add to Cart',
        'confirm_add': 'Add to your cart?',
        'yes': 'Yes',
        'no': 'No',
        'added_to_cart': 'Added to cart',
        'featured': 'Featured Products',
        'jewelry': 'Jewelry Collection',
        'bags': 'Handbags',
        'all': 'All',
        'new': 'New',
        'empty_cart': 'Your cart is empty',
        ...?widget.translations['English'], // Merge with provided translations
      },
      'Arabic': {
        'accessories': 'اكسسوارات',
        'shop': 'تسوق',
        'cart': 'عربة التسوق',
        'add_to_cart': 'أضف إلى السلة',
        'confirm_add': 'إضافة إلى السلة؟',
        'yes': 'نعم',
        'no': 'لا',
        'added_to_cart': 'تمت الإضافة إلى السلة',
        'featured': 'منتجات مميزة',
        'jewelry': 'مجموعة المجوهرات',
        'bags': 'حقائب يد',
        'all': 'الكل',
        'new': 'جديد',
        'empty_cart': 'السلة فارغة',
        ...?widget.translations['Arabic'], // Merge with provided translations
      },
    };
  }

  // Helper to get translation with null safety
  String _translate(String key) {
    return _completeTranslations[widget.selectedLanguage]?[key] ?? key;
  }
  
  // Complete product data
  final List<Map<String, dynamic>> _allProducts = [
    {
      'id': 1,
      'name': 'Diamond Necklace',
      'arabicName': 'قلادة ماسية',
      'description': 'Elegant diamond necklace',
      'arabicDescription': 'قلادة ماسية أنيقة',
      'price': '299.99',
      'category': 'Jewelry',
      'arabicCategory': 'مجوهرات',
      'image': 'assets/images/neck.jpg',
      'isNew': true,
    },
    {
      'id': 2,
      'name': 'Gold Ring',
      'arabicName': 'خاتم ذهبي',
      'description': '24k gold ring',
      'arabicDescription': 'خاتم ذهب عيار 24',
      'price': '199.99',
      'category': 'Jewelry',
      'arabicCategory': 'مجوهرات',
      'image': 'assets/images/ring.avif',
      'isNew': false,
    },
    {
      'id': 3,
      'name': 'Pearl Earrings',
      'arabicName': 'أقراط لؤلؤ',
      'description': 'Genuine pearl earrings',
      'arabicDescription': 'أقراط لؤلؤ حقيقي',
      'price': '149.99',
      'category': 'Jewelry',
      'arabicCategory': 'مجوهرات',
      'image': 'assets/images/ear.png',
      'isNew': true,
    },
    {
      'id': 4,
      'name': 'Silver Bracelet',
      'arabicName': 'سوار فضة',
      'description': 'Handcrafted silver bracelet',
      'arabicDescription': 'سوار فضة مصنوع يدوياً',
      'price': '129.99',
      'category': 'Jewelry',
      'arabicCategory': 'مجوهرات',
      'image': 'assets/images/brace.webp',
      'isNew': false,
    },
    {
      'id': 5,
      'name': 'Designer Clutch',
      'arabicName': 'كلتش مصمم',
      'description': 'Evening designer clutch',
      'arabicDescription': 'كلتش أنيق للمناسبات',
      'price': '179.99',
      'category': 'Bags',
      'arabicCategory': 'حقائب',
      'image': 'assets/images/bag.webp',
      'isNew': true,
    },
    {
      'id': 6,
      'name': 'Leather Tote',
      'arabicName': 'حقيبة جلد',
      'description': 'Premium leather tote bag',
      'arabicDescription': 'حقيبة جلد عالي الجودة',
      'price': '229.99',
      'category': 'Bags',
      'arabicCategory': 'حقائب',
      'image': 'assets/images/bag2.avif',
      'isNew': false,
    },
    {
      'id': 7,
      'name': 'Silk Scarf',
      'arabicName': 'وشاح حرير',
      'description': 'Luxury silk scarf',
      'arabicDescription': 'وشاح حرير فاخر',
      'price': '89.99',
      'category': 'Scarves',
      'arabicCategory': 'أوشحة',
      'image': 'assets/images/silver.avif',
      'isNew': true,
    },
    {
      'id': 8,
      'name': 'Hair Clip',
      'arabicName': 'مشبش شعر',
      'description': 'Decorative hair clip',
      'arabicDescription': 'مشبش شعر زخرفي',
      'price': '39.99',
      'category': 'Hair',
      'arabicCategory': 'إكسسوارات شعر',
      'image': 'assets/images/pearl.webp',
      'isNew': false,
    },
  ];

  List<Map<String, dynamic>> get _filteredProducts {
    return _allProducts.where((product) {
      final matchesSearch = _searchQuery.isEmpty ||
          product['name'].toLowerCase().contains(_searchQuery.toLowerCase()) || 
          product['arabicName'].contains(_searchQuery);
      final matchesCategory = _selectedCategory == 'All' || 
          product['category'] == _selectedCategory ||
          product['arabicCategory'] == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.translations[widget.selectedLanguage]!['accessories']!),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: AccessoriesSearchDelegate(
                  language: widget.selectedLanguage,
                  products: _allProducts,
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Categories Horizontal Scroll
              SizedBox(
                height: 60,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildCategoryChip('All', widget.selectedLanguage == 'Arabic' ? 'الكل' : 'All'),
                    _buildCategoryChip('Jewelry', widget.selectedLanguage == 'Arabic' ? 'مجوهرات' : 'Jewelry'),
                    _buildCategoryChip('Bags', widget.selectedLanguage == 'Arabic' ? 'حقائب' : 'Bags'),
                    _buildCategoryChip('Scarves', widget.selectedLanguage == 'Arabic' ? 'أوشحة' : 'Scarves'),
                    _buildCategoryChip('Hair', widget.selectedLanguage == 'Arabic' ? 'إكسسوارات شعر' : 'Hair'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Featured Section
              Text(
                widget.selectedLanguage == 'Arabic' ? 'منتجات مميزة' : 'Featured Products',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              
              // Featured Products Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: _filteredProducts
                    .where((product) => product['category'] == 'Jewelry')
                    .map((product) => _buildFeaturedProductCard(
                          context,
                          product['image'],
                          widget.selectedLanguage == 'Arabic' ? product['arabicName'] : product['name'],
                          product['price'],
                          product['isNew'],
                          product,
                        ))
                    .toList(),
              ),
              
              const SizedBox(height: 25),
              
              // Bags Section
              Text(
                widget.selectedLanguage == 'Arabic' ? 'حقائب يد' : 'Handbags',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              
              // Bags Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: _filteredProducts
                    .where((product) => product['category'] == 'Bags')
                    .map((product) => _buildProductCard(
                          context,
                          product['image'],
                          widget.selectedLanguage == 'Arabic' ? product['arabicName'] : product['name'],
                          widget.selectedLanguage == 'Arabic' ? product['arabicDescription'] : product['description'],
                          product['price'],
                          product['isNew'],
                          product,
                        ))
                    .toList(),
              ),
              
              const SizedBox(height: 25),
              
              // Other Categories Sections (Scarves, Hair, etc.)
              // Add similar sections for other categories as needed
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String categoryValue, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(label),
        selected: _selectedCategory == categoryValue,
        selectedColor: Colors.pink,
        labelStyle: TextStyle(
          color: _selectedCategory == categoryValue ? Colors.white : Colors.black,
        ),
        onSelected: (bool selected) {
          setState(() {
            _selectedCategory = selected ? categoryValue : 'All';
          });
        },
      ),
    );
  }

  Widget _buildFeaturedProductCard(
    BuildContext context, 
    String imagePath, 
    String title, 
    String price,
    bool isNew,
    Map<String, dynamic> product,
  ) {
    return GestureDetector(
      onTap: () {
        _showAddToCartDialog(context, product);
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '\$$price',
                        style: const TextStyle(
                          color: Colors.pink,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isNew)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.pink,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    widget.selectedLanguage == 'Arabic' ? 'جديد' : 'New',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.add_shopping_cart),
                color: Colors.pink,
                onPressed: () {
                  _showAddToCartDialog(context, product);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(
  BuildContext context, 
  String imagePath, 
  String title, 
  String description, 
  String price,
  bool isFavorite,
  Map<String, dynamic> product,
) {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 4,
    child: Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    maxLines: 2, // Limit description to 2 lines
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  SizedBox( // Constrain the row width
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible( // Make price text flexible
                          child: Text(
                            '\$$price',
                            style: const TextStyle(
                              color: Colors.pink,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Flexible( // Make button flexible
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              minimumSize: const Size(0, 36), // Remove minimum width
                            ),
                            onPressed: () {
                              _showAddToCartDialog(context, product);
                            },
                            child: FittedBox( // Scale text to fit
                              child: Text(
                                widget.translations[widget.selectedLanguage]!['shop']!,
                                style: const TextStyle(color: Colors.white),
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
          ],
        ),
        Positioned(
          top: 8,
          left: 8,
          child: IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.pink : Colors.white,
            ),
            onPressed: () {
              // Toggle favorite
            },
          ),
        ),
      ],
    ),
  );
}

  Future<void> _showAddToCartDialog(BuildContext context, Map<String, dynamic> product) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(widget.translations[widget.selectedLanguage]!['add_to_cart']!),
          content: Text(
            widget.selectedLanguage == 'Arabic' 
              ? '${widget.translations[widget.selectedLanguage]!['confirm_add']!}\n${product['arabicName']}'
              : '${widget.translations[widget.selectedLanguage]!['confirm_add']!}\n${product['name']}',
          ),
          actions: <Widget>[
            TextButton(
              child: Text(widget.translations[widget.selectedLanguage]!['no']!),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text(widget.translations[widget.selectedLanguage]!['yes']!),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() {
        _cartItems.add(product);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.selectedLanguage == 'Arabic' 
              ? '${product['arabicName']} ${widget.translations[widget.selectedLanguage]!['added_to_cart']!}'
              : '${product['name']} ${widget.translations[widget.selectedLanguage]!['added_to_cart']!}',
          ),
        ),
        
      );
    }
  }
}

class AccessoriesSearchDelegate extends SearchDelegate {
  final String language;
  final List<Map<String, dynamic>> products;
  final Function(Map<String, dynamic>) onProductSelected;

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
    final results = query.isEmpty
        ? products
        : products.where((product) {
            return product['name'].toLowerCase().contains(query.toLowerCase()) ||
                   product['arabicName'].contains(query);
          }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final product = results[index];
        return ListTile(
          leading: Image.asset(
            product['image'],
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
          title: Text(language == 'Arabic' ? product['arabicName'] : product['name']),
          subtitle: Text('\$${product['price']}'),
          onTap: () {
            close(context, null);
            onProductSelected(product);
          },
        );
      },
    );
  }
}

class CartScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(translations[selectedLanguage]!['cart']!),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Text(
                selectedLanguage == 'Arabic' ? 'السلة فارغة' : 'Your cart is empty',
                style: const TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return ListTile(
                  leading: Image.asset(
                    item['image'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(selectedLanguage == 'Arabic' ? item['arabicName'] : item['name']),
                  subtitle: Text('\$${item['price']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    color: Colors.pink,
                    onPressed: () {
                      // Remove item from cart
                    },
                  ),
                );
              },
            ),
    );
  }
}
