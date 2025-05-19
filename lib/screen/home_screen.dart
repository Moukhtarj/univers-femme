import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'AccessoriesScreen.dart';
import 'gym_screen.dart';
import 'HammamScreen .dart';
import 'HennaScreen.dart';
import 'MlahfaScreen.dart';
import 'NotificationsScreen.dart';
import 'makeup_screen.dart';
import 'welcome_screen.dart';
import 'profile_screen.dart';
import 'history_screen.dart';
import 'shop_screen.dart';
import 'wishlist_screen.dart';

class ModernHomeScreen extends StatefulWidget {
  final String selectedLanguage;
  final Map<String, Map<String, String>> translations;
  
  const ModernHomeScreen({
    super.key,
    required this.selectedLanguage,
    required this.translations,
  });

  @override
  State<ModernHomeScreen> createState() => _ModernHomeScreenState();
}

class _ModernHomeScreenState extends State<ModernHomeScreen> {
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user');
    if (userStr != null) {
      setState(() {
        
        _userData = json.decode(userStr);
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const WelcomeScreen(),
        ),
        (route) => false,
      );
    }
  }

  // Enhanced translation helper with proper fallbacks
  String _translate(String key) {
    // First try the selected language
    if (widget.translations[widget.selectedLanguage]?.containsKey(key) ?? false) {
      return widget.translations[widget.selectedLanguage]![key]!;
    }
    // Then try English as fallback
    else if (widget.translations['English']?.containsKey(key) ?? false) {
      return widget.translations['English']![key]!;
    }
    // Finally return the key itself if not found
    return key;
  }

  @override
  Widget build(BuildContext context) {
    bool isRTL = widget.selectedLanguage == 'Arabic';
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _translate('appTitle'),
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
                    _getGreeting(),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 230, 162, 191),
                    ),
                  ),
                  const SizedBox(height: 8),
                 
                  // Search bar
                  Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(30),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: _translate('search'),
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
                    _translate('categories'),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
                        _translate('hamam'),
                        Colors.pink[100]!,
                        Icons.spa,
                      ),
                      _buildModernCategoryCard(
                        context,
                        'assets/images/melh.jpg',
                        _translate('mlahfa'),
                        Colors.blue[100]!,
                        Icons.checkroom,
                      ),
                      _buildModernCategoryCard(
                        context,
                        'assets/images/acc.jpg',
                        _translate('accessories'),
                        Colors.purple[100]!,
                        Icons.diamond,
                      ),
                      _buildModernCategoryCard(
                        context,
                        'assets/images/gym.jpg',
                        _translate('gym'),
                        Colors.orange[100]!,
                        Icons.sports_gymnastics,
                      ),
                      _buildModernCategoryCard(
                        context,
                        'assets/images/bath.jpg',
                        _translate('henna'),
                        Colors.pink[100]!,
                        Icons.back_hand,
                      ),
                      _buildModernCategoryCard(
                        context,
                        'assets/images/melh.jpg',
                        _translate('lhfoul'),
                        Colors.blue[100]!,
                        Icons.brush,
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Directionality(
                textDirection: widget.selectedLanguage == 'Arabic' ? TextDirection.rtl : TextDirection.ltr,
                child: ShopScreen(
                  selectedLanguage: widget.selectedLanguage,
                  translations: widget.translations,
                ),
              ),
            ),
          );
        },
        backgroundColor: const Color.fromARGB(255, 241, 169, 200),
        child: const Icon(Icons.shopping_bag, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildModernBottomBar(),
    );
  }

  // Helper method to get proper greeting based on language
  String _getGreeting() {
    switch (widget.selectedLanguage) {
      case 'Arabic':
        return 'مرحباً بك!';
      case 'French':
        return 'Bonjour!';
      default:
        return 'Hello there!';
    }
  }

  Widget _buildModernDrawer(BuildContext context) {
    bool isRTL = widget.selectedLanguage == 'Arabic';
    
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
                  const Color.fromARGB(255, 238, 190, 211)!,
                  const Color.fromARGB(255, 236, 187, 205)!,
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
                    backgroundColor: Colors.black,
                    child: Icon(Icons.person, size: 40, color: Colors.pink),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: isRTL ? null : 24,
                  right: isRTL ? 24 : null,
                  child: Column(
                    crossAxisAlignment: isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                     
                      const SizedBox(height: 10),
                      Text(
                        _userData != null 
                            ? '${_userData!['first_name']} ${_userData!['last_name']}'
                            : _translate('guest'),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      if (_userData != null) Text(
                        _userData!['email'] ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
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
            title: Text(_translate('home')),
            onTap: () => Navigator.pop(context),
          ),
          
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: Text(_translate('shop')),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Directionality(
                    textDirection: widget.selectedLanguage == 'Arabic' ? TextDirection.rtl : TextDirection.ltr,
                    child: ShopScreen(
                      selectedLanguage: widget.selectedLanguage,
                      translations: widget.translations,
                    ),
                  ),
                ),
              );
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.favorite),
            title: Text(_translate('wishlist')),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Directionality(
                    textDirection: widget.selectedLanguage == 'Arabic' ? TextDirection.rtl : TextDirection.ltr,
                    child: WishlistScreen(
                      selectedLanguage: widget.selectedLanguage,
                      translations: widget.translations,
                    ),
                  ),
                ),
              );
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(_translate('profile')),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                    selectedLanguage: widget.selectedLanguage,
                    translations: widget.translations,
                  ),
                ),
              );
            },
          ),
          
          const Divider(indent: 16, endIndent: 16),
          
          ExpansionTile(
            leading: const Icon(Icons.contact_mail),
            title: Text(_translate('contact_us')),
            children: [
              _buildContactOption(
                Icons.phone,
                _translate('phone_call'),
                () async {
                  const phoneNumber = 'tel:+22243632554';
                  if (await canLaunch(phoneNumber)) {
                    await launch(phoneNumber);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_translate('cannot_call')),
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
                        content: Text(_translate('cannot_open_whatsapp')),
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
            title: Text(_translate('logout')),
            onTap: _logout,
          ),
          
          ExpansionTile(
            leading: const Icon(Icons.language),
            title: Text(_translate('language')),
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
      width: 160,
      height: 180,
      child: GestureDetector(
        onTap: () => _navigateToCategory(context, title),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 20),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '15+ ${_translate('items')}',
                  style: TextStyle(
                    fontSize: 10,
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
          height: 80,
          color: Colors.white,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomBarItem(Icons.home, _translate('home'), true, () {}),
                _buildBottomBarItem(Icons.shopping_bag, _translate('shop'), false, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Directionality(
                        textDirection: widget.selectedLanguage == 'Arabic' ? TextDirection.rtl : TextDirection.ltr,
                        child: ShopScreen(
                          selectedLanguage: widget.selectedLanguage,
                          translations: widget.translations,
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(width: 20),
                _buildBottomBarItem(Icons.favorite, _translate('wishlist'), false, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Directionality(
                        textDirection: widget.selectedLanguage == 'Arabic' ? TextDirection.rtl : TextDirection.ltr,
                        child: WishlistScreen(
                          selectedLanguage: widget.selectedLanguage,
                          translations: widget.translations,
                        ),
                      ),
                    ),
                  );
                }),
                _buildBottomBarItem(Icons.history, _translate('historique'), false, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Directionality(
                        textDirection: widget.selectedLanguage == 'Arabic' ? TextDirection.rtl : TextDirection.ltr,
                        child: HistoryScreen(
                          selectedLanguage: widget.selectedLanguage,
                          translations: widget.translations,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBarItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive ? Colors.pink[800] : Colors.grey[600],
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.pink[800] : Colors.grey[600],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
      ),
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
      trailing: widget.selectedLanguage == language 
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
                translations: widget.translations,
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToCategory(BuildContext context, String title) {
    final currentTranslations = widget.translations[widget.selectedLanguage] ?? widget.translations['English']!;
    
    Widget screen;
    
    if (title == currentTranslations['hamam'] || title == 'Hamam' || title == 'حمام') {
      screen = HammamListScreen(
        selectedLanguage: widget.selectedLanguage,
        translations: widget.translations,
      );
    }
    else if (title == currentTranslations['mlahfa'] || title == 'Mlahfa' || title == 'ملحفة') {
      screen = MelhfaScreen(
        selectedLanguage: widget.selectedLanguage,
        translations: widget.translations,
      );
    }
    else if (title == currentTranslations['accessories'] || title == 'Accessories' || title == 'إكسسوارات') {
      screen = AccessoriesScreen(
        selectedLanguage: widget.selectedLanguage,
        translations: widget.translations,
      );
    }
    else if (title == currentTranslations['gym'] || title == 'Gym' || title == 'نادي رياضي') {
      screen = GymScreen(
        selectedLanguage: widget.selectedLanguage,
        translations: widget.translations,
      );
    }
    else if (title == currentTranslations['henna'] || title == 'Henna' || title == 'حناء') {
      screen = HennaScreen(
        selectedLanguage: widget.selectedLanguage,
        translations: widget.translations,
      );
    }
    else if (title == currentTranslations['lhfoul'] || title == 'makeup' || title == 'ماكياج') {
      screen = MakeupScreen(
        selectedLanguage: widget.selectedLanguage,
        translations: widget.translations,
      );
    }
    else {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Directionality(
          textDirection: widget.selectedLanguage == 'Arabic' ? TextDirection.rtl : TextDirection.ltr,
          child: screen,
        ),
      ),
    );
  }
}