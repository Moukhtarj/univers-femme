// import 'package:flutter/material.dart';
// import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

// class LuxuryAccessoriesScreen extends StatefulWidget {
//   final String selectedLanguage;
//   final Map<String, Map<String, String>> translations;
  
//   const LuxuryAccessoriesScreen({
//     super.key,
//     required this.selectedLanguage,
//     required this.translations,
//   });

//   @override
//   State<LuxuryAccessoriesScreen> createState() => _LuxuryAccessoriesScreenState();
// }

// class _LuxuryAccessoriesScreenState extends State<LuxuryAccessoriesScreen> with SingleTickerProviderStateMixin {
//   late AnimationController _scaleController;
//   String _selectedCategory = 'All';
//   final List<String> _categories = ['All', 'Jewelry', 'Bags', 'Scarves', 'Hair', 'Glasses'];
//   final PageController _pageController = PageController(viewportFraction: 0.9);
//   int _currentFeaturedIndex = 0;

//   final List<Map<String, dynamic>> _products = [
//     {
//       'id': '1',
//       'category': 'Jewelry',
//       'image': 'assets/images/diamond_necklace.jpg',
//       'title': 'Diamond Necklace',
//       'titleAr': 'قلادة ماسية',
//       'price': '12,499',
//       'material': '18K White Gold',
//       'description': 'Handcrafted diamond necklace with 2.5 carat center stone',
//       'descriptionAr': 'قلادة ماسية يدوية الصنع بحجر مركزي 2.5 قيراط',
//       'isNew': true,
//       'isLimited': true
//     },
//     // Add 15-20 more luxury products
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _scaleController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );
//   }

//   @override
//   void dispose() {
//     _scaleController.dispose();
//     _pageController.dispose();
//     super.dispose();
//   }

//   void _onCategorySelect(String category) {
//     setState(() {
//       _selectedCategory = category;
//       _scaleController.reset();
//       _scaleController.forward();
//     });
//   }

//   Widget _buildCategoryChip(String category) {
//     final isSelected = _selectedCategory == category;
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 8),
//       child: GestureDetector(
//         onTap: () => _onCategorySelect(category),
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeInOut,
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//           decoration: BoxDecoration(
//             color: isSelected ? Colors.black : Colors.grey[200],
//             borderRadius: BorderRadius.circular(30),
//             boxShadow: isSelected ? [
//               BoxShadow(
//                 color: Colors.pink.withOpacity(0.3),
//                 blurRadius: 10,
//                 offset: const Offset(0, 4))
//             ] : [],
//           ),
//           child: Text(
//             widget.translations[widget.selectedLanguage]![category.toLowerCase()] ?? category,
//             style: TextStyle(
//               color: isSelected ? Colors.white : Colors.grey[800],
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildProductCard(Map<String, dynamic> product, int index) {
//     return AnimationConfiguration.staggeredGrid(
//       position: index,
//       duration: const Duration(milliseconds: 500),
//       columnCount: 2,
//       child: ScaleAnimation(
//         child: FadeInAnimation(
//           child: GestureDetector(
//             onTap: () => _showLuxuryProductDetails(product),
//             child: Card(
//               elevation: 4,
//               margin: const EdgeInsets.all(8),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20)),
//               clipBehavior: Clip.antiAlias,
//               child: Stack(
//                 children: [
//                   // Product Image with Parallax effect
//                   Positioned.fill(
//                     child: Hero(
//                       tag: 'product-${product['id']}',
//                       child: Image.asset(
//                         product['image'],
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),

//                   // Gradient Overlay
//                   Positioned.fill(
//                     child: DecoratedBox(
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           begin: Alignment.topCenter,
//                           end: Alignment.bottomCenter,
//                           colors: [
//                             Colors.transparent,
//                             Colors.black.withOpacity(0.7),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),

//                   // Product Info
//                   Positioned(
//                     bottom: 0,
//                     left: 0,
//                     right: 0,
//                     child: Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             widget.selectedLanguage == 'Arabic' 
//                               ? product['titleAr'] 
//                               : product['title'],
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             '\$${product['price']}',
//                             style: TextStyle(
//                               color: Colors.pink[200],
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),

//                   // Badges
//                   if (product['isNew'] ?? false)
//                     Positioned(
//                       top: 16,
//                       right: 16,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                         decoration: BoxDecoration(
//                           color: Colors.pink,
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Text(
//                           widget.selectedLanguage == 'Arabic' ? 'جديد' : 'NEW',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 12,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),

//                   // Favorite Button
//                   Positioned(
//                     top: 16,
//                     left: 16,
//                     child: IconButton(
//                       icon: const Icon(Icons.favorite_border),
//                       color: Colors.white,
//                       onPressed: () {},
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _showLuxuryProductDetails(Map<String, dynamic> product) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         return Container(
//           height: MediaQuery.of(context).size.height * 0.85,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.2),
//                 blurRadius: 30,
//                 spreadRadius: 5,
//               ),
//             ],
//           ),
//           child: Column(
//             children: [
//               // Draggable Handle
//               Container(
//                 margin: const EdgeInsets.only(top: 12, bottom: 8),
//                 width: 40,
//                 height: 4,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[300],
//                   borderRadius: BorderRadius.circular(2)),
//                 ),
//               ),

//               // Product Image Gallery
//               SizedBox(
//                 height: 300,
//                 child: PageView.builder(
//                   itemCount: 3, // Assuming 3 images per product
//                   itemBuilder: (context, index) {
//                     return Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 20),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(20),
//                         child: Image.asset(
//                           product['image'],
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),

//               // Product Details
//               Expanded(
//                 child: SingleChildScrollView(
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             widget.selectedLanguage == 'Arabic' 
//                               ? product['titleAr'] 
//                               : product['title'],
//                             style: const TextStyle(
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.favorite_border),
//                             onPressed: () {},
//                           ),
//                         ],
//                       ),

//                       const SizedBox(height: 8),

//                       Text(
//                         '\$${product['price']}',
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.pink[400],
//                         ),
//                       ),

//                       const SizedBox(height: 16),

//                       Text(
//                         'Material: ${product['material']}',
//                         style: const TextStyle(
//                           fontSize: 16,
//                           color: Colors.grey,
//                         ),
//                       ),

//                       const SizedBox(height: 24),

//                       Text(
//                         widget.selectedLanguage == 'Arabic' 
//                           ? product['descriptionAr'] 
//                           : product['description'],
//                         style: const TextStyle(
//                           fontSize: 16,
//                           height: 1.5,
//                         ),
//                       ),

//                       const SizedBox(height: 32),

//                       SizedBox(
//                         width: double.infinity,
//                         height: 56,
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.black,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12)),
//                             elevation: 4,
//                           ),
//                           onPressed: () {
//                             Navigator.pop(context);
//                             _showAddToCartConfirmation(product);
//                           },
//                           child: Text(
//                             widget.translations[widget.selectedLanguage]!['addToCart'] ?? 'ADD TO CART',
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   void _showAddToCartConfirmation(Map<String, dynamic> product) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20)),
//         contentPadding: const EdgeInsets.all(24),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(Icons.check_circle, color: Colors.pink, size: 60),
//             const SizedBox(height: 20),
//             Text(
//               widget.selectedLanguage == 'Arabic'
//                 ? 'تمت إضافة ${product['titleAr']} إلى السلة'
//                 : '${product['title']} added to cart',
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 20),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.black,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12)),
//                 ),
//                 onPressed: () => Navigator.pop(context),
//                 child: Text(
//                   widget.translations[widget.selectedLanguage]!['continueShopping'] ?? 'CONTINUE SHOPPING',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: Text(widget.translations[widget.selectedLanguage]!['accessories']!),
//         centerTitle: true,
//         backgroundColor: Colors.white,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.search, color: Colors.black),
//             onPressed: () {
//               showSearch(
//                 context: context,
//                 delegate: LuxuryProductSearchDelegate(
//                   products: _products,
//                   selectedLanguage: widget.selectedLanguage,
//                   translations: widget.translations,
//                 ),
//               );
//             },
//           ),
//           Stack(
//             children: [
//               IconButton(
//                 icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black),
//                 onPressed: () {},
//               ),
//               Positioned(
//                 right: 8,
//                 top: 8,
//                 child: Container(
//                   padding: const EdgeInsets.all(4),
//                   decoration: const BoxDecoration(
//                     color: Colors.pink,
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Text(
//                     '3',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 10,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Categories Strip
//           SizedBox(
//             height: 60,
//             child: ListView(
//               scrollDirection: Axis.horizontal,
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               children: _categories.map(_buildCategoryChip).toList(),
//             ),
//           ),

//           // Featured Products Carousel
//           SizedBox(
//             height: 280,
//             child: PageView.builder(
//               controller: _pageController,
//               itemCount: 5, // Featured items count
//               onPageChanged: (index) {
//                 setState(() {
//                   _currentFeaturedIndex = index;
//                 });
//               },
//               itemBuilder: (context, index) {
//                 return AnimatedBuilder(
//                   animation: _pageController,
//                   builder: (context, child) {
//                     double value = 1.0;
//                     if (_pageController.position.haveDimensions) {
//                       value = _pageController.page! - index;
//                       value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
//                     }
//                     return Center(
//                       child: SizedBox(
//                         height: Curves.easeOut.transform(value) * 280,
//                         width: Curves.easeOut.transform(value) * 300,
//                         child: child,
//                       ),
//                     );
//                   },
//                   child: _buildFeaturedItem(_products[index]),
//                 );
//               },
//             ),
//           ),

//           // Page Indicator
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: List.generate(5, (index) {
//               return Container(
//                 width: 8,
//                 height: 8,
//                 margin: const EdgeInsets.symmetric(horizontal: 4),
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: _currentFeaturedIndex == index 
//                     ? Colors.pink 
//                     : Colors.grey[300],
//                 ),
//               );
//             }),
//           ),

//           const SizedBox(height: 16),

//           // Products Grid Title
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24),
//             child: Row(
//               children: [
//                 Text(
//                   widget.selectedLanguage == 'Arabic' ? 'منتجاتنا' : 'OUR COLLECTION',
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const Spacer(),
//                 Text(
//                   widget.selectedLanguage == 'Arabic' ? 'عرض الكل' : 'VIEW ALL',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.pink[400],
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Products Grid
//           Expanded(
//             child: AnimationLimiter(
//               child: GridView.builder(
//                 padding: const EdgeInsets.all(16),
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   childAspectRatio: 0.75,
//                   crossAxisSpacing: 16,
//                   mainAxisSpacing: 16,
//                 ),
//                 itemCount: _products.length,
//                 itemBuilder: (context, index) {
//                   return _buildProductCard(_products[index], index);
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFeaturedItem(Map<String, dynamic> product) {
//     return GestureDetector(
//       onTap: () => _showLuxuryProductDetails(product),
//       child: Card(
//         elevation: 6,
//         margin: const EdgeInsets.all(12),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(24)),
//         clipBehavior: Clip.antiAlias,
//         child: Stack(
//           children: [
//             // Product Image
//             Positioned.fill(
//               child: Hero(
//                 tag: 'featured-${product['id']}',
//                 child: Image.asset(
//                   product['image'],
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),

//             // Gradient Overlay
//             Positioned.fill(
//               child: DecoratedBox(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [
//                       Colors.transparent,
//                       Colors.black.withOpacity(0.7),
//                     ],
//                   ),
//                 ),
//               ),
//             ),

//             // Limited Edition Badge
//             if (product['isLimited'] ?? false)
//               Positioned(
//                 top: 20,
//                 right: 20,
//                 child: Transform.rotate(
//                   angle: -0.1,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                     decoration: BoxDecoration(
//                       color: Colors.black,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text(
//                       widget.selectedLanguage == 'Arabic' ? 'إصدار محدود' : 'LIMITED',
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         letterSpacing: 1.5,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),

//             // Product Info
//             Positioned(
//               bottom: 0,
//               left: 0,
//               right: 0,
//               child: Padding(
//                 padding: const EdgeInsets.all(24),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       widget.selectedLanguage == 'Arabic' 
//                         ? product['titleAr'] 
//                         : product['title'],
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       '\$${product['price']}',
//                       style: TextStyle(
//                         color: Colors.pink[200],
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class LuxuryProductSearchDelegate extends SearchDelegate {
//   final List<Map<String, dynamic>> products;
//   final String selectedLanguage;
//   final Map<String, Map<String, String>> translations;

//   LuxuryProductSearchDelegate({
//     required this.products,
//     required this.selectedLanguage,
//     required this.translations,
//   });

//   @override
//   List<Widget> buildActions(BuildContext context) {
//     return [
//       IconButton(
//         icon: const Icon(Icons.clear),
//         onPressed: () {
//           query = '';
//         },
//       ),
//     ];
//   }

//   @override
//   Widget buildLeading(BuildContext context) {
//     return IconButton(
//       icon: const Icon(Icons.arrow_back),
//       onPressed: () {
//         close(context, null);
//       },
//     );
//   }

//   @override
//   Widget buildResults(BuildContext context) {
//     return _buildSearchResults();
//   }

//   @override
//   Widget buildSuggestions(BuildContext context) {
//     return _buildSearchResults();
//   }

//   Widget _buildSearchResults() {
//     final results = query.isEmpty
//         ? []
//         : products.where((product) {
//             return product['title'].toLowerCase().contains(query.toLowerCase()) ||
//                    (product['titleAr']?.toLowerCase().contains(query.toLowerCase()) ?? false);
//           }).toList();

//     if (results.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.search_off, size: 60, color: Colors.grey),
//             const SizedBox(height: 16),
//             Text(
//               selectedLanguage == 'Arabic' 
//                 ? 'لا توجد نتائج مطابقة' 
//                 : 'No items found',
//               style: const TextStyle(
//                 fontSize: 18,
//                 color: Colors.grey,
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: results.length,
//       itemBuilder: (context, index) {
//         final product = results[index];
//         return Card(
//           elevation: 2,
//           margin: const EdgeInsets.only(bottom: 16),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12)),
//           ),
//           child: ListTile(
//             contentPadding: const EdgeInsets.all(16),
//             leading: ClipRRect(
//               borderRadius: BorderRadius.circular(12),
//               child: Image.asset(
//                 product['image'],
//                 width: 60,
//                 height: 60,
//                 fit: BoxFit.cover,
//               ),
//             ),
//             title: Text(
//               selectedLanguage == 'Arabic' 
//                 ? product['titleAr'] 
//                 : product['title'],
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             subtitle: Text('\$${product['price']}'),
//             trailing: const Icon(Icons.chevron_right),
//             onTap: () {
//               close(context, product);
//             },
//           ),
//         );
//       },
//     );
//   }
// }