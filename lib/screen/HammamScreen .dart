import 'package:flutter/material.dart';
import 'reservation_screen.dart';

class HammamScreen extends StatelessWidget {
  final String selectedLanguage;
  final Map<String, Map<String, String>> translations;
  
  const HammamScreen({
    super.key,
    required this.selectedLanguage,
    required this.translations,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(translations[selectedLanguage]!['hamam']!),
        backgroundColor: const Color.fromARGB(255, 234, 173, 194),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildProductCard(
              context,
              'assets/images/sh.jpg',
              selectedLanguage == 'Arabic' ? 'استحمام' : 'Traditional Shower',
              selectedLanguage == 'Arabic' ? 'استحمام' : 'Bathing',
              '350',
            ),
            _buildProductCard(
              context,
              'assets/images/im.jpg',
              selectedLanguage == 'Arabic' ? 'تصفيف الشعر' : 'Hair Combing',
              selectedLanguage == 'Arabic' ? 'تصفيف شامل للشعر' : 'Complete hair combing and cleaning',
              '600',
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
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Circular image container
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
              ),
              child: ClipOval(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Icon(Icons.spa, size: 40, color: Colors.grey[400]),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Text content and price
            Expanded(
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
                  const SizedBox(height: 4),
                  Text(
                    '$price MRU',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 243, 177, 199),
                    ),
                  ),
                ],
              ),
            ),
            // Reserve button
            Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC0CB), // Rose color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Directionality(
                        textDirection: selectedLanguage == 'Arabic' 
                            ? TextDirection.rtl 
                            : TextDirection.ltr,
                        child: ReservationScreen(
                          productName: title,
                          selectedLanguage: selectedLanguage,
                          translations: translations,
                        ),
                      ),
                    ),
                  );
                },
                child: Text(
                  selectedLanguage == 'Arabic' ? 'حجز' : 'Book',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}