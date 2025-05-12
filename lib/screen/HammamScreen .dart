import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'reservation_screen.dart';

class HammamListScreen extends StatelessWidget {
  final String selectedLanguage;
  final Map<String, Map<String, String>> translations;
  
  const HammamListScreen({
    super.key,
    required this.selectedLanguage,
    required this.translations,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F5),
      appBar: AppBar(
        title: Text(
          translations[selectedLanguage]!['hamam']!,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: const Color(0xFFF8BBD0),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: ListView(
          children: [
            const SizedBox(height: 10),
            _buildCategoryHeader(context, selectedLanguage == 'Arabic' ? 'الحمامات الموريتانية' : 'Mauritanian Hammams'),
            const SizedBox(height: 15),
            _buildHammamCard(
              context,
              'assets/images/hammam_nil.jpg',
              'Hammam Nil',
              selectedLanguage == 'Arabic' ? 'الشارع الرئيسي، نواكشوط' : 'Main Street, Nouakchott',
              4.7,
              '8:00 - 22:00',
            ),
            _buildHammamCard(
              context,
              'assets/images/hammam_yasmin.jpg',
              'Hammam El Yasmin',
              selectedLanguage == 'Arabic' ? 'حي تفرغ زينة، نواكشوط' : 'Tevragh Zeina, Nouakchott',
              4.8,
              '7:00 - 23:00',
            ),
           
            _buildHammamCard(
              context,
              'assets/images/hammam_zahra.jpg',
              'Hammam SPA',
              selectedLanguage == 'Arabic' ? 'شارع عبد الناصر، نواكشوط' : 'Abdel Nasser Street, Nouakchott',
              4.6,
              '8:00 - 22:00',
            ),
            _buildHammamCard(
              context,
              'assets/images/hammam_lotus.jpg',
              'Hammam aladin',
              selectedLanguage == 'Arabic' ? 'حي لكصر، نواكشوط' : 'Ksar District, Nouakchott',
              4.9,
              '7:30 - 23:30',
            ),
          
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Container(
            height: 24,
            width: 6,
            decoration: BoxDecoration(
              color: const Color(0xFFF06292),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF880E4F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHammamCard(BuildContext context, String imagePath, String name, 
      String address, double rating, String hours) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Directionality(
                textDirection: selectedLanguage == 'Arabic' 
                    ? TextDirection.rtl 
                    : TextDirection.ltr,
                child: HammamDetailScreen(
                  hammamName: name,
                  selectedLanguage: selectedLanguage,
                  translations: translations,
                ),
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with decorative border
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFF8BBD0).withOpacity(0.5),
                    width: 2,
                  ),
                  image: DecorationImage(
                    image: AssetImage(imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Hammam details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF880E4F),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.pink[300]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            address,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        RatingBarIndicator(
                          rating: rating,
                          itemBuilder: (context, index) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          itemCount: 5,
                          itemSize: 16,
                          direction: Axis.horizontal,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          rating.toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: Colors.pink[300]),
                        const SizedBox(width: 4),
                        Text(
                          hours,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFFF06292)),
            ],
          ),
        ),
      ),
    );
  }
}

class HammamDetailScreen extends StatelessWidget {
  final String hammamName;
  final String selectedLanguage;
  final Map<String, Map<String, String>> translations;
  
  const HammamDetailScreen({
    super.key,
    required this.hammamName,
    required this.selectedLanguage,
    required this.translations,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F5),
      appBar: AppBar(
        title: Text(
          hammamName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: const Color(0xFFF8BBD0),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
        ),
      ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: ListView(
          children: [
            const SizedBox(height: 10),
            _buildCategoryHeader(context, selectedLanguage == 'Arabic' ? 'خدمات الحمام' : 'Bath Services'),
            const SizedBox(height: 15),
            _buildServiceCard(
              context,
              'assets/images/sh.jpg',
              selectedLanguage == 'Arabic' ? 'استحمام تقليدي' : 'Traditional Bath',
              selectedLanguage == 'Arabic' ? 'تجربة استحمام تقليدية مع أعشاب طبيعية' : 'Traditional bathing experience with natural herbs',
              '350',
              4.5,
              '45 ${selectedLanguage == 'Arabic' ? 'دقيقة' : 'min'}',
            ),
            _buildServiceCard(
              context,
              'assets/images/im.jpg',
              selectedLanguage == 'Arabic' ? 'عناية كاملة بالشعر' : 'Complete Hair Care',
              selectedLanguage == 'Arabic' ? 'تنظيف، تطهير وتصفيف شامل للشعر' : 'Cleaning, purification and complete hair styling',
              '600',
              4.8,
              '60 ${selectedLanguage == 'Arabic' ? 'دقيقة' : 'min'}',
            ),
            _buildServiceCard(
              context,
              'assets/images/spa.jpg',
              selectedLanguage == 'Arabic' ? 'حمام بخار ومساج' : 'Steam Bath & Massage',
              selectedLanguage == 'Arabic' ? 'جلسة بخار مع مساج كامل للجسم' : 'Steam session with full body massage',
              '800',
              4.9,
              '90 ${selectedLanguage == 'Arabic' ? 'دقيقة' : 'min'}',
            ),
            const SizedBox(height: 30),
            _buildInfoCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Container(
            height: 24,
            width: 6,
            decoration: BoxDecoration(
              color: const Color(0xFFF06292),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF880E4F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, String imagePath, String title, 
      String description, String price, double rating, String duration) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          _showServiceDetails(context, title, description, price, duration);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image with decorative border
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFF8BBD0).withOpacity(0.5),
                        width: 2,
                      ),
                      image: DecorationImage(
                        image: AssetImage(imagePath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Service details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF880E4F),
                          )),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600]),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            RatingBarIndicator(
                              rating: rating,
                              itemBuilder: (context, index) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              itemCount: 5,
                              itemSize: 16,
                              direction: Axis.horizontal,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              rating.toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Price and booking button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$price MRU',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEC407A),
                        ),
                      ),
                      Text(
                        duration,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF06292),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 6),
                      elevation: 2,
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
                      selectedLanguage == 'Arabic' ? 'احجز الآن' : 'Book Now',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFCE4EC),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: Color(0xFFEC407A)),
              const SizedBox(width: 8),
              Text(
                selectedLanguage == 'Arabic' ? 'معلومات هامة' : 'Important Information',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF880E4F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            selectedLanguage == 'Arabic' 
                ? '• جميع خدماتنا تستخدم منتجات طبيعية وعضوية\n• يرجى الحضور قبل 15 دقيقة من الموعد المحدد\n• الإلغاء قبل 24 ساعة لاسترداد المبلغ كاملاً'
                : '• All our services use natural and organic products\n• Please arrive 15 minutes before your appointment\n• Cancel 24 hours in advance for full refund',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  void _showServiceDetails(BuildContext context, String title, String description, 
      String price, String duration) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(25),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 60,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF880E4F),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Icon(Icons.access_time, color: Colors.pink[300], size: 18),
                  const SizedBox(width: 5),
                  Text(
                    duration,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Icon(Icons.attach_money, color: Colors.pink[300], size: 18),
                  const SizedBox(width: 5),
                  Text(
                    '$price MRU',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEC407A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                selectedLanguage == 'Arabic' ? 'وصف الخدمة' : 'Service Description',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 25),
              Text(
                selectedLanguage == 'Arabic' ? 'ما تشمله الخدمة' : 'What\'s Included',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              _buildIncludedItem(Icons.spa, selectedLanguage == 'Arabic' ? 'أعشاب طبيعية' : 'Natural Herbs'),
              _buildIncludedItem(Icons.clean_hands, selectedLanguage == 'Arabic' ? 'أدوات احترافية' : 'Professional Tools'),
              _buildIncludedItem(Icons.emoji_people, selectedLanguage == 'Arabic' ? 'خدمة من خبراء' : 'Expert Service'),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF06292),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 3),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
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
                    selectedLanguage == 'Arabic' ? 'احجز هذه الخدمة' : 'Book This Service',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIncludedItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFF06292)),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}