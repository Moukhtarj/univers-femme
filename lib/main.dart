import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Univers Femme',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: const SplashAnimationScreen(),
    );
  }
}

class SplashAnimationScreen extends StatefulWidget {
  const SplashAnimationScreen({super.key});

  @override
  State<SplashAnimationScreen> createState() => _SplashAnimationScreenState();
}

class _SplashAnimationScreenState extends State<SplashAnimationScreen> {
  String _displayText = '';
  final String _fullText = 'Univers Femme\nكل ما تحتاجه المرأة';
  
  int _currentIndex = 0;
  bool _animationComplete = false;

  @override
  void initState() {
    super.initState();
    _animateText();
  }

  void _animateText() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_currentIndex < _fullText.length) {
        setState(() {
          _displayText = _fullText.substring(0, _currentIndex + 1);
          _currentIndex++;
        });
        _animateText();
      } else {
        setState(() {
          _animationComplete = true;
        });
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const Directionality(
                textDirection: TextDirection.rtl,
                child: WelcomeScreen(),
              ),
            ),
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 185, 185),
      body: Center(
        child: Text(
          _displayText,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.pink,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

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
      'hamam': 'الحمام',
      'mlahfa': 'الملحفة',
      'accessories': 'الإكسسوارات',
      'gym': 'النادي الرياضي',
      'henna': 'الحناء',
    },
    'English': {
      'appTitle': "🌸🎀 Girl's",
      'shop': 'Shop',
      'care': 'Care',
      'health': 'Health',
      'education': 'Education',
      'login': 'Login',
      'register': 'Create Account',
      'loginTitle': 'Login',
      'registerTitle': 'Register',
      'email': 'Email',
      'password': 'Password',
      'fullName': 'Full Name',
      'forgotPassword': 'Forgot Password?',
      'home': 'Home Page',
      'account': 'My Account',
      'logout': 'Logout',
      'hamam': 'Hammam',
      'mlahfa': 'Mlahfa',
      'accessories': 'Accessories',
      'gym': 'Gym',
      'henna': 'Henna',
    },
    'French': {
      'appTitle': "🌸🎀 Girl's",
      'shop': 'Shop',
      'care': 'Soins',
      'health': 'Santé',
      'education': 'Éducation',
      'login': 'Connexion',
      'register': 'Créer un compte',
      'loginTitle': 'Connexion',
      'registerTitle': 'Inscription',
      'email': 'E-mail',
      'password': 'Mot de passe',
      'fullName': 'Nom complet',
      'forgotPassword': 'Mot de passe oublié?',
      'home': 'Page d\'accueil',
      'account': 'Mon Compte',
      'logout': 'Déconnexion',
      'hamam': 'Hammam',
      'mlahfa': 'Mlahfa',
      'accessories': 'Accessoires',
      'gym': 'Gym',
      'henna': 'Henna',
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
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.language, color: Colors.black),
          //   onPressed: () {
          //     Scaffold.of(context).openDrawer();
          //   },
          // ),
        ],
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

class LoginScreen extends StatefulWidget {
  final String selectedLanguage;
  final Map<String, Map<String, String>> translations;
  
  const LoginScreen({
    super.key,
    required this.selectedLanguage,
    required this.translations,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  final RegExp _passwordRegex = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$',
  );

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _changeLanguage(String language) {
    setState(() {
      widget.translations['selectedLanguage'] = language as Map<String, String> ;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 192, 203, 1),
      appBar: AppBar(

        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.menu, color: Colors.black),
          //   onPressed: () {
          //     Scaffold.of(context).openEndDrawer();
          //   },
          // ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromRGBO(255, 192, 203, 1),
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
              title: Text(widget.translations[widget.selectedLanguage]!['language'] ?? 'Language'),
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
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Text(
                  widget.translations[widget.selectedLanguage]!['loginTitle']!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: widget.translations[widget.selectedLanguage]!['username'] ?? 'Username',
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.person, color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return widget.selectedLanguage == 'Arabic' 
                          ? 'اسم المستخدم مطلوب'
                          : widget.selectedLanguage == 'French'
                              ? 'Le nom d\'utilisateur est requis'
                              : 'Username is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: widget.translations[widget.selectedLanguage]!['password']!,
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return widget.selectedLanguage == 'Arabic'
                          ? 'كلمة المرور مطلوبة'
                          : widget.selectedLanguage == 'French'
                              ? 'Le mot de passe est requis'
                              : 'Password is required';
                    }
                    if (!_passwordRegex.hasMatch(value)) {
                      return widget.selectedLanguage == 'Arabic'
                          ? 'يجب أن تحتوي كلمة المرور على 8 أحرف على الأقل وتحتوي على حروف وأرقام'
                          : widget.selectedLanguage == 'French'
                              ? 'Le mot de passe doit contenir au moins 8 caractères avec des lettres et des chiffres'
                              : 'Password must be at least 8 characters with letters and numbers';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
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
                      if (_formKey.currentState!.validate()) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Directionality(
                              textDirection: widget.selectedLanguage == 'Arabic' 
                                  ? TextDirection.rtl 
                                  : TextDirection.ltr,
                              child: HomeScreen(
                                selectedLanguage: widget.selectedLanguage,
                                translations: widget.translations,
                              ),
                            ),
                          ),
                        );
                      }
                    },
                    child: Text(
                      widget.translations[widget.selectedLanguage]!['login']!,
                      style: const TextStyle(
                        color: Color.fromRGBO(255, 192, 203, 1),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    widget.translations[widget.selectedLanguage]!['forgotPassword']!,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class RegisterScreen extends StatefulWidget {
  final String selectedLanguage;
  final Map<String, Map<String, String>> translations;
  
  const RegisterScreen({
    super.key,
    required this.selectedLanguage,
    required this.translations,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  
  final RegExp _passwordRegex = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$',
  );

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 192, 203, 1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Text(
                  widget.translations[widget.selectedLanguage]!['registerTitle']!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: widget.translations[widget.selectedLanguage]!['fullName']!,
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.person, color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return widget.selectedLanguage == 'Arabic'
                          ? 'الاسم الكامل مطلوب'
                          : widget.selectedLanguage == 'French'
                              ? 'Le nom complet est requis'
                              : 'Full name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: widget.translations[widget.selectedLanguage]!['email']!,
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.email, color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return widget.selectedLanguage == 'Arabic'
                          ? 'البريد الإلكتروني مطلوب'
                          : widget.selectedLanguage == 'French'
                              ? 'L\'email est requis'
                              : 'Email is required';
                    }
                    if (!_emailRegex.hasMatch(value)) {
                      return widget.selectedLanguage == 'Arabic'
                          ? 'بريد إلكتروني غير صالح'
                          : widget.selectedLanguage == 'French'
                              ? 'Email invalide'
                              : 'Invalid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: widget.translations[widget.selectedLanguage]!['password']!,
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return widget.selectedLanguage == 'Arabic'
                          ? 'كلمة المرور مطلوبة'
                          : widget.selectedLanguage == 'French'
                              ? 'Le mot de passe est requis'
                              : 'Password is required';
                    }
                    if (!_passwordRegex.hasMatch(value)) {
                      return widget.selectedLanguage == 'Arabic'
                          ? 'يجب أن تحتوي كلمة المرور على 8 أحرف على الأقل وتحتوي على حروف وأرقام'
                          : widget.selectedLanguage == 'French'
                              ? 'Le mot de passe doit contenir au moins 8 caractères avec des lettres et des chiffres'
                              : 'Password must be at least 8 characters with letters and numbers';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
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
                      if (_formKey.currentState!.validate()) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Directionality(
                              textDirection: TextDirection.rtl,
                              child: HomeScreen(
                                selectedLanguage: widget.selectedLanguage,
                                translations: widget.translations,
                              ),
                            ),
                          ),
                        );
                      }
                    },
                    child: Text(
                      widget.translations[widget.selectedLanguage]!['register']!,
                      style: const TextStyle(
                        color: Color.fromRGBO(255, 192, 203, 1),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final String selectedLanguage;
  final Map<String, Map<String, String>> translations;
  
  const HomeScreen({
    super.key,
    required this.selectedLanguage,
    required this.translations,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(translations[selectedLanguage]!['appTitle']!),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.pink,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: Colors.pink),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    translations[selectedLanguage]!['account']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.pink),
              title: Text(translations[selectedLanguage]!['home']!),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.pink),
              title: Text(translations[selectedLanguage]!['account']!),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.pink),
              title: Text(translations[selectedLanguage]!['logout']!),
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
              leading: const Icon(Icons.language, color: Colors.pink),
              title: Text(translations[selectedLanguage]!['language'] ?? 'Language'),
              children: [
                ListTile(
                  title: const Text('العربية'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Directionality(
                          textDirection: TextDirection.rtl,
                          child: HomeScreen(
                            selectedLanguage: 'Arabic',
                            translations: translations,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: const Text('English'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Directionality(
                          textDirection: TextDirection.ltr,
                          child: HomeScreen(
                            selectedLanguage: 'English',
                            translations: translations,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: const Text('Français'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Directionality(
                          textDirection: TextDirection.ltr,
                          child: HomeScreen(
                            selectedLanguage: 'French',
                            translations: translations,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildCategoryCard(
              context,
              'assets/images/bath.jpg',
              translations[selectedLanguage]!['hamam']!,
            ),
            _buildCategoryCard(
              context,
              'assets/images/melh.jpg',
              translations[selectedLanguage]!['mlahfa']!,
            ),
            _buildCategoryCard(
              context,
              'assets/images/acc.jpg',
              translations[selectedLanguage]!['accessories']!,
            ),
            _buildCategoryCard(
              context,
              'assets/images/gym.jpg',
              translations[selectedLanguage]!['gym']!,
            ),
            _buildCategoryCard(
              context,
              'assets/images/henna.jpg',
              translations[selectedLanguage]!['henna']!,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String imagePath, String title) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.asset(
                imagePath,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}