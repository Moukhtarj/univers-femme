import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReservationScreen extends StatefulWidget {
  final String productName;
  final String selectedLanguage;
  final Map<String, Map<String, String>> translations;

  const ReservationScreen({
    super.key,
    required this.productName,
    required this.selectedLanguage,
    required this.translations,
  });

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTime? _selectedDateTime;

  // Expression régulière pour le nom (lettres, espaces et caractères arabes)
  final RegExp _nameRegExp = RegExp(r'^[\p{L}\s]+$', unicode: true);
  
  // Expression régulière pour le téléphone mauritanien (exactement 8 chiffres commençant par 2, 3, 4 ou 6)
  final RegExp _phoneRegExp = RegExp(r'^[234]\d{7}$');

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectedLanguage == 'Arabic' ? 'حجز' : 'Reservation'),
        backgroundColor: const Color.fromARGB(255, 226, 173, 191),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                widget.productName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: widget.selectedLanguage == 'Arabic' ? 'الاسم الكامل' : 'Nom complet',
                  border: const OutlineInputBorder(),
                  hintText: widget.selectedLanguage == 'Arabic' ? 'أدخل اسمك الكامل' : 'Entrez votre nom complet',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return widget.selectedLanguage == 'Arabic' 
                        ? 'الاسم مطلوب' 
                        : 'Le nom est requis';
                  }
                  if (!_nameRegExp.hasMatch(value)) {
                    return widget.selectedLanguage == 'Arabic'
                        ? 'الاسم يجب أن يحتوي على أحرف فقط'
                        : 'Le nom ne doit contenir que des lettres';
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
                  labelText: widget.selectedLanguage == 'Arabic' ? 'رقم الهاتف' : 'Numéro de téléphone',
                  border: const OutlineInputBorder(),
                  hintText: widget.selectedLanguage == 'Arabic' ? 'مثال: 31234567' : 'Exemple: 31234567',
                  prefixText: '+222 ',
                ),
                keyboardType: TextInputType.phone,
                maxLength: 8,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return widget.selectedLanguage == 'Arabic' 
                        ? 'رقم الهاتف مطلوب' 
                        : 'Le numéro de téléphone est requis';
                  }
                  if (!_phoneRegExp.hasMatch(value)) {
                    return widget.selectedLanguage == 'Arabic'
                        ? 'يجب أن يبدأ رقم الهاتف بـ 2/3/4/ ويتكون من 8 أرقام'
                        : 'Le numéro doit commencer par 2/3/4/6 et contenir 8 chiffres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  widget.selectedLanguage == 'Arabic' 
                      ? 'تاريخ ووقت الحجز' 
                      : 'Date et heure de réservation',
                ),
                subtitle: Text(
                  _selectedDateTime == null
                      ? widget.selectedLanguage == 'Arabic'
                          ? 'اختر التاريخ والوقت'
                          : 'Sélectionnez la date et l\'heure'
                      : DateFormat('dd-MM-yyyy HH:mm').format(_selectedDateTime!),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDateTime(context),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 236, 169, 191),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (_selectedDateTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            widget.selectedLanguage == 'Arabic'
                                ? 'الرجاء اختيار التاريخ والوقت'
                                : 'Veuillez sélectionner une date et une heure',
                          ),
                        ),
                      );
                    } else {
                      _submitReservation();
                    }
                  }
                },
                child: Text(
                  widget.selectedLanguage == 'Arabic' ? 'تأكيد الحجز' : 'Confirmer la réservation',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitReservation() {
    final reservationData = {
      'service': widget.productName,
      'nom': _nameController.text,
      'telephone': '+222${_phoneController.text}',
      'date': DateFormat('dd-MM-yyyy HH:mm').format(_selectedDateTime!),
    };

    print('Données de réservation: $reservationData');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.selectedLanguage == 'Arabic'
              ? 'تم تأكيد الحجز بنجاح!'
              : 'Réservation confirmée avec succès!',
        ),
      ),
    );
    Navigator.pop(context);
  }
}