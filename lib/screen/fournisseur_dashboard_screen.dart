import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'manage_commands_screen.dart';
import 'manage_reservations_screen.dart';
import 'manage_services_screen.dart';
import 'profile_screen.dart';
import 'fournisseur_notification_screen.dart';

class FournisseurDashboardScreen extends StatefulWidget {
  const FournisseurDashboardScreen({super.key});

  @override
  State<FournisseurDashboardScreen> createState() =>
      _FournisseurDashboardScreenState();
}

class _FournisseurDashboardScreenState
    extends State<FournisseurDashboardScreen> with TickerProviderStateMixin {
  String _selectedLanguage = 'English';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final Map<String, Map<String, String>> _dashboardTranslations = {
    'English': {
      'dashboardTitle': 'Dashboard',
      'manageServices': 'Services',
      'manageReservations': 'Reservations',
      'manageOrders': 'Orders',
      'profile': 'Profile',
      'welcome': 'Welcome back!',
      'notifications': 'Notifications',
      'settings': 'Settings',
      'logout': 'Logout',
      'manageYourServices': 'Manage Your Services',
      'manageYourReservations': 'Manage Your Reservations',
      'manageYourOrders': 'Manage Your Orders',
      'manageBusiness': 'Manage your business efficiently',
      'managementDashboard': 'Management Dashboard',
      'tapToManage': 'Tap to Manage',
    },
    'French': {
      'dashboardTitle': 'Tableau de Bord',
      'manageServices': 'Services',
      'manageReservations': 'Réservations',
      'manageOrders': 'Commandes',
      'profile': 'Profil',
      'welcome': 'Bon retour!',
      'notifications': 'Notifications',
      'settings': 'Paramètres',
      'logout': 'Déconnexion',
      'manageYourServices': 'Gérer Vos Services',
      'manageYourReservations': 'Gérer Vos Réservations',
      'manageYourOrders': 'Gérer Vos Commandes',
      'manageBusiness': 'Gérez votre entreprise efficacement',
      'managementDashboard': 'Tableau de Bord de Gestion',
      'tapToManage': 'Appuyez pour Gérer',
    },
    'Arabic': {
      'dashboardTitle': 'لوحة التحكم',
      'manageServices': 'الخدمات',
      'manageReservations': 'الحجوزات',
      'manageOrders': 'الطلبات',
      'profile': 'الملف الشخصي',
      'welcome': 'مرحباً بعودتك!',
      'notifications': 'الإشعارات',
      'settings': 'الإعدادات',
      'logout': 'تسجيل الخروج',
      'manageYourServices': 'إدارة خدماتك',
      'manageYourReservations': 'إدارة حجوزاتك',
      'manageYourOrders': 'إدارة طلباتك',
      'manageBusiness': 'إدارة عملك بكفاءة',
      'managementDashboard': 'لوحة إدارة الأعمال',
      'tapToManage': 'انقر للإدارة',
    },
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _changeLanguage(String newLanguage) {
    setState(() {
      _selectedLanguage = newLanguage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      drawer: _buildDrawer(),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color.fromRGBO(255, 192, 203, 1),
            elevation: 0,
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  _dashboardTranslations[_selectedLanguage]!['dashboardTitle']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.fromRGBO(255, 192, 203, 1),
                      Color.fromRGBO(255, 182, 193, 1),
                      Color.fromRGBO(255, 172, 183, 1),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: FadeTransition(
                                opacity: _fadeAnimation,
                                child: Text(
                                  _dashboardTranslations[_selectedLanguage]!['welcome']!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: DropdownButton<String>(
                                    value: _selectedLanguage,
                                    onChanged: (String? newValue) {
                                      if (newValue != null) {
                                        _changeLanguage(newValue);
                                      }
                                    },
                                    icon: const Icon(Icons.language, color: Colors.white),
                                    dropdownColor: const Color.fromRGBO(255, 192, 203, 1),
                                    underline: Container(),
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    items: <String>['English', 'French', 'Arabic']
                                        .map<DropdownMenuItem<String>>((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.notifications, color: Colors.white),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const FournisseurNotificationScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Text(
                            _dashboardTranslations[_selectedLanguage]!['manageBusiness']!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Management Cards Section
                    _buildManagementCardsSection(),
                    const SizedBox(height: 20), // Bottom padding
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(255, 192, 203, 1),
              Color.fromRGBO(255, 182, 193, 1),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Icon(
                        Icons.business,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Provider Dashboard',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Manage your services',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white54, height: 32),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildDrawerItem(
                      icon: Icons.dashboard,
                      title: _dashboardTranslations[_selectedLanguage]!['dashboardTitle']!,
                      onTap: () {
                        Navigator.pop(context);
                      },
                      isSelected: true,
                    ),
                    _buildDrawerItem(
                      icon: Icons.business_center,
                      title: _dashboardTranslations[_selectedLanguage]!['manageServices']!,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ManageServicesScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.event_note,
                      title: _dashboardTranslations[_selectedLanguage]!['manageReservations']!,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ManageReservationsScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.shopping_bag,
                      title: _dashboardTranslations[_selectedLanguage]!['manageOrders']!,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ManageCommandsScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.notifications,
                      title: _dashboardTranslations[_selectedLanguage]!['notifications']!,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FournisseurNotificationScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(color: Colors.white54, height: 32),
                    _buildDrawerItem(
                      icon: Icons.person_outline,
                      title: _dashboardTranslations[_selectedLanguage]!['profile']!,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileScreen(
                              selectedLanguage: _selectedLanguage,
                              translations: const {},
                            ),
                          ),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.settings,
                      title: _dashboardTranslations[_selectedLanguage]!['settings']!,
                      onTap: () {
                        Navigator.pop(context);
                        // Add settings navigation
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.logout,
                      title: _dashboardTranslations[_selectedLanguage]!['logout']!,
                      onTap: () {
                        Navigator.pop(context);
                        // Add logout logic
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildManagementCardsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Text(
            _dashboardTranslations[_selectedLanguage]!['managementDashboard']!,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ),
        
        // Horizontal Cards - Changed to horizontal layout
        SizedBox(
          height: 200, // Fixed height for horizontal cards
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            children: [
              _buildAnimatedManagementCard(
                title: _dashboardTranslations[_selectedLanguage]!['manageReservations']!,
                subtitle: _dashboardTranslations[_selectedLanguage]!['manageYourReservations']!,
                icon: Icons.event_note,
                gradient: const LinearGradient(
                  colors: [Color(0xFFE74C3C), Color(0xFFC0392B)],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ManageReservationsScreen(),
                    ),
                  );
                },
                delay: 0,
              ),
              const SizedBox(width: 20),
              _buildAnimatedManagementCard(
                title: _dashboardTranslations[_selectedLanguage]!['manageServices']!,
                subtitle: _dashboardTranslations[_selectedLanguage]!['manageYourServices']!,
                icon: Icons.business_center,
                gradient: const LinearGradient(
                  colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ManageServicesScreen(),
                    ),
                  );
                },
                delay: 200,
              ),
              const SizedBox(width: 20),
              _buildAnimatedManagementCard(
                title: _dashboardTranslations[_selectedLanguage]!['manageOrders']!,
                subtitle: _dashboardTranslations[_selectedLanguage]!['manageYourOrders']!,
                icon: Icons.shopping_bag,
                gradient: const LinearGradient(
                  colors: [Color(0xFFF39C12), Color(0xFFE67E22)],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ManageCommandsScreen(),
                    ),
                  );
                },
                delay: 400,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedManagementCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (value * 0.2),
          child: Opacity(
            opacity: value,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                width: 280,
                height: 200,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(24),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Icon and Title
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  icon,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      subtitle,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          // Action Button
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _dashboardTranslations[_selectedLanguage]!['tapToManage']!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
} 