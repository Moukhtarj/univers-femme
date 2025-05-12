import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'AccessoriesScreen.dart';
import 'GymScreen.dart';
import 'HammamScreen .dart';
import 'HennaScreen.dart';
import 'MlahfaScreen.dart';
import 'NotificationsScreen.dart';
import 'makeup_screen.dart';
import 'welcome_screen.dart';

class ModernHomeScreen extends StatelessWidget {
  final String selectedLanguage;
  final Map<String, Map<String, String>> translations;
  
  const ModernHomeScreen({
    super.key,
    required this.selectedLanguage,
    required this.translations,
  });

  // Helper method to safely get translations
  String _translate(String key, [String defaultValue = '']) {
    return translations[selectedLanguage]?[key] ?? defaultValue;
  }

  @override
  Widget build(BuildContext context) {
    bool isRTL = selectedLanguage == 'Arabic';
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _translate('appTitle', 'App Title'),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.pink[800],
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Badge(
              backgroundColor: Colors.red[400],
              label: const Text('3'),
              child: const Icon(Icons.notifications_outlined, color: Colors.black),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      drawer: _buildModernDrawer(context),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with greeting
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.pink[50]!,
                    Colors.pink[100]!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedLanguage == 'Arabic' ? 'مرحباً بك!' : 'Hello there!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                 
                  // Search bar
                  Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(30),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: _translate('search', 'Search'),
                        prefixIcon: const Icon(Icons.search, color: Colors.pink),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Categories grid
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
  overflow: TextOverflow.ellipsis,
  maxLines: 2,
                    _translate('categories', 'Categories'),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.9,
                    children: [
                      _buildModernCategoryCard(
                        context,
                        'assets/images/bath.jpg',
                        _translate('hamam', 'Bath'),
                        Colors.pink[100]!,
                        Icons.spa,
                      ),
                      _buildModernCategoryCard(
                        context,
                        'assets/images/melh.jpg',
                        _translate('mlahfa', 'Mlahfa'),
                        Colors.blue[100]!,
                        Icons.checkroom,
                      ),
                      _buildModernCategoryCard(
                        context,
                        'assets/images/acc.jpg',
                        _translate('accessories', 'Accessories'),
                        Colors.purple[100]!,
                        Icons.diamond,
                      ),
                      _buildModernCategoryCard(
                        context,
                        'assets/images/gym.jpg',
                        _translate('gym', 'Gym'),
                        Colors.orange[100]!,
                        Icons.sports_gymnastics,
                      ),
                      _buildModernCategoryCard(
                        context,
                        'assets/images/bath.jpg',
                        _translate('henna', 'Henna'),
                        Colors.pink[100]!,
                        Icons.back_hand,
                      ),
                      _buildModernCategoryCard(
                        context,
                        'assets/images/melh.jpg',
                        _translate('lhfoul', 'makeup'),
                        Colors.blue[100]!,
                        Icons.brush ,
                      ),
                    ].animate(interval: 100.ms).slideX(begin: 0.5, end: 0, duration: 400.ms),
                  ),
                ],
              ),
            ),

           
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.pink[800],
        child: const Icon(Icons.shopping_bag, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildModernBottomBar(),
    );
  }

  Widget _buildModernDrawer(BuildContext context) {
    bool isRTL = selectedLanguage == 'Arabic';
    
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(
          right: Radius.circular(30),
        ),
      ),
      width: MediaQuery.of(context).size.width * 0.8,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.pink[800]!,
                  Colors.pink[600]!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 60,
                  left: isRTL ? null : 24,
                  right: isRTL ? 24 : null,
                  child: const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 50, color: Colors.pink),
                  ),
                ),
                Positioned(
                  bottom: 24,
                  left: isRTL ? null : 24,
                  right: isRTL ? 24 : null,
                  child: Column(
                    crossAxisAlignment: isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Text(
  overflow: TextOverflow.ellipsis,
  maxLines: 2,
                        _translate('welcome', 'Welcome'),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Zeyneb Latif',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          ListTile(
            leading: const Icon(Icons.home),
            title: Text(_translate('home', 'Home')),
            onTap: () => Navigator.pop(context),
          ),
          
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: Text(_translate('shop', 'Shop')),
            onTap: () {},
          ),
          
          ListTile(
            leading: const Icon(Icons.favorite),
            title: Text(_translate('wishlist', 'Wishlist')),
            onTap: () {},
          ),
          
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(_translate('account', 'Account')),
            onTap: () {},
          ),
          
          const Divider(indent: 16, endIndent: 16),
          
          ExpansionTile(
            leading: const Icon(Icons.contact_mail),
            title: Text(_translate('contact_us', 'Contact Us')),
            children: [
              _buildContactOption(
                Icons.phone,
                _translate('phone_call', 'Phone Call'),
                () async {
                  const phoneNumber = 'tel:+22243632554';
                  if (await canLaunch(phoneNumber)) {
                    await launch(phoneNumber);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _translate('cannot_call', 'Cannot make phone call'),
                        ),
                      ),
                    );
                  }
                  Navigator.pop(context);
                },
              ),
              _buildContactOption(
                Icons.message,
                'WhatsApp',
                () async {
                  const whatsappUrl = 'https://wa.me/22243632554';
                  if (await canLaunch(whatsappUrl)) {
                    await launch(whatsappUrl);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _translate('cannot_open_whatsapp', 'Cannot open WhatsApp'),
                        ),
                      ),
                    );
                  }
                  Navigator.pop(context);
                },
              ),
              _buildContactOption(
                Icons.email,
                _translate('email', 'Email'),
                () async {
                  const emailUrl = 'mailto:zeynebou.latif@gmail.com';
                  if (await canLaunch(emailUrl)) {
                    await launch(emailUrl);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _translate('cannot_send_email', 'Cannot send email'),
                        ),
                      ),
                    );
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          
          const Divider(indent: 16, endIndent: 16),
          
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(_translate('logout', 'Logout')),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const Directionality(
                    textDirection: TextDirection.rtl,
                    child: WelcomeScreen(),
                  ),
                ),
              );
            },
          ),
          
          ExpansionTile(
            leading: const Icon(Icons.language),
            title: Text(_translate('language', 'Language')),
            children: [
              _buildLanguageOption(context, 'العربية', 'Arabic'),
              _buildLanguageOption(context, 'English', 'English'), 
              _buildLanguageOption(context, 'Français', 'French'),
            ],
          ),
        ],
      ),
    );
  }

 Widget _buildModernCategoryCard(
  BuildContext context, 
  String imagePath, 
  String title,
  Color bgColor,
  IconData icon,
) {
  return SizedBox(
    width: 160, // Fixed width
    height: 180, // Fixed height
     child: GestureDetector(
      onTap: () => _navigateToCategory(context, title),
    child: Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(12), // Add padding
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10), // Reduced padding
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20), // Smaller icon
            ),
            const SizedBox(height: 10), // Reduced spacing
            Text(
              title,
              style: TextStyle(
                fontSize: 14, // Smaller font
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '15+ items',
              style: TextStyle(
                fontSize: 10, // Smaller font
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    ),
     ),
  );
}
  Widget _buildFeaturedItem(String imagePath, String title, String subtitle, String tag) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withOpacity(0.7),
                Colors.transparent,
              ],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.pink[400],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
  overflow: TextOverflow.ellipsis,
  maxLines: 2,
                  tag,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
  overflow: TextOverflow.ellipsis,
  maxLines: 2,
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
  overflow: TextOverflow.ellipsis,
  maxLines: 2,
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialOfferCard(String title, String subtitle, IconData icon, Color bgColor, Color iconColor) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
  overflow: TextOverflow.ellipsis,
  maxLines: 2,
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
              ),
              Text(
  overflow: TextOverflow.ellipsis,
  maxLines: 2,
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

 Widget _buildModernBottomBar() {
  return Container(
    decoration: BoxDecoration(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          spreadRadius: 2,
          blurRadius: 10,
          offset: const Offset(0, -5),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: BottomAppBar(
        height: 80, // Increased height
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10), // Add padding
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomBarItem(Icons.home, _translate('home', 'Home'), true),
              _buildBottomBarItem(Icons.shopping_bag, _translate('shop', 'Shop'), false),
              const SizedBox(width: 20), // Space for FAB
              _buildBottomBarItem(Icons.favorite, _translate('wishlist', 'Wishlist'), false),
              _buildBottomBarItem(Icons.person, _translate('account', 'Account'), false),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildBottomBarItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive ? Colors.pink[800] : Colors.grey[600],
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.pink[800] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildContactOption(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }

  Widget _buildLanguageOption(BuildContext context, String title, String language) {
    return ListTile(
      title: Text(title),
      trailing: selectedLanguage == language 
          ? Icon(Icons.check, color: Colors.pink[800])
          : null,
      onTap: () {
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Directionality(
              textDirection: language == 'Arabic' ? TextDirection.rtl : TextDirection.ltr,
              child: ModernHomeScreen(
                selectedLanguage: language,
                translations: translations,
              ),
            ),
          ),
        );
      },
    );
  }

 void _navigateToCategory(BuildContext context, String title) {
  // Get the current translations
  final currentTranslations = translations[selectedLanguage] ?? translations['English']!;
  
  // Determine which screen to navigate to based on the title
  Widget screen;
  
  // Check against all possible translated category names
  if (title == currentTranslations['hamam'] || title == 'Hamam' || title == 'حمام') {
    screen = HammamListScreen(
      selectedLanguage: selectedLanguage,
      translations: translations,
    );
  }
  else if (title == currentTranslations['mlahfa'] || title == 'Mlahfa' || title == 'ملحفة') {
    screen = MelhfaScreen(
      selectedLanguage: selectedLanguage,
      translations: translations,
    );
  }
  else if (title == currentTranslations['accessories'] || title == 'Accessories' || title == 'إكسسوارات') {
    screen = AccessoriesScreen(
      selectedLanguage: selectedLanguage,
      translations: translations,
    );
  }
  else if (title == currentTranslations['gym'] || title == 'Gym' || title == 'نادي رياضي') {
    screen = GymScreen(
      selectedLanguage: selectedLanguage,
      translations: translations,
    );
  }
  else if (title == currentTranslations['henna'] || title == 'Henna' || title == 'حناء') {
    // If you have a HennaScreen
    screen = HennaScreen(
      selectedLanguage: selectedLanguage,
      translations: translations,
    );
  }
  
  else if (title == currentTranslations['lhfoul'] || title == 'makeup' || title == 'ماكياج') {
    // If you have a MakeupScreen
    screen = MakeupScreen(
      selectedLanguage: selectedLanguage,
      translations: translations,
    );
  }
  else {
    // Fallback for unknown categories
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Category $title not implemented yet'),
      ),
    );
    return;
  }

  // Navigate to the selected screen
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => screen),
  );
}


}