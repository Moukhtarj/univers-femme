import 'package:flutter/material.dart';
import 'reservation_screen.dart';

class HennaScreen extends StatelessWidget {
  final String selectedLanguage;
  final Map<String, Map<String, String>> translations;
  
  const HennaScreen({
    super.key,
    required this.selectedLanguage,
    required this.translations,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(translations[selectedLanguage]!['henna']!),
        backgroundColor: const Color.fromARGB(255, 232, 174, 193),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildProductCard(
              context,
              'assets/images/n.jpg',
              selectedLanguage == 'Arabic' ? 'حناء تقليدية' : 'Traditional Henna',
              selectedLanguage == 'Arabic' ? 'اتصل: 22134478' : 'Call: 22134478',
            ),
            _buildProductCard(
              context,
              'assets/images/mn.jpg',
              selectedLanguage == 'Arabic' ? 'حناء تقليدية' : 'Traditional Henna',
              selectedLanguage == 'Arabic' ? 'اتصل: 34537711' : 'Call: 34537711',
            ),
            _buildProductCard(
              context,
              'assets/images/h.jpg',
              selectedLanguage == 'Arabic' ? 'حناء تقليدية' : 'Traditional Henna',
              selectedLanguage == 'Arabic' ? 'اتصل: 44109921' : 'Call: 44109921',
            ),
            _buildProductCard(
              context,
              'assets/images/..jpg',
              selectedLanguage == 'Arabic' ? 'حناء تقليدية' : 'Traditional Henna',
              selectedLanguage == 'Arabic' ? 'اتصل: 43990045' : 'Call: 43990045',
            ),
            _buildProductCard(
              context,
              'assets/images/a.jpg',
              selectedLanguage == 'Arabic' ? 'حناء تقليدية' : 'Traditional Henna',
              selectedLanguage == 'Arabic' ? 'اتصل: 26876002' : 'Call: 26876002',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, String imagePath, String title, String description) {
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
                    child: Icon(Icons.image, size: 40, color: Colors.grey[400]),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Text content
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
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 245, 182, 203),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
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
                        style: const TextStyle(color: Colors.white),
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