import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class MelhfaScreen extends StatelessWidget {
  final String selectedLanguage;
  final Map<String, Map<String, String>> translations;
  
  const MelhfaScreen({
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
          translations[selectedLanguage]?['melhfa'] ?? 'Melhfa',
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
            _buildCategoryHeader(context, selectedLanguage == 'Arabic' ? 'أنواع الملاحف' : 'Types of Melhfas'),
            const SizedBox(height: 15),
            _buildMelhfaTypeCard(
              context,
              'assets/images/melhfa_koura.jpg',
              selectedLanguage == 'Arabic' ? 'ملاحف الكرة' : 'Koura Melhfa',
              4.5,
            ),
            _buildMelhfaTypeCard(
              context,
              'assets/images/melhfa_gaz.jpg',
              selectedLanguage == 'Arabic' ? 'ملاحف گاز' : 'Gaz Melhfa',
              4.7,
            ),
            _buildMelhfaTypeCard(
              context,
              'assets/images/melhfa_khayata.jpg',
              selectedLanguage == 'Arabic' ? 'ملاحف الخياطة' : 'Khayata Melhfa',
              4.8,
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

  Widget _buildMelhfaTypeCard(BuildContext context, String imagePath, String name, double rating) {
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
                child: MelhfaListScreen(
                  melhfaType: name,
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
            children: [
              Container(
                width: 80,
                height: 80,
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
                )),
              const SizedBox(width: 12),
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
                      )),
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
              const Icon(Icons.chevron_right, color: Color(0xFFF06292)),
            ],
          ),
        ),
      ),
    );
  }
}

class MelhfaListScreen extends StatelessWidget {
  final String melhfaType;
  final String selectedLanguage;
  final Map<String, Map<String, String>> translations;
  
  const MelhfaListScreen({
    super.key,
    required this.melhfaType,
    required this.selectedLanguage,
    required this.translations,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F5),
      appBar: AppBar(
        title: Text(
          melhfaType,
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
            _buildCategoryHeader(context, selectedLanguage == 'Arabic' ? 'الملاحف المتوفرة' : 'Available Melhfas'),
            const SizedBox(height: 15),
            _buildMelhfaItem(
              context,
              'assets/images/melhfa3.jpg',
              selectedLanguage == 'Arabic' ? 'ملحفة أنيقة' : 'Blue Embroidered Melhfa',
              '22134478',
              '4000 MRU',
            ),
            _buildMelhfaItem(
              context,
              'assets/images/melhfa2.jpg',
              selectedLanguage == 'Arabic' ? 'ملحفة  أنيقة' : 'Red Classic Melhfa',
              '34537711',
              '3000 MRU',
            ),
            _buildMelhfaItem(
              context,
              'assets/images/melhfa1.jpg',
              selectedLanguage == 'Arabic' ? 'ملحفة  أنيقة' : 'Elegant Black Melhfa',
              '44109921',
              '2800 MRU',
            ),
             _buildMelhfaItem(
              context,
              'assets/images/melhfa4.jpg',
              selectedLanguage == 'Arabic' ? 'ملحفة  أنيقة' : 'Elegant Black Melhfa',
              '44109921',
              '2000 MRU',
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

  Widget _buildMelhfaItem(BuildContext context, String imagePath, String name, 
      String phoneNumber, String price) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Melhfa image
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: AssetImage(imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Melhfa details
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
                        )),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 16, color: Colors.pink[300]),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => _launchPhoneCall(phoneNumber),
                            child: Text(
                              phoneNumber,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue[600],
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Price
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEC407A)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF06292),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Directionality(
                            textDirection: selectedLanguage == 'Arabic' 
                                ? TextDirection.rtl 
                                : TextDirection.ltr,
                            child: OrderMelhfaScreen(
                              melhfaName: name,
                              melhfaPrice: price,
                              phoneNumber: phoneNumber,
                              selectedLanguage: selectedLanguage,
                              translations: translations,
                            ),
                          ),
                        ),
                      );
                    },
                    child: Text(
                      selectedLanguage == 'Arabic' ? 'اطلب الآن' : 'Order Now',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchPhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $launchUri';
    }
  }
}

class OrderMelhfaScreen extends StatefulWidget {
  final String melhfaName;
  final String melhfaPrice;
  final String phoneNumber;
  final String selectedLanguage;
  final Map<String, Map<String, String>> translations;
  
  const OrderMelhfaScreen({
    super.key,
    required this.melhfaName,
    required this.melhfaPrice,
    required this.phoneNumber,
    required this.selectedLanguage,
    required this.translations,
  });

  @override
  State<OrderMelhfaScreen> createState() => _OrderMelhfaScreenState();
}

class _OrderMelhfaScreenState extends State<OrderMelhfaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  int _quantity = 1;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isRTL = widget.selectedLanguage == 'Arabic';
    
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F5),
      appBar: AppBar(
        title: Text(
          widget.translations[widget.selectedLanguage]?['order'] ?? 'Order',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Melhfa details
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.melhfaName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF880E4F)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${isRTL ? 'السعر: ' : 'Price: '}${widget.melhfaPrice}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFFEC407A)),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            isRTL ? 'الكمية: ' : 'Quantity: ',
                            style: const TextStyle(fontSize: 16),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              setState(() {
                                if (_quantity > 1) _quantity--;
                              });
                            },
                          ),
                          Text(
                            _quantity.toString(),
                            style: const TextStyle(fontSize: 16),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                _quantity++;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Customer information
              Text(
                isRTL ? 'معلومات العميل' : 'Customer Information',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF880E4F)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: isRTL ? 'الاسم الكامل' : 'Full Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return isRTL ? 'الرجاء إدخال الاسم' : 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: isRTL ? 'رقم الهاتف' : 'Phone Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return isRTL ? 'الرجاء إدخال رقم الهاتف' : 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: isRTL ? 'العنوان' : 'Address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.location_on),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return isRTL ? 'الرجاء إدخال العنوان' : 'Please enter your address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Order button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF06292),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _showOrderConfirmation(context);
                    }
                  },
                  child: Text(
                    isRTL ? 'تأكيد الطلب' : 'Confirm Order',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOrderConfirmation(BuildContext context) {
    bool isRTL = widget.selectedLanguage == 'Arabic';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isRTL ? 'تم تأكيد الطلب' : 'Order Confirmed'),
        content: Text(
          isRTL 
              ? 'شكراً لك! تم استلام طلبك وسنتصل بك قريباً.'
              : 'Thank you! Your order has been received and we will call you soon.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(isRTL ? 'حسناً' : 'OK'),
          ),
        ],
      ),
    );
  }
}