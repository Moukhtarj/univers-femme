import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GymScreen extends StatelessWidget {
  final String selectedLanguage;
  final Map<String, Map<String, String>> translations;
  
  const GymScreen({
    super.key,
    required this.selectedLanguage,
    required this.translations,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(translations[selectedLanguage]!['gym']!),
        backgroundColor: const Color.fromARGB(255, 233, 170, 191),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildGymCard(
              context,
              'assets/images/gim2.jpeg',
              selectedLanguage == 'Arabic' ? 'نادي فايكنج الرياضي' : 'Viking Fitness Club',
              selectedLanguage == 'Arabic' ? 'نواكشوط، تفرغ زينة' : 'Nouakchott, Tevragh Zeina',
              '80 MRU',
              '1500 MRU',
            ),
            _buildGymCard(
              context,
              'assets/images/gim.jpg',
              selectedLanguage == 'Arabic' ? 'نادي القوة الذهبية' : 'Golden Power Gym',
              selectedLanguage == 'Arabic' ? 'نواكشوط، الرياض' : 'Nouakchott, El Riyadh',
              '60 MRU',
              '1000 MRU',
            ),
            _buildGymCard(
              context,
              'assets/images/gim3.jpg',
              selectedLanguage == 'Arabic' ? 'مركز اللياقة البدنية' : 'Fitness Center',
              selectedLanguage == 'Arabic' ? 'نواكشوط، لكصر' : 'Nouakchott, El Ksar',
              '100 MRU',
              '2000 MRU',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGymCard(BuildContext context, String imagePath, String name, String location, String dailyPrice, String monthlyPrice) {
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
                    child: Icon(Icons.fitness_center, size: 40, color: Colors.grey[400]),
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
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.pink),
                      const SizedBox(width: 4),
                      Text(
                        location,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedLanguage == 'Arabic' ? 'يوم واحد' : '1 Day',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            dailyPrice,
                            style: const TextStyle(

                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 236, 173, 194),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedLanguage == 'Arabic' ? 'شهر كامل' : '1 Month',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            monthlyPrice,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 237, 176, 196),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 237, 181, 200),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubscriptionScreen(
                              gymName: name,
                              dailyPrice: dailyPrice,
                              monthlyPrice: monthlyPrice,
                              selectedLanguage: selectedLanguage,
                              translations: translations,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        selectedLanguage == 'Arabic' ? 'اشتراك' : 'Subscribe',
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

// Keep the SubscriptionScreen and ExpandedSection classes the same as in your original code


class SubscriptionScreen extends StatefulWidget {
  final String gymName;
  final String dailyPrice;
  final String monthlyPrice;
  final String selectedLanguage;
  final Map<String, Map<String, String>> translations;

  const SubscriptionScreen({
    super.key,
    required this.gymName,
    required this.dailyPrice,
    required this.monthlyPrice,
    required this.selectedLanguage,
    required this.translations,
  });

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  String _subscriptionType = 'daily';
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  // Regular expressions for validation
  final RegExp _nameRegExp = RegExp(r'^[\p{L}\s]+$', unicode: true);
  final RegExp _phoneRegExp = RegExp(r'^[234]\d{7}$');

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.pink,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.pink,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.selectedLanguage == 'Arabic'
                ? 'تم الاشتراك بنجاح في ${widget.gymName}'
                : 'Successfully subscribed to ${widget.gymName}',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectedLanguage == 'Arabic' ? 'نموذج الاشتراك' : 'Subscription Form'),
        backgroundColor: const Color.fromARGB(255, 233, 172, 192),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.gymName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink,
                ),
              ),
              const SizedBox(height: 20),
              
              // Subscription Type Selection
              Text(
                widget.selectedLanguage == 'Arabic' 
                    ? 'نوع الاشتراك:' 
                    : 'Subscription Type:',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ExpandedSection(
                child: Column(
                  children: [
                    RadioListTile(
                      title: Text(
                        widget.selectedLanguage == 'Arabic'
                            ? 'يوم واحد (${widget.dailyPrice})'
                            : '1 Day (${widget.dailyPrice})',
                      ),
                      value: 'daily',
                      groupValue: _subscriptionType,
                      activeColor: const Color.fromARGB(255, 242, 168, 193),
                      onChanged: (value) {
                        setState(() {
                          _subscriptionType = value.toString();
                        });
                      },
                    ),
                    RadioListTile(
                      title: Text(
                        widget.selectedLanguage == 'Arabic'
                            ? 'شهر كامل (${widget.monthlyPrice})'
                            : '1 Month (${widget.monthlyPrice})',
                      ),
                      value: 'monthly',
                      groupValue: _subscriptionType,
                      activeColor: const Color.fromARGB(255, 232, 170, 190),
                      onChanged: (value) {
                        setState(() {
                          _subscriptionType = value.toString();
                        });
                      },
                    ),
                  ],
                ),
              ),
              
              // Personal Information
              Text(
                widget.selectedLanguage == 'Arabic' 
                    ? 'المعلومات الشخصية:' 
                    : 'Personal Information:',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ExpandedSection(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: widget.selectedLanguage == 'Arabic' 
                            ? 'الاسم الكامل' 
                            : 'Full Name',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return widget.selectedLanguage == 'Arabic'
                              ? 'الرجاء إدخال الاسم'
                              : 'Please enter your name';
                        }
                         if (value.length < 3) {
                    return widget.selectedLanguage == 'Arabic'
                        ? 'الاسم يجب أن يكون على الأقل 3 أحرف'
                        : 'Le nom doit contenir au moins 3 caractères';
                  }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: widget.selectedLanguage == 'Arabic' 
                            ? 'رقم الهاتف' 
                            : 'Phone Number',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return widget.selectedLanguage == 'Arabic'
                              ? 'الرجاء إدخال رقم الهاتف'
                              : 'Please enter your phone number';
                        }
                        if (!_phoneRegExp.hasMatch(value)) {
                    return widget.selectedLanguage == 'Arabic'
                        ? 'يجب أن يبدأ رقم الهاتف بـ 2/3/4/ ويتكون من 8 أرقام'
                        : 'Le numéro doit commencer par 2/3/4/6 et contenir 8 chiffres';
                  }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              
              // Date Selection
              Text(
                widget.selectedLanguage == 'Arabic' 
                    ? 'تاريخ البدء:' 
                    : 'Start Date:',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ExpandedSection(
                child: TextFormField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    labelText: widget.selectedLanguage == 'Arabic' 
                        ? 'اختر التاريخ' 
                        : 'Select Date',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return widget.selectedLanguage == 'Arabic'
                          ? 'الرجاء اختيار التاريخ'
                          : 'Please select a date';
                    }
                    return null;
                  },
                ),
              ),
              
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 245, 173, 197),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _submitForm,
                  child: Text(
                    widget.selectedLanguage == 'Arabic' 
                        ? 'تأكيد الاشتراك' 
                        : 'Confirm Subscription',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
               const SizedBox(height: 20), // Extra space at bottom
            ],
          ),
        ),
      ),
    );
  }
}

class ExpandedSection extends StatefulWidget {
  final Widget child;
  final bool expand;

  const ExpandedSection({
    super.key,
    this.expand = true,
    required this.child,
  });

  @override
  State<ExpandedSection> createState() => _ExpandedSectionState();
}

class _ExpandedSectionState extends State<ExpandedSection> with SingleTickerProviderStateMixin {
  late AnimationController expandController;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    prepareAnimations();
    _runExpandCheck();
  }

  void prepareAnimations() {
    expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    animation = CurvedAnimation(
      parent: expandController,
      curve: Curves.fastOutSlowIn,
    );
  }

  void _runExpandCheck() {
    if (widget.expand) {
      expandController.forward();
    } else {
      expandController.reverse();
    }
  }

  @override
  void didUpdateWidget(ExpandedSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _runExpandCheck();
  }

  @override
  void dispose() {
    expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      axisAlignment: 1.0,
      sizeFactor: animation,
      child: widget.child,
    );
  }
}