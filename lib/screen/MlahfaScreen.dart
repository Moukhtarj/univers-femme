import 'package:flutter/material.dart';

class MlahfaScreen extends StatelessWidget {
  final String selectedLanguage;
  final Map<String, Map<String, String>> translations;
  
  const MlahfaScreen({
    super.key,
    required this.selectedLanguage,
    required this.translations,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(translations[selectedLanguage]!['mlahfa']!),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildProductCard(
              context,
              'assets/images/traditional_mlahfa.jpg',
              selectedLanguage == 'Arabic' ? 'ملحفة تقليدية' : 'Traditional Mlahfa',
              selectedLanguage == 'Arabic' ? 'ملحفة موريتانية تقليدية' : 'Traditional Mauritanian Mlahfa',
              '129.99',
            ),
            _buildProductCard(
              context,
              'assets/images/modern_mlahfa.jpg',
              selectedLanguage == 'Arabic' ? 'ملحفة عصرية' : 'Modern Mlahfa',
              selectedLanguage == 'Arabic' ? 'تصميم عصري' : 'Contemporary design',
              '149.99',
            ),
            _buildProductCard(
              context,
              'assets/images/luxury_mlahfa.jpg',
              selectedLanguage == 'Arabic' ? 'ملحفة فاخرة' : 'Luxury Mlahfa',
              selectedLanguage == 'Arabic' ? 'منسوجة يدوياً' : 'Handwoven luxury',
              '199.99',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, String imagePath, String title, String description, String price) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.asset(
              imagePath,
              height: 180,
              fit: BoxFit.cover,
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
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$$price',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink,
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              selectedLanguage == 'Arabic' 
                                ? 'تمت إضافة $title إلى السلة'
                                : '$title added to cart',
                            ),
                          ),
                        );
                      },
                      child: Text(
                        translations[selectedLanguage]!['shop']!,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}