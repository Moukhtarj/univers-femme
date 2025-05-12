import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'reservation_screen.dart';

class MakeupScreen extends StatelessWidget {
  final String selectedLanguage;
  final Map<String, Map<String, String>> translations;
  
  const MakeupScreen({
    super.key,
    required this.selectedLanguage,
    required this.translations,
  });

  @override
  Widget build(BuildContext context) {
    bool isRTL = selectedLanguage == 'Arabic';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(translations[selectedLanguage]?['makeup'] ?? 'Makeup'),
        backgroundColor: Colors.pink[800],
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
              // Bridal Makeup Section
              // _buildSectionHeader(
              //   context,
              //   isRTL ? 'مكياج عرائس' : 'Bridal Makeup',
              //   isRTL ? 'عرض خاص: 20% خصم' : 'Special Offer: 20% Off',
              // ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildMakeupArtistCard(
                      context,
                      'assets/images/makeup1.jpg',
                      isRTL ? 'صالون زينة' : 'Zina Salon',
                      '+222 12345678',
                      isRTL ? 'مكياج كامل: 1500 MRU' : 'Full Makeup: 1500 MRU',
                    ),
                    _buildMakeupArtistCard(
                      context,
                      'assets/images/makeup2.jpg',
                      isRTL ? 'صالون ليلى' : 'Layla Salon',
                      '+222 87654321',
                      isRTL ? 'مكياج كامل: 1800 MRU' : 'Full Makeup: 1800 MRU',
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Evening Makeup Section
              // _buildSectionHeader(
              //   context,
              //   isRTL ? 'مكياج سهرة' : 'Evening Makeup',
              //   isRTL ? 'احجز قبل 3 أيام' : 'Book 3 Days in Advance',
              // ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildMakeupArtistCard(
                      context,
                      'assets/images/makeup3.jpg',
                      isRTL ? 'صالون نور' : 'Noor Beauty',
                      '+222 23456789',
                      isRTL ? 'مكياج سهرة: 1000 MRU' : 'Evening Makeup: 1000 MRU',
                    ),
                    _buildMakeupArtistCard(
                      context,
                      'assets/images/makeup4.webp',
                      isRTL ? 'صالون ياسمين' : 'Yasmin Studio',
                      '+222 98765432',
                      isRTL ? 'مكياج سهرة: 1200 MRU' : 'Evening Makeup: 1200 MRU',
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Special Offers Card
              // Card(
              //   margin: const EdgeInsets.symmetric(horizontal: 8),
              //   shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(20),
              //   ),
              //   child: Container(
              //     padding: const EdgeInsets.all(16),
              //     decoration: BoxDecoration(
              //       gradient: LinearGradient(
              //         colors: [
              //           Colors.pink[100]!,
              //           Colors.pink[50]!,
              //         ],
              //         begin: Alignment.topLeft,
              //         end: Alignment.bottomRight,
              //       ),
              //       borderRadius: BorderRadius.circular(20),
              //     ),
              //     child: Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Row(
              //           children: [
              //             Icon(Icons.local_offer, color: Colors.pink[800]),
              //             const SizedBox(width: 8),
              //             Text(
              //               isRTL ? 'عروض خاصة' : 'Special Offers',
              //               style: TextStyle(
              //                 fontSize: 18,
              //                 fontWeight: FontWeight.bold,
              //                 color: Colors.pink[800],
              //               ),
              //             ),
              //           ],
              //         ),
              //         const SizedBox(height: 12),
              //         _buildOfferItem(
              //           isRTL ? 'حزمة زفاف كاملة' : 'Complete Wedding Package',
              //           isRTL ? 'مكياج + حناء + فستان' : 'Makeup + Henna + Dress',
              //           '5000 MRU',
              //         ),
              //         _buildOfferItem(
              //           isRTL ? 'حزمة عيد الميلاد' : 'Eid Package',
              //           isRTL ? 'مكياج + مانيكير' : 'Makeup + Manicure',
              //           '2500 MRU',
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Directionality(
                textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                child: ReservationScreen(
                  productName: isRTL ? 'حجز مكياج' : 'Makeup Booking',
                  selectedLanguage: selectedLanguage,
                  translations: translations,
                ),
              ),
            ),
          );
        },
        backgroundColor: Colors.pink[800],
        child: const Icon(Icons.calendar_today, color: Colors.white),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.pink[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMakeupArtistCard(
    BuildContext context,
    String imagePath,
    String salonName,
    String phoneNumber,
    String price,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _launchPhoneCall(phoneNumber),
        child: Container(
          width: 220,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: AspectRatio(
                  aspectRatio: 16/9,
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.face_retouching_natural, 
                            size: 40, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                salonName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                price,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.pink[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.pink[50],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.phone,
                        color: Colors.pink[800],
                        size: 18,
                      ),
                    ),
                    onPressed: () => _launchPhoneCall(phoneNumber),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    phoneNumber,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.pink[800],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.bookmark,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfferItem(String title, String description, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.pink[800],
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.pink[800],
            ),
          ),
        ],
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