import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config.dart';

class ManageReservationsScreen extends StatefulWidget {
  const ManageReservationsScreen({super.key});

  @override
  State<ManageReservationsScreen> createState() => _ManageReservationsScreenState();
}

class _ManageReservationsScreenState extends State<ManageReservationsScreen>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _reservations = [];
  bool _isLoading = true;
  String? _error;
  String _selectedFilter = 'all';
  String _selectedLanguage = 'en';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> _filterOptions = [
    'all',
    'pending',
    'confirmed',
    'completed',
    'cancelled',
  ];

  // Local translations
  final Map<String, Map<String, String>> _translations = {
    'en': {
      'reservations': 'Reservations',
      'filter_reservations': 'Filter Reservations',
      'all': 'All',
      'pending': 'Pending',
      'confirmed': 'Confirmed',
      'completed': 'Completed',
      'cancelled': 'Cancelled',
      'loading_reservations': 'Loading reservations...',
      'no_reservations': 'No reservations found',
      'no_reservations_message': 'You don\'t have any reservations yet',
      'no_filtered_reservations': 'No reservations found',
      'retry': 'Retry',
      'error': 'Error',
      'something_went_wrong': 'Oops! Something went wrong',
      'reservation_status_updated': 'Reservation status updated to',
      'failed_to_update': 'Failed to update reservation',
      'failed_to_load': 'Failed to load reservations',
      'no_auth_token': 'No authentication token found',
      'client_information': 'Client Information',
      'reservation_details': 'Reservation Details',
      'comments': 'Comments',
      'name': 'Name',
      'phone': 'Phone',
      'date': 'Date',
      'amount': 'Amount',
      'confirm': 'Confirm',
      'complete': 'Complete',
      'cancel': 'Cancel',
      'view_details': 'View Details',
      'close': 'Close',
      'unknown_client': 'Unknown Client',
      'no_phone': 'No phone',
      'unknown': 'Unknown',
      'payment_proof': 'Payment Proof',
      'view_payment_proof': 'View Payment Proof',
      'opening_payment_proof': 'Opening payment proof',
      'rejection_reason': 'Rejection Reason',
      'customer_information': 'Customer Information',
      'order_details': 'Order Details',
      'product_information': 'Product Information',
      'provider_information': 'Provider Information',
      'payment_confirmation': 'Payment & Confirmation',
      'start_date': 'Start Date',
      'end_date': 'End Date',
      'total_amount': 'Total Amount',
      'service_type': 'Service Type',
      'product_name': 'Product Name',
      'description': 'Description',
      'provider_name': 'Provider Name',
      'provider_phone': 'Provider Phone',
      'payment_status': 'Payment Status',
      'owner_confirmed': 'Owner Confirmed',
      'payment_verified': 'Payment Verified',
      'paid': 'Paid',
      'not_paid': 'Not Paid',
      'yes': 'Yes',
      'no': 'No',
      'no_payment_proof': 'No payment proof available',
      'payment_proof_document': 'Payment proof document:',
      'unknown_product': 'Unknown Product',
      'no_email': 'No email',
      'try_again': 'Try Again',
    },
    'fr': {
      'reservations': 'Réservations',
      'filter_reservations': 'Filtrer les Réservations',
      'all': 'Tout',
      'pending': 'En Attente',
      'confirmed': 'Confirmé',
      'completed': 'Terminé',
      'cancelled': 'Annulé',
      'loading_reservations': 'Chargement des réservations...',
      'no_reservations': 'Aucune réservation trouvée',
      'no_reservations_message': 'Vous n\'avez pas encore de réservations',
      'no_filtered_reservations': 'Aucune réservation trouvée',
      'retry': 'Réessayer',
      'error': 'Erreur',
      'something_went_wrong': 'Oups ! Quelque chose s\'est mal passé',
      'reservation_status_updated': 'Statut de réservation mis à jour vers',
      'failed_to_update': 'Échec de la mise à jour de la réservation',
      'failed_to_load': 'Échec du chargement des réservations',
      'no_auth_token': 'Aucun token d\'authentification trouvé',
      'client_information': 'Informations Client',
      'reservation_details': 'Détails de Réservation',
      'comments': 'Commentaires',
      'name': 'Nom',
      'phone': 'Téléphone',
      'date': 'Date',
      'amount': 'Montant',
      'confirm': 'Confirmer',
      'complete': 'Terminer',
      'cancel': 'Annuler',
      'view_details': 'Voir les Détails',
      'close': 'Fermer',
      'unknown_client': 'Client Inconnu',
      'no_phone': 'Pas de téléphone',
      'unknown': 'Inconnu',
      'payment_proof': 'Preuve de Paiement',
      'view_payment_proof': 'Voir la Preuve de Paiement',
      'opening_payment_proof': 'Ouverture de la preuve de paiement',
      'rejection_reason': 'Raison du Refus',
      'customer_information': 'Informations Client',
      'order_details': 'Détails de la Commande',
      'product_information': 'Informations Produit',
      'provider_information': 'Informations Fournisseur',
      'payment_confirmation': 'Paiement et Confirmation',
      'start_date': 'Date de Début',
      'end_date': 'Date de Fin',
      'total_amount': 'Montant Total',
      'service_type': 'Type de Service',
      'product_name': 'Nom du Produit',
      'description': 'Description',
      'provider_name': 'Nom du Fournisseur',
      'provider_phone': 'Téléphone du Fournisseur',
      'payment_status': 'Statut du Paiement',
      'owner_confirmed': 'Confirmé par le Propriétaire',
      'payment_verified': 'Paiement Vérifié',
      'paid': 'Payé',
      'not_paid': 'Non Payé',
      'yes': 'Oui',
      'no': 'Non',
      'no_payment_proof': 'Aucune preuve de paiement disponible',
      'payment_proof_document': 'Document de preuve de paiement:',
      'unknown_product': 'Produit Inconnu',
      'no_email': 'Pas d\'email',
      'try_again': 'Réessayer',
    },
    'ar': {
      'reservations': 'الحجوزات',
      'filter_reservations': 'تصفية الحجوزات',
      'all': 'الكل',
      'pending': 'في الانتظار',
      'confirmed': 'مؤكد',
      'completed': 'مكتمل',
      'cancelled': 'ملغي',
      'loading_reservations': 'جاري تحميل الحجوزات...',
      'no_reservations': 'لا توجد حجوزات',
      'no_reservations_message': 'ليس لديك أي حجوزات بعد',
      'no_filtered_reservations': 'لا توجد حجوزات',
      'retry': 'إعادة المحاولة',
      'error': 'خطأ',
      'something_went_wrong': 'عذراً! حدث خطأ ما',
      'reservation_status_updated': 'تم تحديث حالة الحجز إلى',
      'failed_to_update': 'فشل في تحديث الحجز',
      'failed_to_load': 'فشل في تحميل الحجوزات',
      'no_auth_token': 'لم يتم العثور على رمز المصادقة',
      'client_information': 'معلومات العميل',
      'reservation_details': 'تفاصيل الحجز',
      'comments': 'التعليقات',
      'name': 'الاسم',
      'phone': 'الهاتف',
      'date': 'التاريخ',
      'amount': 'المبلغ',
      'confirm': 'تأكيد',
      'complete': 'إكمال',
      'cancel': 'إلغاء',
      'view_details': 'عرض التفاصيل',
      'close': 'إغلاق',
      'unknown_client': 'عميل غير معروف',
      'no_phone': 'لا يوجد هاتف',
      'unknown': 'غير معروف',
      'payment_proof': 'إثبات الدفع',
      'view_payment_proof': 'عرض إثبات الدفع',
      'opening_payment_proof': 'فتح إثبات الدفع',
      'rejection_reason': 'سبب الرفض',
      'customer_information': 'معلومات العميل',
      'order_details': 'تفاصيل الطلب',
      'product_information': 'معلومات المنتج',
      'provider_information': 'معلومات المزود',
      'payment_confirmation': 'الدفع والتأكيد',
      'start_date': 'تاريخ البداية',
      'end_date': 'تاريخ الانتهاء',
      'total_amount': 'المبلغ الإجمالي',
      'service_type': 'نوع الخدمة',
      'product_name': 'اسم المنتج',
      'description': 'الوصف',
      'provider_name': 'اسم المزود',
      'provider_phone': 'هاتف المزود',
      'payment_status': 'حالة الدفع',
      'owner_confirmed': 'تم تأكيد المالك',
      'payment_verified': 'تم التحقق من الدفع',
      'paid': 'مدفوع',
      'not_paid': 'غير مدفوع',
      'yes': 'نعم',
      'no': 'لا',
      'no_payment_proof': 'لا يوجد إثبات دفع',
      'payment_proof_document': 'مستند إثبات الدفع:',
      'unknown_product': 'منتج غير معروف',
      'no_email': 'لا يوجد بريد إلكتروني',
      'try_again': 'إعادة المحاولة',
    },
  };

  String _getTranslation(String key) {
    // Use selected language, fallback to English
    return _translations[_selectedLanguage]?[key] ?? _translations['en']?[key] ?? key;
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
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
    _loadReservations();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadReservations() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception(_getTranslation('no_auth_token'));
      }

      final response = await http.get(
        Uri.parse('${Config.apiUrl}/api/reservations/owner/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<Map<String, dynamic>> reservations = [];
        
        // Handle different response structures
        if (data is Map<String, dynamic>) {
          if (data.containsKey('results') && data['results'] is List) {
            reservations = List<Map<String, dynamic>>.from(data['results']);
          } else if (data.containsKey('data') && data['data'] is List) {
            reservations = List<Map<String, dynamic>>.from(data['data']);
          } else {
            // If no recognizable structure, set empty list
            print('Could not parse reservations from response structure');
            reservations = [];
          }
        } else if (data is List) {
          reservations = List<Map<String, dynamic>>.from(data);
        }
        
        // Convert string IDs to integers if needed
        for (var reservation in reservations) {
          if (reservation['id'] is String) {
            reservation['id'] = int.tryParse(reservation['id']) ?? 0;
          }
        }
        
        print('Loaded ${reservations.length} reservations');
        setState(() {
          _reservations = reservations;
          _isLoading = false;
        });
      } else {
        throw Exception('${_getTranslation('failed_to_load')}: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updateReservationStatus(dynamic reservationId, String status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception(_getTranslation('no_auth_token'));
      }

      final response = await http.patch(
        Uri.parse('${Config.apiUrl}/api/reservations/owner/$reservationId/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'statut': status}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_getTranslation('reservation_status_updated')} $status'),
            backgroundColor: _getStatusColor(status),
          ),
        );
        _loadReservations();
      } else {
        throw Exception('${_getTranslation('failed_to_update')}: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_getTranslation('error')}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<Map<String, dynamic>> get _filteredReservations {
    if (_selectedFilter == 'all') {
      return _reservations;
    }
    return _reservations.where((reservation) {
      return reservation['statut']?.toLowerCase() == _selectedFilter.toLowerCase();
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return const Color(0xFF27AE60);
      case 'pending':
        return const Color(0xFFF39C12);
      case 'cancelled':
        return const Color(0xFFE74C3C);
      case 'completed':
        return const Color(0xFF3498DB);
      default:
        return const Color(0xFF95A5A6);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Icons.check_circle;
      case 'pending':
        return Icons.schedule;
      case 'cancelled':
        return Icons.cancel;
      case 'completed':
        return Icons.done_all;
      default:
        return Icons.info;
    }
  }

  IconData _getServiceIcon(String serviceType) {
    switch (serviceType?.toLowerCase()) {
      case 'hammam':
        return Icons.spa;
      case 'melhfa':
        return Icons.checkroom;
      case 'henna':
        return Icons.back_hand;
      case 'makeup':
        return Icons.brush;
      case 'gym':
        return Icons.sports_gymnastics;
      case 'accessory':
        return Icons.diamond;
      default:
        return Icons.category;
    }
  }

  Color _getServiceColor(String serviceType) {
    switch (serviceType?.toLowerCase()) {
      case 'hammam':
        return const Color(0xFF3498DB);
      case 'melhfa':
        return const Color(0xFFE74C3C);
      case 'henna':
        return const Color(0xFF8E44AD);
      case 'makeup':
        return const Color(0xFFE91E63);
      case 'gym':
        return const Color(0xFF27AE60);
      case 'accessory':
        return const Color(0xFFF39C12);
      default:
        return const Color(0xFF95A5A6);
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          _getTranslation('reservations'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: const Color.fromRGBO(255, 192, 203, 1),
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButton<String>(
              value: _selectedLanguage,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedLanguage = newValue;
                  });
                }
              },
              icon: const Icon(Icons.language, color: Colors.white),
              dropdownColor: const Color.fromRGBO(255, 192, 203, 1),
              underline: Container(),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              items: <String>['en', 'fr', 'ar']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value.toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _loadReservations,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Enhanced Filter Section
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(255, 192, 203, 1).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.filter_list,
                        color: Color.fromRGBO(255, 192, 203, 1),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _getTranslation('filter_reservations'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filterOptions.map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return Container(
                        margin: const EdgeInsets.only(right: 12),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedFilter = filter;
                              });
                            },
                            borderRadius: BorderRadius.circular(25),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? const LinearGradient(
                                        colors: [
                                          Color.fromRGBO(255, 192, 203, 1),
                                          Color.fromRGBO(255, 182, 193, 1),
                                        ],
                                      )
                                    : null,
                                color: isSelected ? null : Colors.grey[100],
                                borderRadius: BorderRadius.circular(25),
                                border: isSelected
                                    ? null
                                    : Border.all(color: Colors.grey[300]!),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getStatusIcon(filter),
                                    color: isSelected ? Colors.white : _getStatusColor(filter),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    filter.toUpperCase(),
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : _getStatusColor(filter),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          
          // Reservations List
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(255, 192, 203, 1).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const CircularProgressIndicator(
                            color: Color.fromRGBO(255, 192, 203, 1),
                            strokeWidth: 3,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _getTranslation('loading_reservations'),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF7F8C8D),
                          ),
                        ),
                      ],
                    ),
                  )
                : _error != null
                    ? Center(
                        child: Container(
                          margin: const EdgeInsets.all(20),
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _getTranslation('something_went_wrong'),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${_getTranslation('error')}: $_error',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF7F8C8D),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: _loadReservations,
                                icon: const Icon(Icons.refresh),
                                label: Text(_getTranslation('try_again')),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromRGBO(255, 192, 203, 1),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _filteredReservations.isEmpty
                        ? Center(
                            child: Container(
                              margin: const EdgeInsets.all(20),
                              padding: const EdgeInsets.all(30),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: const Color.fromRGBO(255, 192, 203, 1).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Icon(
                                      Icons.event_note,
                                      size: 48,
                                      color: Color.fromRGBO(255, 192, 203, 1),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _getTranslation('no_reservations'),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2C3E50),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _selectedFilter == 'all'
                                        ? _getTranslation('no_reservations_message')
                                        : '${_getTranslation('no_filtered_reservations')} ${_selectedFilter}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF7F8C8D),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: _filteredReservations.length,
                            itemBuilder: (context, index) {
                              final reservation = _filteredReservations[index];
                              return FadeTransition(
                                opacity: _fadeAnimation,
                                child: _buildModernReservationCard(reservation),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernReservationCard(Map<String, dynamic> reservation) {
    final status = reservation['statut'] ?? 'pending';
    final serviceType = reservation['service_type'] ?? 'unknown';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with gradient
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _getServiceColor(serviceType).withOpacity(0.1),
                  _getServiceColor(serviceType).withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                // Service Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getServiceColor(serviceType).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _getServiceIcon(serviceType),
                    color: _getServiceColor(serviceType),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Service Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reservation['service_name'] ?? 'Unknown Service',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Text(
                      //   'Reservation #${reservation['id']}',
                      //   style: const TextStyle(
                      //     fontSize: 14,
                      //     color: Color(0xFF7F8C8D),
                      //   ),
                      // ),
                    ],
                  ),
                ),
                
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getStatusColor(status),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(status),
                        color: _getStatusColor(status),
                        size: 12,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(status),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Client Information
                _buildInfoSection(
                  _getTranslation('client_information'),
                  Icons.person,
                  [
                    _buildInfoRow(_getTranslation('name'), reservation['user_name'] ?? _getTranslation('unknown_client')),
                    _buildInfoRow(_getTranslation('phone'), reservation['client_phone'] ?? _getTranslation('no_phone')),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Reservation Details
                _buildInfoSection(
                  _getTranslation('reservation_details'),
                  Icons.event,
                  [
                    _buildInfoRow(_getTranslation('date'), _formatDate(reservation['date_debut'])),
                    _buildInfoRow(_getTranslation('amount'), '\$${reservation['montant_total']?.toString() ?? '0'}'),
                  ],
                ),
                
                if (reservation['commentaire']?.isNotEmpty == true) ...[
                  const SizedBox(height: 20),
                  _buildInfoSection(
                    _getTranslation('comments'),
                    Icons.comment,
                    [
                      _buildInfoRow('', reservation['commentaire']),
                    ],
                  ),
                ],
                
                const SizedBox(height: 20),
                
                // Action Buttons
                Row(
                  children: [
                    if (status == 'pending')
                      Expanded(
                        child: _buildActionButton(
                          _getTranslation('confirm'),
                          Icons.check,
                          const Color(0xFF27AE60),
                          () => _updateReservationStatus(
                            reservation['id'] is String ? int.tryParse(reservation['id']) ?? 0 : reservation['id'],
                            'confirmed',
                          ),
                        ),
                      ),
                    if (status == 'confirmed')
                      Expanded(
                        child: _buildActionButton(
                          _getTranslation('complete'),
                          Icons.done_all,
                          const Color(0xFF3498DB),
                          () => _updateReservationStatus(
                            reservation['id'] is String ? int.tryParse(reservation['id']) ?? 0 : reservation['id'],
                            'completed',
                          ),
                        ),
                      ),
                    if (['pending', 'confirmed'].contains(status)) ...[
                      if (status == 'pending' || status == 'confirmed')
                        const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          _getTranslation('cancel'),
                          Icons.cancel,
                          const Color(0xFFE74C3C),
                          () => _updateReservationStatus(
                            reservation['id'] is String ? int.tryParse(reservation['id']) ?? 0 : reservation['id'],
                            'cancelled',
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // View Details Button
                SizedBox(
                  width: double.infinity,
                  child: _buildActionButton(
                    _getTranslation('view_details'),
                    Icons.visibility,
                    const Color.fromRGBO(255, 192, 203, 1),
                    () => _showReservationDetails(reservation),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color.fromRGBO(255, 192, 203, 1), size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) ...[
            SizedBox(
              width: 80,
              child: Text(
                '$label:',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF7F8C8D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
    );
  }

  void _showReservationDetails(Map<String, dynamic> reservation) {
    final status = reservation['statut'] ?? 'pending';
    final serviceType = reservation['service_type'] ?? 'unknown';
    final isPaid = status == 'paid' || reservation['est_paye'] == true;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color.fromRGBO(255, 192, 203, 1),
                        const Color.fromRGBO(255, 182, 193, 1),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getServiceIcon(serviceType),
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reservation['service_name'] ?? 'Unknown Service',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // Text(
                            //   'Reservation #${reservation['id']}',
                            //   style: const TextStyle(
                            //     color: Colors.white70,
                            //     fontSize: 14,
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Client Information Section
                        _buildDetailSection(
                          'Client Information',
                          Icons.person,
                          [
                            _buildDetailRow('Name', reservation['user_name'] ?? 'Unknown Client'),
                            _buildDetailRow('Phone', reservation['client_phone'] ?? 'No phone'),
                            // _buildDetailRow('Email', reservation['client_email'] ?? 'No email'),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Reservation Details Section
                        _buildDetailSection(
                          _getTranslation('reservation_details'),
                          Icons.event_note,
                          [
                            _buildDetailRow(_getTranslation('start_date'), _formatDate(reservation['date_debut'])),
                            _buildDetailRow(_getTranslation('end_date'), _formatDate(reservation['date_fin'])),
                            // _buildDetailRow('Created', _formatDate(reservation['date_creation'])),
                            // _buildDetailRow('Modified', _formatDate(reservation['date_modification'])),
                            _buildDetailRow(_getTranslation('total_amount'), '\$${reservation['montant_total']?.toString() ?? '0'}'),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Service Information Section
                        _buildDetailSection(
                          _getTranslation('service_type'),
                          Icons.business_center,
                          [
                            _buildDetailRow(_getTranslation('service_type'), serviceType.toUpperCase()),
                            _buildDetailRow(_getTranslation('product_name'), reservation['service_name'] ?? _getTranslation('unknown_product')),
                            if (reservation['service_description'] != null)
                              _buildDetailRow(_getTranslation('description'), reservation['service_description']),
                          ],
                        ),
                        
                        if (reservation['commentaire']?.isNotEmpty == true) ...[
                          const SizedBox(height: 20),
                          _buildDetailSection(
                            _getTranslation('comments'),
                            Icons.comment,
                            [
                              _buildDetailRow('', reservation['commentaire']),
                            ],
                          ),
                        ],
                        
                        if (isPaid && reservation['preuve_paiement'] != null) ...[
                          const SizedBox(height: 20),
                          _buildDetailSection(
                            _getTranslation('payment_proof'),
                            Icons.receipt,
                            [
                              _buildPaymentProofRow(reservation['preuve_paiement']),
                            ],
                          ),
                        ],
                        
                        if (reservation['raison_refus']?.isNotEmpty == true) ...[
                          const SizedBox(height: 20),
                          _buildDetailSection(
                            _getTranslation('rejection_reason'),
                            Icons.cancel,
                            [
                              _buildDetailRow('', reservation['raison_refus']),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                
                // Footer
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            _getTranslation('close'),
                            style: const TextStyle(
                              color: Color(0xFF7F8C8D),
                              fontSize: 16,
                            ),
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
      },
    );
  }

  Widget _buildDetailSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color.fromRGBO(255, 192, 203, 1), size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) ...[
            SizedBox(
              width: 100,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF7F8C8D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentProofRow(String? proofUrl) {
    if (proofUrl == null || proofUrl.isEmpty) {
      return Text(
        _getTranslation('no_payment_proof'),
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF7F8C8D),
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getTranslation('payment_proof_document'),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _openPaymentProof(proofUrl),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 192, 203, 1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color.fromRGBO(255, 192, 203, 1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.receipt,
                  color: Color.fromRGBO(255, 192, 203, 1),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getTranslation('view_payment_proof'),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color.fromRGBO(255, 192, 203, 1),
                    ),
                  ),
                ),
                const Icon(
                  Icons.open_in_new,
                  color: Color.fromRGBO(255, 192, 203, 1),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _openPaymentProof(String proofUrl) async {
    try {
      // Check if the URL is valid
      final Uri uri = Uri.parse(proofUrl);
      
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color.fromRGBO(255, 192, 203, 1),
            ),
          );
        },
      );

      // Try to launch the URL
      final bool canLaunch = await canLaunchUrl(uri);
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      if (canLaunch) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        // If can't launch, show the document in a custom viewer
        _showPaymentProofDialog(proofUrl);
      }
    } catch (e) {
      // Close loading dialog if it's still open
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      // Show error and fallback to custom viewer
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_getTranslation('error')}: $e'),
          backgroundColor: Colors.red,
        ),
      );
      
      _showPaymentProofDialog(proofUrl);
    }
  }

  void _showPaymentProofDialog(String proofUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 400,
              maxHeight: 600,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color.fromRGBO(255, 192, 203, 1),
                        const Color.fromRGBO(255, 182, 193, 1),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.receipt,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getTranslation('payment_proof'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getFileTypeFromUrl(proofUrl),
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
                ),
                
                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // File preview or info
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                _getFileIcon(proofUrl),
                                size: 48,
                                color: const Color.fromRGBO(255, 192, 203, 1),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _getFileNameFromUrl(proofUrl),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2C3E50),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                proofUrl,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF7F8C8D),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  try {
                                    final Uri uri = Uri.parse(proofUrl);
                                    await launchUrl(
                                      uri,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${_getTranslation('error')}: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.open_in_new),
                                label: Text(_getTranslation('view_payment_proof')),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromRGBO(255, 192, 203, 1),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  try {
                                    final Uri uri = Uri.parse(proofUrl);
                                    await launchUrl(
                                      uri,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${_getTranslation('error')}: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.download),
                                label: const Text('Download'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF27AE60),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Footer
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            _getTranslation('close'),
                            style: const TextStyle(
                              color: Color(0xFF7F8C8D),
                              fontSize: 16,
                            ),
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
      },
    );
  }

  String _getFileTypeFromUrl(String url) {
    final extension = url.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return 'PDF Document';
      case 'jpg':
      case 'jpeg':
        return 'JPEG Image';
      case 'png':
        return 'PNG Image';
      case 'gif':
        return 'GIF Image';
      case 'webp':
        return 'WebP Image';
      case 'doc':
        return 'Word Document';
      case 'docx':
        return 'Word Document';
      case 'txt':
        return 'Text File';
      default:
        return 'Document';
    }
  }

  IconData _getFileIcon(String url) {
    final extension = url.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return Icons.image;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _getFileNameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        return pathSegments.last;
      }
      return 'Payment Proof';
    } catch (e) {
      return 'Payment Proof';
    }
  }
}
