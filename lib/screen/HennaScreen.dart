import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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
        backgroundColor: const Color(0xFFE8AEC1),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF9E8EF),
              Color(0xFFF5D6E3),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              _buildShopCard(
                context,
                'assets/images/n.jpg',
                'Salon Al Ward',
                '+222 22134478',
              ),
              _buildShopCard(
                context,
                'assets/images/mn.jpg',
                'Salon Noor',
                '+222 34537711',
              ),
              _buildShopCard(
                context,
                'assets/images/h.jpg',
                'Salon Zahra',
                '+222 44109921',
              ),
              _buildShopCard(
                context,
                'assets/images/..jpg',
                'Salon  Laila',
                '+222 43990045',
              ),
              _buildShopCard(
                context,
                'assets/images/a.jpg',
                'Salon Yasmin',
                '+222 26876002',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShopCard(BuildContext context, String imagePath, String shopName, String phoneNumber) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _launchPhoneCall(phoneNumber),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFFF9FB),
                Color(0xFFFFF0F5),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              // Circular avatar with image
              Hero(
                tag: shopName,
                child: Container(
                  width: 53,
                  height: 65,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE8AEC1),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Icon(
                          Icons.spa,
                          size: 30,
                          color: const Color(0xFFE8AEC1).withOpacity(0.6),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Shop info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shopName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6D3B47),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.phone,
                          size: 16,
                          color: const Color(0xFFE8AEC1),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          phoneNumber,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Book button
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8AEC1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.calendar_today,
                    color: Colors.white,
                    size: 20,
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
                          productName: shopName,
                          selectedLanguage: selectedLanguage,
                          translations: translations,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchPhoneCall(String phoneNumber) async {
    final Uri telLaunchUri = Uri(
      scheme: 'tel',
      path: phoneNumber.replaceAll(RegExp(r'[^0-9+]'), ''),
    );
    
    if (await canLaunchUrl(telLaunchUri)) {
      await launchUrl(telLaunchUri);
    } else {
      throw 'Could not launch $telLaunchUri';
    }
  }
}