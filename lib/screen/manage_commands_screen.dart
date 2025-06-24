import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class ManageCommandsScreen extends StatefulWidget {
  const ManageCommandsScreen({super.key});

  @override
  State<ManageCommandsScreen> createState() => _ManageCommandsScreenState();
}

class _ManageCommandsScreenState extends State<ManageCommandsScreen> with TickerProviderStateMixin {
  List<Map<String, dynamic>> _commands = [];
  bool _isLoading = true;
  String? _error;
  String _selectedFilter = 'all';
  String _selectedLanguage = 'en';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Local translations
  final Map<String, Map<String, String>> _translations = {
    'en': {
      'manage_orders': 'Manage Orders',
      'filter_orders': 'Filter Orders',
      'all': 'All',
      'pending': 'Pending',
      'confirmed': 'Confirmed',
      'shipped': 'Shipped',
      'completed': 'Completed',
      'cancelled': 'Cancelled',
      'no_orders': 'No orders found',
      'loading_orders': 'Loading orders...',
      'retry': 'Retry',
      'error': 'Error',
      'order': 'Order',
      'customer': 'Customer',
      'total': 'Total',
      'quantity': 'Quantity',
      'date': 'Date',
      'comment': 'Comment',
      'confirm': 'Confirm',
      'ship': 'Ship',
      'complete': 'Complete',
      'cancel': 'Cancel',
      'view_details': 'View Details',
      'close': 'Close',
      'customer_information': 'Customer Information',
      'order_details': 'Order Details',
      'product_information': 'Product Information',
      'provider_information': 'Provider Information',
      'payment_confirmation': 'Payment & Confirmation',
      'comments': 'Comments',
      'payment_proof': 'Payment Proof',
      'rejection_reason': 'Rejection Reason',
      'name': 'Name',
      'phone': 'Phone',
      'email': 'Email',
      'start_date': 'Start Date',
      'end_date': 'End Date',
      'created': 'Created',
      'modified': 'Modified',
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
      'view_payment_proof': 'View Payment Proof',
      'opening_payment_proof': 'Opening payment proof',
      'command_status_updated': 'Command status updated to',
      'failed_to_update': 'Failed to update command',
      'failed_to_load': 'Failed to load commands',
      'no_auth_token': 'No authentication token found',
      'unknown_product': 'Unknown Product',
      'unknown_customer': 'Unknown Customer',
      'no_phone': 'No phone',
      'no_email': 'No email',
      'unknown': 'Unknown',
    },
    'fr': {
      'manage_orders': 'Gérer les Commandes',
      'filter_orders': 'Filtrer les Commandes',
      'all': 'Tout',
      'pending': 'En Attente',
      'confirmed': 'Confirmé',
      'shipped': 'Expédié',
      'completed': 'Terminé',
      'cancelled': 'Annulé',
      'no_orders': 'Aucune commande trouvée',
      'loading_orders': 'Chargement des commandes...',
      'retry': 'Réessayer',
      'error': 'Erreur',
      'order': 'Commande',
      'customer': 'Client',
      'total': 'Total',
      'quantity': 'Quantité',
      'date': 'Date',
      'comment': 'Commentaire',
      'confirm': 'Confirmer',
      'ship': 'Expédier',
      'complete': 'Terminer',
      'cancel': 'Annuler',
      'view_details': 'Voir les Détails',
      'close': 'Fermer',
      'customer_information': 'Informations Client',
      'order_details': 'Détails de la Commande',
      'product_information': 'Informations Produit',
      'provider_information': 'Informations Fournisseur',
      'payment_confirmation': 'Paiement et Confirmation',
      'comments': 'Commentaires',
      'payment_proof': 'Preuve de Paiement',
      'rejection_reason': 'Raison du Refus',
      'name': 'Nom',
      'phone': 'Téléphone',
      'email': 'Email',
      'start_date': 'Date de Début',
      'end_date': 'Date de Fin',
      'created': 'Créé',
      'modified': 'Modifié',
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
      'view_payment_proof': 'Voir la Preuve de Paiement',
      'opening_payment_proof': 'Ouverture de la preuve de paiement',
      'command_status_updated': 'Statut de la commande mis à jour vers',
      'failed_to_update': 'Échec de la mise à jour de la commande',
      'failed_to_load': 'Échec du chargement des commandes',
      'no_auth_token': 'Aucun token d\'authentification trouvé',
      'unknown_product': 'Produit Inconnu',
      'unknown_customer': 'Client Inconnu',
      'no_phone': 'Pas de téléphone',
      'no_email': 'Pas d\'email',
      'unknown': 'Inconnu',
    },
    'ar': {
      'manage_orders': 'إدارة الطلبات',
      'filter_orders': 'تصفية الطلبات',
      'all': 'الكل',
      'pending': 'في الانتظار',
      'confirmed': 'مؤكد',
      'shipped': 'تم الشحن',
      'completed': 'مكتمل',
      'cancelled': 'ملغي',
      'no_orders': 'لا توجد طلبات',
      'loading_orders': 'جاري تحميل الطلبات...',
      'retry': 'إعادة المحاولة',
      'error': 'خطأ',
      'order': 'طلب',
      'customer': 'العميل',
      'total': 'المجموع',
      'quantity': 'الكمية',
      'date': 'التاريخ',
      'comment': 'تعليق',
      'confirm': 'تأكيد',
      'ship': 'شحن',
      'complete': 'إكمال',
      'cancel': 'إلغاء',
      'view_details': 'عرض التفاصيل',
      'close': 'إغلاق',
      'customer_information': 'معلومات العميل',
      'order_details': 'تفاصيل الطلب',
      'product_information': 'معلومات المنتج',
      'provider_information': 'معلومات المزود',
      'payment_confirmation': 'الدفع والتأكيد',
      'comments': 'التعليقات',
      'payment_proof': 'إثبات الدفع',
      'rejection_reason': 'سبب الرفض',
      'name': 'الاسم',
      'phone': 'الهاتف',
      'email': 'البريد الإلكتروني',
      'start_date': 'تاريخ البداية',
      'end_date': 'تاريخ الانتهاء',
      'created': 'تم الإنشاء',
      'modified': 'تم التعديل',
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
      'view_payment_proof': 'عرض إثبات الدفع',
      'opening_payment_proof': 'فتح إثبات الدفع',
      'command_status_updated': 'تم تحديث حالة الطلب إلى',
      'failed_to_update': 'فشل في تحديث الطلب',
      'failed_to_load': 'فشل في تحميل الطلبات',
      'no_auth_token': 'لم يتم العثور على رمز المصادقة',
      'unknown_product': 'منتج غير معروف',
      'unknown_customer': 'عميل غير معروف',
      'no_phone': 'لا يوجد هاتف',
      'no_email': 'لا يوجد بريد إلكتروني',
      'unknown': 'غير معروف',
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
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadCommands();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadCommands() async {
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
        Uri.parse('${Config.apiUrl}/api/commands/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<Map<String, dynamic>> commands = [];
        
        if (data is Map<String, dynamic>) {
          if (data.containsKey('results') && data['results'] is List) {
            commands = List<Map<String, dynamic>>.from(data['results']);
          } else if (data.containsKey('data') && data['data'] is List) {
            commands = List<Map<String, dynamic>>.from(data['data']);
          } else {
            commands = [];
          }
        } else if (data is List) {
          commands = List<Map<String, dynamic>>.from(data);
        }
        
        for (var command in commands) {
          if (command['id'] is String) {
            command['id'] = int.tryParse(command['id']) ?? 0;
          }
          
          command['product_name'] = command['service_name'] ?? 'Unknown Service';
          command['customer_name'] = command['client_name'] ?? 'Unknown Customer';
          command['customer_phone'] = command['client_phone'] ?? '';
          // command['customer_email'] = command['client_email'] ?? '';
          command['date_debut'] = command['date_commande'] ?? command['date_creation'];
          // command['date_fin'] = command['date_fin'] ?? command['date_creation'];
          // command['date_creation'] = command['date_creation'] ?? '';
          // command['date_modification'] = command['date_modification'] ?? '';
          command['product_description'] = command['commentaire'] ?? '';
          
          if (command['service_type'] == 'makeup' && command['makeup_service'] != null) {
            if (command['makeup_service'] is Map<String, dynamic>) {
              command['product_name'] = command['makeup_service']['name'] ?? 'Makeup Service';
            } else {
              command['product_name'] = 'Makeup Service';
            }
          } else if (command['service_type'] == 'accessory' && command['accessory_service'] != null) {
            if (command['accessory_service'] is Map<String, dynamic>) {
              command['product_name'] = command['accessory_service']['name'] ?? 'Accessory Service';
            } else {
              command['product_name'] = 'Accessory Service';
            }
          } else if (command['service_type'] == 'melhfa' && command['melhfa_service'] != null) {
            if (command['melhfa_service'] is Map<String, dynamic>) {
              command['product_name'] = command['melhfa_service']['name'] ?? 'Melhfa Service';
            } else {
              command['product_name'] = 'Melhfa Service';
            }
          }
        }
        
        setState(() {
          _commands = commands;
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

  Future<void> _updateCommandStatus(dynamic commandId, String status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception(_getTranslation('no_auth_token'));
      }

      int id;
      if (commandId is String) {
        id = int.tryParse(commandId) ?? 0;
      } else if (commandId is int) {
        id = commandId;
      } else {
        throw Exception('Invalid command ID');
      }

      final response = await http.patch(
        Uri.parse('${Config.apiUrl}/api/commands/$id/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'statut': status}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_getTranslation('command_status_updated')} $status'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        _loadCommands();
      } else {
        throw Exception('${_getTranslation('failed_to_update')}: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_getTranslation('error')}: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  List<Map<String, dynamic>> get _filteredCommands {
    if (_selectedFilter == 'all') {
      return _commands;
    }
    return _commands.where((command) {
      return command['statut']?.toLowerCase() == _selectedFilter.toLowerCase();
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return const Color(0xFF10B981);
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'cancelled':
        return const Color(0xFFEF4444);
      case 'completed':
        return const Color(0xFF3B82F6);
      case 'shipped':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          _getTranslation('manage_orders'),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFEC4899),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
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
              dropdownColor: const Color(0xFFEC4899),
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
            onPressed: _loadCommands,
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
        children: [
            // Filter Section
          Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getTranslation('filter_orders'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                        _buildModernFilterChip('all', _getTranslation('all')),
                        const SizedBox(width: 12),
                        _buildModernFilterChip('pending', _getTranslation('pending')),
                        const SizedBox(width: 12),
                        _buildModernFilterChip('confirmed', _getTranslation('confirmed')),
                        const SizedBox(width: 12),
                        _buildModernFilterChip('shipped', _getTranslation('shipped')),
                        const SizedBox(width: 12),
                        _buildModernFilterChip('completed', _getTranslation('completed')),
                        const SizedBox(width: 12),
                        _buildModernFilterChip('cancelled', _getTranslation('cancelled')),
                ],
              ),
            ),
                ],
          ),
            ),
            
            // Orders List
          Expanded(
            child: _isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEC4899)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _getTranslation('loading_orders'),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : _error != null
                      ? Center(
                          child: Container(
                            margin: const EdgeInsets.all(16),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: Colors.red[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '${_getTranslation('error')}: $_error',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton.icon(
                              onPressed: _loadCommands,
                                  icon: const Icon(Icons.refresh),
                                  label: Text(_getTranslation('retry')),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFEC4899),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                            ),
                          ],
                            ),
                        ),
                      )
                    : _filteredCommands.isEmpty
                          ? Center(
                              child: Container(
                                margin: const EdgeInsets.all(16),
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.inbox_outlined,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      _getTranslation('no_orders'),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredCommands.length,
                            itemBuilder: (context, index) {
                              final command = _filteredCommands[index];
                                return _buildModernOrderCard(command, index);
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEC4899) : Colors.grey[100],
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? const Color(0xFFEC4899) : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildModernOrderCard(Map<String, dynamic> command, int index) {
    final status = command['statut'] ?? 'pending';
    final statusColor = _getStatusColor(status);
    
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 100)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              // Compact Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      statusColor.withOpacity(0.1),
                      statusColor.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    // Compact Icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.shopping_bag_rounded,
                        color: statusColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Compact Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            command['product_name'] ?? _getTranslation('unknown_product'),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          // Text(
                          //   '${_getTranslation('order')} #${command['id']}',
                          //   style: TextStyle(
                          //     fontSize: 12,
                          //     color: Colors.grey[600],
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                    
                    // Compact Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor, width: 1),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Compact Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Compact Details Grid
                    Row(
                      children: [
                        Expanded(
                          child: _buildCompactDetailItem(
                            Icons.person_outline,
                            _getTranslation('customer'),
                            command['customer_name'] ?? _getTranslation('unknown_customer'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildCompactDetailItem(
                            Icons.attach_money_rounded,
                            _getTranslation('total'),
                            '\$${command['montant_total']?.toString() ?? '0'}',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildCompactDetailItem(
                            Icons.calendar_today_rounded,
                            _getTranslation('date'),
                            _formatDate(command['date_debut']),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildCompactDetailItem(
                            Icons.inventory_2_outlined,
                            _getTranslation('quantity'),
                            command['quantity']?.toString() ?? '1',
                          ),
                        ),
                      ],
                    ),
                    
                    // Compact Comment (if exists)
                    if (command['commentaire']?.isNotEmpty == true) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.comment_outlined,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                command['commentaire'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 16),
                    
                    // Compact Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () => _showCommandDetails(command),
                            icon: const Icon(Icons.visibility_outlined, size: 16),
                            label: Text(
                              _getTranslation('view_details'),
                              style: const TextStyle(fontSize: 12),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFFEC4899),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(color: Color(0xFFEC4899)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (command['statut'] == 'pending')
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _updateCommandStatus(command['id'], 'confirmed'),
                              icon: const Icon(Icons.check_rounded, size: 16),
                              label: Text(
                                _getTranslation('confirm'),
                                style: const TextStyle(fontSize: 12),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        if (command['statut'] == 'confirmed')
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _updateCommandStatus(command['id'], 'shipped'),
                              icon: const Icon(Icons.local_shipping_rounded, size: 16),
                              label: Text(
                                _getTranslation('ship'),
                                style: const TextStyle(fontSize: 12),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8B5CF6),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        if (command['statut'] == 'shipped')
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _updateCommandStatus(command['id'], 'completed'),
                              icon: const Icon(Icons.done_all_rounded, size: 16),
                              label: Text(
                                _getTranslation('complete'),
                                style: const TextStyle(fontSize: 12),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3B82F6),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        if (['pending', 'confirmed'].contains(command['statut'])) ...[
                          if (command['statut'] == 'pending' || command['statut'] == 'confirmed')
                            const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _updateCommandStatus(command['id'], 'cancelled'),
                              icon: const Icon(Icons.cancel_rounded, size: 16),
                              label: Text(
                                _getTranslation('cancel'),
                                style: const TextStyle(fontSize: 12),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEF4444),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
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

  Widget _buildCompactDetailItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatDate(String? date) {
    if (date == null) return _getTranslation('unknown');
    try {
    final DateTime parsedDate = DateTime.parse(date);
    return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
    } catch (e) {
      return _getTranslation('unknown');
    }
  }

  void _showCommandDetails(Map<String, dynamic> command) {
    final status = command['statut'] ?? 'pending';
    final serviceType = command['service_type'] ?? 'unknown';
    final isPaid = status == 'paid' || command['est_paye'] == true;
    final isConfirmed = command['est_confirme_proprietaire'] == true;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFEC4899),
                        const Color(0xFFF472B6),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
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
                          Icons.shopping_bag_rounded,
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
                              command['product_name'] ?? _getTranslation('unknown_product'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${_getTranslation('order')} #${command['id']}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
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
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailSection(
                          _getTranslation('customer_information'),
                          Icons.person_outline,
                          [
                            _buildDetailRow(_getTranslation('name'), command['customer_name'] ?? _getTranslation('unknown_customer')),
                            _buildDetailRow(_getTranslation('phone'), command['customer_phone'] ?? _getTranslation('no_phone')),
                            _buildDetailRow(_getTranslation('email'), command['customer_email'] ?? _getTranslation('no_email')),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        _buildDetailSection(
                          _getTranslation('order_details'),
                          Icons.shopping_cart_outlined,
                          [
                            _buildDetailRow(_getTranslation('start_date'), _formatDate(command['date_debut'])),
                            _buildDetailRow(_getTranslation('end_date'), _formatDate(command['date_fin'])),
                            _buildDetailRow(_getTranslation('created'), _formatDate(command['date_creation'])),
                            _buildDetailRow(_getTranslation('modified'), _formatDate(command['date_modification'])),
                            _buildDetailRow(_getTranslation('total_amount'), '\$${command['montant_total']?.toString() ?? '0'}'),
                            _buildDetailRow(_getTranslation('quantity'), command['quantity']?.toString() ?? '1'),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        _buildDetailSection(
                          _getTranslation('product_information'),
                          Icons.inventory_2_outlined,
                          [
                            _buildDetailRow(_getTranslation('service_type'), serviceType.toUpperCase()),
                            _buildDetailRow(_getTranslation('product_name'), command['product_name'] ?? _getTranslation('unknown_product')),
                            if (command['product_description'] != null)
                              _buildDetailRow(_getTranslation('description'), command['product_description']),
                          ],
                        ),
                        
                        // Provider Information
                        if (command['fournisseur_name'] != null) ...[
                          const SizedBox(height: 24),
                          _buildDetailSection(
                            _getTranslation('provider_information'),
                            Icons.business_outlined,
                            [
                              _buildDetailRow(_getTranslation('provider_name'), command['fournisseur_name']),
                              if (command['fournisseur_phone'] != null)
                                _buildDetailRow(_getTranslation('provider_phone'), command['fournisseur_phone']),
                            ],
                          ),
                        ],
                        
                        // Payment Status
                        const SizedBox(height: 24),
                        _buildDetailSection(
                          _getTranslation('payment_confirmation'),
                          Icons.payment_outlined,
                          [
                            _buildDetailRow(_getTranslation('payment_status'), isPaid ? _getTranslation('paid') : _getTranslation('not_paid')),
                            _buildDetailRow(_getTranslation('owner_confirmed'), isConfirmed ? _getTranslation('yes') : _getTranslation('no')),
                            if (command['est_paye'] != null)
                              _buildDetailRow(_getTranslation('payment_verified'), command['est_paye'] ? _getTranslation('yes') : _getTranslation('no')),
                          ],
                        ),
                        
                        if (command['commentaire']?.isNotEmpty == true) ...[
                          const SizedBox(height: 24),
                          _buildDetailSection(
                            _getTranslation('comments'),
                            Icons.comment_outlined,
                            [
                              _buildDetailRow('', command['commentaire']),
                            ],
                          ),
                        ],
                        
                        if (isPaid && command['preuve_paiement'] != null) ...[
                          const SizedBox(height: 24),
                          _buildDetailSection(
                            _getTranslation('payment_proof'),
                            Icons.receipt_outlined,
                            [
                              _buildPaymentProofRow(command['preuve_paiement']),
                            ],
                          ),
                        ],
                        
                        if (command['raison_refus']?.isNotEmpty == true) ...[
                          const SizedBox(height: 24),
                          _buildDetailSection(
                            _getTranslation('rejection_reason'),
                            Icons.cancel_outlined,
                            [
                              _buildDetailRow('', command['raison_refus']),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                
                // Footer
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEC4899),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            _getTranslation('close'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
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
            Icon(icon, color: const Color(0xFFEC4899), size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
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
      padding: const EdgeInsets.only(bottom: 12),
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
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
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
          color: Color(0xFF6B7280),
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
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _openPaymentProof(proofUrl),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEC4899).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFEC4899),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.receipt_outlined,
                  color: Color(0xFFEC4899),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getTranslation('view_payment_proof'),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFEC4899),
                    ),
                  ),
                ),
                const Icon(
                  Icons.open_in_new,
                  color: Color(0xFFEC4899),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _openPaymentProof(String proofUrl) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_getTranslation('opening_payment_proof')}: $proofUrl'),
        backgroundColor: const Color(0xFFEC4899),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
} 