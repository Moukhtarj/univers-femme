import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String _selectedLanguage = 'Arabic';
  final Map<String, Map<String, String>> _translations = {
    'Arabic': {
      'appTitle': "🌸🎀 Girl's",
      'shop': 'تسوق',
      'care': 'العناية',
      'health': 'صحة',
      'education': 'تعليم',
      'login': 'تسجيل الدخول',
      'register': 'إنشاء حساب جديد',
      'loginTitle': 'تسجيل الدخول',
      'registerTitle': 'إنشاء حساب جديد',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'fullName': 'الاسم الكامل',
      'forgotPassword': 'نسيت كلمة المرور؟',
      'home': 'الصفحة الرئيسية',
      'account': 'حسابي',
      'logout': 'تسجيل الخروج',
      'profile': 'الملف الشخصي',
      'firstName': 'الاسم الأول',
      'lastName': 'اسم العائلة',
      'phone': 'رقم الهاتف',
      'guest': 'زائر',
      'requiredField': 'هذا الحقل مطلوب',
      'invalidEmail': 'البريد الإلكتروني غير صالح',
      'profileUpdated': 'تم تحديث الملف الشخصي بنجاح',
      'welcome': 'مرحباً',
      'hamam': 'الحمام',
      'mlahfa': 'الملحفة',
      'lhfoul': 'ماكياج',
      'accessories': 'الإكسسوارات',
      'gym': 'النادي الرياضي',
      'henna': 'الحناء',
      'contact_us': 'اتصل بنا',
      'phone_call': 'مكالمة هاتفية',
      'cannot_call': 'لا يمكن إجراء مكالمة',
      'cannot_open_whatsapp': 'لا يمكن فتح واتساب',
      'cannot_send_email': 'لا يمكن إرسال البريد الإلكتروني',
      'traditional_bath': 'حمام تقليدي',
    'hair_care': 'عناية بالشعر',
    'steam_massage': 'بخار ومساج',
    'duration': 'المدة',
    'price': 'السعر',
    'book_now': 'احجز الآن',
    'important_info': 'معلومات هامة',
    'natural_products': 'جميع الخدمات تستخدم منتجات طبيعية',
    'arrive_early': 'يرجى الحضور قبل 15 دقيقة',
    'cancel_policy': 'سياسة الإلغاء قبل 24 ساعة',
    'service_description': 'وصف الخدمة',
    'whats_included': 'ما المدرج',
    'natural_herbs': 'أعشاب طبيعية',
    'professional_tools': 'أدوات محترفة',
    'expert_service': 'خدمة خبراء',
    'minutes': 'دقيقة',
    'search': 'بحث',
    'categories': 'فئات',
    'wishlist': 'قائمة الرغبات',
    'language': 'اللغة',
    'home_page': 'الصفحة الرئيسية',
    'historique': 'السجل',

    },
    'English': {
      'appTitle': "🌸🎀 Girl's",
      'shop': 'Shop',
      'care': 'Care',
      'health': 'Health',
      'education': 'Education',
      'login': 'Login',
      'register': 'Register',
      'loginTitle': 'Login',
      'registerTitle': 'Create New Account',
      'email': 'Email',
      'password': 'Password',
      'fullName': 'Full Name',
      'forgotPassword': 'Forgot Password?',
      'home': 'Home',
      'account': 'Account',
      'logout': 'Logout',
      'profile': 'Profile',
      'firstName': 'First Name',
      'lastName': 'Last Name',
      'phone': 'Phone',
      'guest': 'Guest',
      'requiredField': 'This field is required',
      'invalidEmail': 'Invalid email format',
      'profileUpdated': 'Profile updated successfully',
      'welcome': 'Welcome',
      'hamam': 'Hammam',
      'mlahfa': 'Mlahfa',
      'lhfoul': 'Makeup',
      'accessories': 'Accessories',
      'gym': 'Gym',
      'henna': 'Henna',
      'contact_us': 'Contact Us',
      'phone_call': 'Phone Call',
      'cannot_call': 'Cannot make call',
      'cannot_open_whatsapp': 'Cannot open WhatsApp',
      'cannot_send_email': 'Cannot send email',
      'traditional_bath': 'Traditional Bath',
    'hair_care': 'Hair Care',
    'steam_massage': 'Steam & Massage',
    'duration': 'Duration',
    'price': 'Price',
    'book_now': 'Book Now',
    'important_info': 'Important Information',
    'natural_products': 'All services use natural products',
    'arrive_early': 'Please arrive 15 minutes early',
    'cancel_policy': '24-hour cancellation policy',
    'service_description': 'Service Description',
    'whats_included': "What's Included",
    'natural_herbs': 'Natural Herbs',
    'professional_tools': 'Professional Tools',
    'expert_service': 'Expert Service',
    'minutes': 'minutes',
    'search': 'Search',
    'categories': 'Categories',
    'wishlist': 'Wishlist',
    'language': 'Language',
    'historique': 'History',
    },
    'French': {
    'appTitle': "🌸🎀 Girl's",
    'shop': 'Boutique',
    'care': 'Soins',
    'health': 'Santé',
    'education': 'Éducation',
    'login': 'Connexion',
    'register': 'Inscription',
    'loginTitle': 'Connexion',
    'registerTitle': 'Créer un nouveau compte',
    'email': 'Email',
    'password': 'Mot de passe',
    'fullName': 'Nom complet',
    'forgotPassword': 'Mot de passe oublié?',
    'home': 'Accueil',
    'account': 'Compte',
    'logout': 'Déconnexion',
    'profile': 'Profil',
    'firstName': 'Prénom',
    'lastName': 'Nom',
    'phone': 'Téléphone',
    'guest': 'Invité',
    'requiredField': 'Ce champ est requis',
    'invalidEmail': 'Format d\'email invalide',
    'profileUpdated': 'Profil mis à jour avec succès',
    'welcome': 'Bienvenue',
    'hamam': 'Hammam',
    'mlahfa': 'Mlahfa',
    'accessories': 'Accessoires',
    'gym': 'Salle de sport',
    'henna': 'Henné',
    'contact_us': 'Contactez-nous',
    'phone_call': 'Appel téléphonique',
    'cannot_call': 'Impossible de passer l\'appel',
    'cannot_open_whatsapp': 'Impossible d\'ouvrir WhatsApp',
    'cannot_send_email': 'Impossible d\'envoyer l\'email',
    'traditional_bath': 'Bain traditionnel',
    'hair_care': 'Soin capillaire',
    'steam_massage': 'Hammam & Massage',
    'duration': 'Durée',
    'price': 'Prix',
    'book_now': 'Réserver maintenant',
    'important_info': 'Informations importantes',
    'natural_products': 'Tous les services utilisent des produits naturels',
    'arrive_early': 'Veuillez arriver 15 minutes à l\'avance',
    'cancel_policy': 'Politique d\'annulation 24 heures',
    'service_description': 'Description du service',
    'whats_included': 'Ce qui est inclus',
    'natural_herbs': 'Herbes naturelles',
    'professional_tools': 'Outils professionnels',
    'expert_service': 'Service expert',
    'minutes': 'minutes',
    'search': 'Rechercher',
    'categories': 'Catégories',
    'wishlist': 'souhaits',
    'language': 'Langue',
    'historique': 'Historique',

        
    },
  };

  void _changeLanguage(String language) {
    setState(() {
      _selectedLanguage = language;
    });
    Navigator.pop(context);
  }

  Widget _buildCategoryCard(IconData icon, String titleKey) {
    return Expanded(
      child: Card(
        margin: EdgeInsets.zero,
        color: const Color.fromRGBO(255, 192, 203, 0.3),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 10),
              Text(
                _translations[_selectedLanguage]![titleKey]!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 192, 203, 1),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromRGBO(18, 17, 18, 1),
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ExpansionTile(
              title: Text(_translations[_selectedLanguage]!['account']!),
              children: [
                ListTile(
                  title: Text(_translations[_selectedLanguage]!['logout']!),
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
              ],
            ),
            const Divider(),
            ExpansionTile(
              title: const Text('Language'),
              children: [
                ListTile(
                  title: const Text('العربية'),
                  onTap: () => _changeLanguage('Arabic'),
                ),
                ListTile(
                  title: const Text('English'),
                  onTap: () => _changeLanguage('English'),
                ),
                ListTile(
                  title: const Text('Français'),
                  onTap: () => _changeLanguage('French'),
                ),
              ],
            ),
            const Divider(),
            ExpansionTile(
              title: Text(_translations[_selectedLanguage]!['contact_us'] ?? 'Contact Us'),
              children: [
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: Text(_translations[_selectedLanguage]!['phone_call'] ?? 'Phone Call'),
                  onTap: () async {
                    const phoneNumber = 'tel:+22243632554';
                    if (await canLaunch(phoneNumber)) {
                      await launch(phoneNumber);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(_translations[_selectedLanguage]!['cannot_call'] ?? 'Cannot make phone call'),
                        ),
                      );
                    }
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Image.asset('assets/images/wts.png', width: 24, height: 24, color: Colors.red),
                  title: const Text('WhatsApp'),
                  onTap: () async {
                    const whatsappUrl = 'https://wa.me/22243632554';
                    if (await canLaunch(whatsappUrl)) {
                      await launch(whatsappUrl);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(_translations[_selectedLanguage]!['cannot_open_whatsapp'] ?? 'Cannot open WhatsApp'),
                        ),
                      );
                    }
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.email),
                  title: Text(_translations[_selectedLanguage]!['email'] ?? 'Email'),
                  onTap: () async {
                    const emailUrl = 'zeynebou.latif@gmail.con';
                    if (await canLaunch(emailUrl)) {
                      await launch(emailUrl);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(_translations[_selectedLanguage]!['cannot_send_email'] ?? 'Cannot send email'),
                        ),
                      );
                    }
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text(
                _translations[_selectedLanguage]!['appTitle']!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              Image.asset(
                'assets/images/talye.jpg',
                height: 200,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  _buildCategoryCard(Icons.shopping_bag, 'shop'),
                  _buildCategoryCard(Icons.spa, 'care'),
                  _buildCategoryCard(Icons.health_and_safety, 'health'),
                ],
              ),
              const SizedBox(height: 40),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Directionality(
                          textDirection: TextDirection.rtl,
                          child: LoginScreen(
                            selectedLanguage: _selectedLanguage,
                            translations: _translations,
                          ),
                        ),
                      ),
                    );
                  },
                  child: Text(
                    _translations[_selectedLanguage]!['login']!,
                    style: const TextStyle(
                      color: Color.fromRGBO(255, 192, 203, 1),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Directionality(
                        textDirection: TextDirection.rtl,
                        child: RegisterScreen(
                          selectedLanguage: _selectedLanguage,
                          translations: _translations,
                        ),
                      ),
                    ),
                  );
                },
                child: Text(
                  _translations[_selectedLanguage]!['register']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}