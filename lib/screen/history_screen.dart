import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/reservation.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/widgets.dart' as pw;
import '../services/tflite_service.dart';
import 'dart:io';

class HistoryScreen extends StatefulWidget {
  final String selectedLanguage;
  final Map<String, Map<String, String>> translations;
  
  const HistoryScreen({
    super.key,
    required this.selectedLanguage,
    required this.translations,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final TFLiteService _tfliteService = TFLiteService();
  late TabController _tabController;
  List<dynamic> _reservations = [];
  List<dynamic> _commands = [];
  bool _isLoadingReservations = true;
  bool _isLoadingCommands = true;
  String? _reservationsError;
  String? _commandsError;
  
  // Cache for service details
  Map<int, Map<String, dynamic>> _serviceDetailsCache = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _translate(String key) {
    return widget.translations[widget.selectedLanguage]?[key] ?? 
           widget.translations['English']?[key] ?? key;
  }

  Future<void> _fetchData() async {
    _fetchReservations();
    _fetchCommands();
  }

  Future<void> _fetchReservations() async {
    try {
      setState(() {
        _isLoadingReservations = true;
        _reservationsError = null;
      });

      final reservations = await _apiService.getUserReservations();
      if (reservations == null) {
        throw Exception('Failed to load reservations');
      }

      setState(() {
        _reservations = reservations;
        _isLoadingReservations = false;
      });
    } catch (e) {
      setState(() {
        _reservationsError = e.toString();
        _isLoadingReservations = false;
      });
    }
  }

  Future<void> _fetchCommands() async {
    try {
      setState(() {
        _isLoadingCommands = true;
        _commandsError = null;
      });

      final commands = await _apiService.getUserCommands();
      if (commands == null) {
        throw Exception('Failed to load commands');
      }

      setState(() {
        _commands = commands;
        _isLoadingCommands = false;
      });
    } catch (e) {
      setState(() {
        _commandsError = e.toString();
        _isLoadingCommands = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F5),
      appBar: AppBar(
        title: Text(
          widget.selectedLanguage == 'Arabic' ? 'سجل النشاط' : 'History',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: const Color(0xFFF8BBD0),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchData,
            tooltip: widget.selectedLanguage == 'Arabic' ? 'تحديث' : 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: widget.selectedLanguage == 'Arabic' ? 'الحجوزات' : 'Reservations'),
            Tab(text: widget.selectedLanguage == 'Arabic' ? 'الطلبات' : 'Orders'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReservationsTab(),
          _buildCommandsTab(),
        ],
      ),
    );
  }

  Widget _buildReservationsTab() {
    if (_isLoadingReservations) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFF06292)));
    }

    if (_reservationsError != null) {
      return _buildErrorView(_reservationsError!, _fetchReservations);
    }

    if (_reservations.isEmpty) {
      return _buildEmptyView(
        widget.selectedLanguage == 'Arabic' ? 'لا توجد حجوزات' : 'No reservations',
        Icons.event_busy
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchReservations,
      color: const Color(0xFFF06292),
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _reservations.length,
        itemBuilder: (context, index) {
          final reservation = _reservations[index];
          
          // Parse date - handle both Map and Reservation object cases
          DateTime date;
          String status;
          
          if (reservation is Map) {
            // Parse date from Map
            date = DateTime.tryParse(reservation['date'] ?? '') ?? DateTime.now();
            status = reservation['status'] ?? reservation['statut'] ?? 'pending';
          } else if (reservation is Reservation) {
            // Get date directly from Reservation object
            date = reservation.date;
            status = reservation.status;
          } else {
            // Fallback for unexpected types
            print('Warning: Unexpected reservation type: ${reservation.runtimeType}');
            date = DateTime.now();
            status = 'pending';
          }
          
          String formattedDate = DateFormat('MMM d, yyyy – h:mm a').format(date);
          
          // Determine status color
          Color statusColor = _getStatusColor(status);
          
          return _buildReservationCard(reservation, formattedDate, statusColor);
        },
      ),
    );
  }

  Widget _buildCommandsTab() {
    if (_isLoadingCommands) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFF06292)));
    }

    if (_commandsError != null) {
      return _buildErrorView(_commandsError!, _fetchCommands);
    }

    if (_commands.isEmpty) {
      return _buildEmptyView(
        widget.selectedLanguage == 'Arabic' ? 'لا توجد طلبات' : 'No orders',
        Icons.shopping_bag
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchCommands,
      color: const Color(0xFFF06292),
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _commands.length,
        itemBuilder: (context, index) {
          final command = _commands[index];
          
          // Parse date
          DateTime date = DateTime.tryParse(command['created_at'] ?? '') ?? DateTime.now();
          String formattedDate = DateFormat('MMM d, yyyy – h:mm a').format(date);
          
          // Determine status color
          Color statusColor = _getStatusColor(command['status'] ?? 'pending');
          
          return _buildCommandCard(command, formattedDate, statusColor);
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'delivered':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'confirmed':
      case 'processing':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    if (widget.selectedLanguage == 'Arabic') {
      switch (status.toLowerCase()) {
        case 'completed':
          return 'مكتمل';
        case 'pending':
          return 'قيد الانتظار';
        case 'confirmed':
          return 'مؤكد';
        case 'cancelled':
          return 'ملغي';
        case 'delivered':
          return 'تم التوصيل';
        case 'processing':
          return 'قيد المعالجة';
        default:
          return status;
      }
    } else {
      return status.substring(0, 1).toUpperCase() + status.substring(1).toLowerCase();
    }
  }

  Widget _buildReservationCard(dynamic reservation, String formattedDate, Color statusColor) {
    // Extract service ID and details
    int serviceId = -1;
    Map<String, dynamic>? serviceDetails;
    
    if (reservation is Map) {
      if (reservation['service'] is Map) {
        serviceDetails = reservation['service'];
        serviceId = serviceDetails?['id'] ?? -1;
      } else if (reservation['service'] != null) {
        serviceId = int.tryParse(reservation['service'].toString()) ?? -1;
      }
    } else if (reservation is Reservation) {
      serviceId = reservation.serviceId;
    }

    // Get status icon
    IconData statusIcon = _getStatusIcon(reservation is Map ? 
        (reservation['status'] ?? reservation['statut'] ?? 'pending') : 
        (reservation is Reservation ? reservation.status : 'pending'));

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Status Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 24),
                ),
                const SizedBox(width: 16),
                
                // Service name and category
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        serviceDetails?['nom'] ?? 
                        serviceDetails?['name'] ?? 
                        reservation['service_name'] ?? 
                        'Service $serviceId',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF880E4F),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getCategoryFromReservation(reservation),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(reservation is Map ? 
                        (reservation['status'] ?? reservation['statut'] ?? 'pending') : 
                        (reservation is Reservation ? reservation.status : 'pending')),
                    style: TextStyle(
                      fontSize: 12,
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            
            // Date
            _buildInfoRow(
              Icons.calendar_today,
              formattedDate,
            ),
            
            // Price
            if (reservation['montant_total'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: _buildInfoRow(
                  Icons.payments,
                  '${reservation['montant_total']} MRU',
                ),
              ),

            // Provider information
            if (reservation['fournisseur_name'] != null || reservation['fournisseur_phone'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Provider Details',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF880E4F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (reservation['fournisseur_name'] != null)
                      _buildInfoRow(
                        Icons.person,
                        reservation['fournisseur_name'],
                      ),
                    if (reservation['fournisseur_phone'] != null)
                      _buildInfoRow(
                        Icons.phone,
                        reservation['fournisseur_phone'],
                      ),
                  ],
                ),
              ),

            // Action buttons
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Print button
                  SizedBox(
                    width: 90,
                    child: ElevatedButton.icon(
                  onPressed: () => _printReservation(reservation),
                      icon: const Icon(Icons.print, size: 14),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        textStyle: const TextStyle(fontSize: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  label: Text(_translate('print')),
                ),
                  ),
                  const SizedBox(width: 8),

                // Cancel button (only show if not cancelled or completed)
                if (reservation['statut'] != 'cancelled' && 
                    reservation['statut'] != 'completed')
                    SizedBox(
                      width: 90,
                      child: ElevatedButton.icon(
                    onPressed: () => _cancelReservation(reservation['id']),
                        icon: const Icon(Icons.cancel, size: 14),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          textStyle: const TextStyle(fontSize: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    label: Text(_translate('cancel')),
                      ),
                  ),

                // Payment button (only show if accepted and not paid)
                if (reservation['statut'] == 'accepted' && 
                      (reservation['est_paye'] == false))
                    SizedBox(
                      width: 90,
                      child: ElevatedButton.icon(
                    onPressed: () => _showPaymentDialog(reservation),
                        icon: const Icon(Icons.payment, size: 14),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          textStyle: const TextStyle(fontSize: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    label: Text(_translate('pay')),
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

  Widget _buildCommandCard(dynamic command, String formattedDate, Color statusColor) {
    // Extract service details
    String serviceName = '';
    String serviceType = '';
    
    // Get service type and name from command data
    if (command is Map) {
      // First try to get service type from the command
      serviceType = command['service_type'] ?? '';
      
      // Then try to get service name based on service type
      if (command['henna_service'] != null) {
        serviceName = command['henna_service'] is Map ? 
          (command['henna_service']['name'] ?? 'Henna Service') : 
          'Henna Service';
        serviceType = 'henna';
      } else if (command['melhfa_service'] != null) {
        serviceName = command['melhfa_service'] is Map ? 
          (command['melhfa_service']['type'] ?? 'Melhfa Service') : 
          'Melhfa Service';
        serviceType = 'melhfa';
      } else if (command['accessory_service'] != null) {
        serviceName = command['accessory_service'] is Map ? 
          (command['accessory_service']['name'] ?? 'Accessory Service') : 
          'Accessory Service';
        serviceType = 'accessory';
      } else if (command['hammam_service'] != null) {
        serviceName = command['hammam_service'] is Map ? 
          (command['hammam_service']['name'] ?? 'Hammam Service') : 
          'Hammam Service';
        serviceType = 'hammam';
      } else if (command['gym_service'] != null) {
        serviceName = command['gym_service'] is Map ? 
          (command['gym_service']['name'] ?? 'Gym Service') : 
          'Gym Service';
        serviceType = 'gym';
      } else if (command['service'] is Map) {
        serviceName = command['service']['name'] ?? 
                     command['service']['nom'] ?? 
                     command['service']['type'] ?? 
                     'Service';
        serviceType = command['service']['type'] ?? serviceType;
      }
    }

    // Get status with automatic updates
    String status = command['status'] ?? command['statut'] ?? 'pending';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Service Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.pink[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getServiceIcon(serviceType),
                    color: Colors.pink[300],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Service name and type
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        serviceName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF880E4F),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getServiceTypeText(serviceType),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(status),
                    style: TextStyle(
                      fontSize: 12,
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            
            // Date
            _buildInfoRow(
              Icons.calendar_today,
              formattedDate,
            ),
            
            // Price if available
            if (command['montant_total'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: _buildInfoRow(
                  Icons.payments,
                  '${command['montant_total']} MRU',
                ),
              ),

            // Provider information
            if (command['fournisseur_name'] != null || command['fournisseur_phone'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Provider Details',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF880E4F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (command['fournisseur_name'] != null)
                      _buildInfoRow(
                        Icons.person,
                        command['fournisseur_name'],
                      ),
                    if (command['fournisseur_phone'] != null)
                      _buildInfoRow(
                        Icons.phone,
                        command['fournisseur_phone'],
                      ),
                  ],
                ),
              ),

            // Action buttons
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Print button
                  SizedBox(
                    width: 90,
                    child: ElevatedButton.icon(
                  onPressed: () => _printCommand(command),
                      icon: const Icon(Icons.print, size: 14),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        textStyle: const TextStyle(fontSize: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  label: Text(_translate('print')),
                ),
                  ),
                  const SizedBox(width: 8),

                // Cancel button (only show if not cancelled or completed)
                if (status != 'cancelled' && status != 'completed')
                    SizedBox(
                      width: 90,
                      child: ElevatedButton.icon(
                    onPressed: () => _cancelCommand(command['id']),
                        icon: const Icon(Icons.cancel, size: 14),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          textStyle: const TextStyle(fontSize: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    label: Text(_translate('cancel')),
                      ),
                  ),

                // Payment button (only show if accepted and not paid)
                if (status == 'accepted' && 
                    command['est_paye'] != true)
                    SizedBox(
                      width: 90,
                      child: ElevatedButton.icon(
                    onPressed: () => _showPaymentDialog(command),
                        icon: const Icon(Icons.payment, size: 14),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          textStyle: const TextStyle(fontSize: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    label: Text(_translate('pay')),
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

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'delivered':
        return Icons.check_circle;
      case 'pending':
        return Icons.hourglass_empty;
      case 'confirmed':
        return Icons.verified;
      case 'processing':
        return Icons.sync;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  String _getServiceTypeText(String serviceType) {
    if (widget.selectedLanguage == 'Arabic') {
      switch (serviceType.toLowerCase()) {
        case 'henna':
          return 'حناء';
        case 'melhfa':
          return 'ملحفة';
        case 'accessory':
          return 'إكسسوارات';
        default:
          return 'طلب';
      }
    } else {
      switch (serviceType.toLowerCase()) {
        case 'henna':
          return 'Henna';
        case 'melhfa':
          return 'Melhfa';
        case 'accessory':
          return 'Accessory';
        default:
          return 'Order';
      }
    }
  }

  IconData _getServiceIcon(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'henna':
        return Icons.brush;
      case 'melhfa':
        return Icons.checkroom;
      case 'accessory':
        return Icons.shopping_bag;
      case 'gym':
        return Icons.fitness_center;
      case 'hammam':
        return Icons.spa;
      default:
        return Icons.shopping_cart;
    }
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView(String errorMessage, VoidCallback retryFunction) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            errorMessage,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: retryFunction,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF06292),
            ),
            child: Text(
              widget.selectedLanguage == 'Arabic' ? 'إعادة المحاولة' : 'Try Again',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryFromReservation(dynamic reservation) {
    if (reservation is Map) {
    final service = reservation['service'] ?? {};
    final categoryId = service['category'] ?? '';
    return _getCategoryName(categoryId);
    } else if (reservation is Reservation) {
      // For Reservation objects, we need to determine the category differently
      // We might need to fetch service details to get the category
      // For now, return a default
      return _getCategoryName('');
    }
    
    return _getCategoryName('');
  }

  String _getCategoryName(String categoryId) {
    switch (categoryId) {
      case 'hammam':
        return widget.selectedLanguage == 'Arabic' ? 'حمام' : 'Hammam';
      case 'melhfa':
        return widget.selectedLanguage == 'Arabic' ? 'ملحفة' : 'Melhfa';
      case 'henna':
        return widget.selectedLanguage == 'Arabic' ? 'حناء' : 'Henna';
      case 'accessories':
        return widget.selectedLanguage == 'Arabic' ? 'إكسسوارات' : 'Accessories';
      case 'makeup':
        return widget.selectedLanguage == 'Arabic' ? 'مكياج' : 'Makeup';
      case 'gym':
        return widget.selectedLanguage == 'Arabic' ? 'صالة رياضية' : 'Gym';
      default:
        return categoryId;
    }
  }

  // Fetch service details and cache them
  Future<Map<String, dynamic>?> _getServiceDetails(int serviceId) async {
    // Check if we already have this service in the cache
    if (_serviceDetailsCache.containsKey(serviceId)) {
      return _serviceDetailsCache[serviceId];
    }
    
    // Otherwise fetch and cache the details
    try {
      // Try to get service details from the reservation/order data first
      if (_reservations.isNotEmpty) {
        for (var reservation in _reservations) {
          if (reservation is Map && 
              reservation['service'] is Map && 
              reservation['service']['id'] == serviceId) {
            final details = reservation['service'];
            _serviceDetailsCache[serviceId] = details;
            return details;
          }
        }
      }
      
      // If not found in reservations, try API based on service type
      String? serviceType;
      if (_reservations.isNotEmpty) {
        for (var reservation in _reservations) {
          if (reservation is Map && 
              reservation['service'] is Map && 
              reservation['service']['id'] == serviceId) {
            serviceType = reservation['service']['type'];
            break;
          }
        }
      }

      String endpoint = '';
      switch (serviceType?.toLowerCase()) {
        case 'hammam':
          endpoint = '/api/hammams/services/$serviceId/';
          break;
        case 'gym':
          endpoint = '/api/gyms/services/$serviceId/';
          break;
        case 'makeup':
          endpoint = '/api/makeup/services/$serviceId/';
          break;
        case 'henna':
          endpoint = '/api/henna/services/$serviceId/';
          break;
        case 'melhfa':
          endpoint = '/api/melhfa/services/$serviceId/';
          break;
        case 'accessory':
          endpoint = '/api/accessories/services/$serviceId/';
          break;
        default:
          print('Unknown service type: $serviceType');
          return null;
      }

      final response = await _apiService.get(endpoint);
      if (response != null) {
        _serviceDetailsCache[serviceId] = response;
        return response;
      }
      return null;
    } catch (e) {
      print('Error fetching service details for ID $serviceId: $e');
      return null;
    }
  }

  // Add these new methods for handling actions
  Future<void> _printReservation(dynamic reservation) async {
    try {
      final pdf = pw.Document();
      
      // Add content to PDF
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Container(
              padding: const pw.EdgeInsets.all(40),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.pink300, width: 2),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
              ),
              child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                  // Header with logo and title
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        _translate('confirmation'),
                        style: pw.TextStyle(
                          fontSize: 24,
                          color: PdfColors.pink700,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
                        style: const pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                ),
                pw.SizedBox(height: 20),
                  
                  // Reservation details in a styled container
                  pw.Container(
                    padding: const pw.EdgeInsets.all(20),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.pink50,
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _buildPdfInfoRow(_translate('reservation_number'), '#${reservation['id']}'),
                pw.SizedBox(height: 10),
                        _buildPdfInfoRow(_translate('service_name'), reservation['service_name'] ?? 'N/A'),
                pw.SizedBox(height: 10),
                        _buildPdfInfoRow(_translate('start_date'), DateFormat('dd/MM/yyyy').format(DateTime.parse(reservation['date_debut']))),
                pw.SizedBox(height: 10),
                        _buildPdfInfoRow(_translate('end_date'), DateFormat('dd/MM/yyyy').format(DateTime.parse(reservation['date_fin']))),
                pw.SizedBox(height: 10),
                        _buildPdfInfoRow(_translate('status'), _getStatusText(reservation['statut'])),
                        pw.SizedBox(height: 10),
                        _buildPdfInfoRow(_translate('total_amount'), '${reservation['montant_total']} MRU'),
                      ],
                    ),
                  ),
                pw.SizedBox(height: 20),
                  
                  // Provider information
                  pw.Container(
                    padding: const pw.EdgeInsets.all(20),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey100,
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          _translate('provider_details'),
                          style: pw.TextStyle(
                            fontSize: 16,
                            color: PdfColors.pink700,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                pw.SizedBox(height: 10),
                        _buildPdfInfoRow(
                          _translate('provider_name'),
                          _getProviderName(reservation),
                        ),
                        pw.SizedBox(height: 10),
                        _buildPdfInfoRow(
                          _translate('provider_phone'),
                          _getProviderPhone(reservation),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  
                  // Payment Status
                  pw.Container(
                    padding: const pw.EdgeInsets.all(20),
                    decoration: pw.BoxDecoration(
                      color: reservation['est_paye'] ? PdfColors.green50 : PdfColors.orange50,
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                    ),
                    child: pw.Row(
                      children: [
                        pw.Icon(
                          reservation['est_paye'] ? pw.IconData(0x2713) : pw.IconData(0x2717),
                          color: reservation['est_paye'] ? PdfColors.green : PdfColors.orange,
                          size: 20,
                        ),
                        pw.SizedBox(width: 10),
                        pw.Text(
                          reservation['est_paye'] ? _translate('payment_completed') : _translate('payment_pending'),
                          style: pw.TextStyle(
                            fontSize: 14,
                            color: reservation['est_paye'] ? PdfColors.green : PdfColors.orange,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  
                  // Footer with print date
                  pw.Container(
                    padding: const pw.EdgeInsets.all(20),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                    ),
                    child: pw.Text(
                      '${_translate('print_date')}: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey700,
                        fontStyle: pw.FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error printing: $e')),
      );
    }
  }

  pw.Widget _buildPdfInfoRow(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 120,
          child: pw.Text(
            label,
            style: const pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey700,
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            style: const pw.TextStyle(
              fontSize: 12,
              color: PdfColors.black,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _printCommand(dynamic command) async {
    try {
      final pdf = pw.Document();
      
      // Add content to PDF
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Text(_translate('confirmation')),
                ),
                pw.SizedBox(height: 20),
                pw.Text('${_translate('order_number')}: #${command['id'] ?? 'N/A'}'),
                pw.SizedBox(height: 10),
                pw.Text('${_translate('service_type')}: ${_getServiceTypeText(command['service_type'] ?? '')}'),
                pw.SizedBox(height: 10),
                pw.Text('${_translate('start_date')}: ${DateFormat('dd/MM/yyyy').format(DateTime.tryParse(command['date_debut'] ?? '') ?? DateTime.now())}'),
                pw.SizedBox(height: 10),
                pw.Text('${_translate('end_date')}: ${DateFormat('dd/MM/yyyy').format(DateTime.tryParse(command['date_fin'] ?? '') ?? DateTime.now())}'),
                pw.SizedBox(height: 10),
                pw.Text('${_translate('status')}: ${_getStatusText(command['status'] ?? command['statut'] ?? 'pending')}'),
                pw.SizedBox(height: 10),
                pw.Text('${_translate('total_amount')}: ${command['montant_total'] ?? '0'} MRU'),
                pw.SizedBox(height: 20),
                
                // Provider information
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        _translate('provider_details'),
                        style: pw.TextStyle(
                          fontSize: 16,
                          color: PdfColors.pink700,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                pw.SizedBox(height: 10),
                      _buildPdfInfoRow(
                        _translate('provider_name'),
                        _getProviderName(command),
                      ),
                      pw.SizedBox(height: 10),
                      _buildPdfInfoRow(
                        _translate('provider_phone'),
                        _getProviderPhone(command),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                
                // Payment Status
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: (command['est_paye'] == true) ? PdfColors.green50 : PdfColors.orange50,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Icon(
                        (command['est_paye'] == true) ? pw.IconData(0x2713) : pw.IconData(0x2717),
                        color: (command['est_paye'] == true) ? PdfColors.green : PdfColors.orange,
                        size: 20,
                      ),
                      pw.SizedBox(width: 10),
                      pw.Text(
                        (command['est_paye'] == true) ? _translate('payment_completed') : _translate('payment_pending'),
                        style: pw.TextStyle(
                          fontSize: 14,
                          color: (command['est_paye'] == true) ? PdfColors.green : PdfColors.orange,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                
                // Footer with print date
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Text(
                    '${_translate('print_date')}: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey700,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error printing: $e')),
        );
      }
    }
  }

  Future<void> _cancelReservation(int reservationId) async {
    try {
      await _apiService.cancelReservation(reservationId);
      await _fetchReservations();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_translate('reservation_cancelled'))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cancelling reservation: $e')),
        );
      }
    }
  }

  Future<void> _cancelCommand(int commandId) async {
    try {
      await _apiService.cancelCommand(commandId);
      await _fetchCommands();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_translate('reservation_cancelled'))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cancelling command: $e')),
        );
      }
    }
  }

  void _showPaymentDialog(dynamic item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_translate('choose_payment_method')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.phone_android, size: 40),
                title: const Text('Sedad'),
                onTap: () => _showPaymentDetails(item, 'Sedad'),
              ),
              ListTile(
                leading: const Icon(Icons.account_balance, size: 40),
                title: const Text('Bankily'),
                onTap: () => _showPaymentDetails(item, 'Bankily'),
              ),
              ListTile(
                leading: const Icon(Icons.phone_iphone, size: 40),
                title: const Text('Masrivi'),
                onTap: () => _showPaymentDetails(item, 'Masrivi'),
              ),
              ListTile(
                leading: const Icon(Icons.account_balance_wallet, size: 40),
                title: const Text('BIM Bank'),
                onTap: () => _showPaymentDetails(item, 'BIM Bank'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_translate('cancel')),
          ),
        ],
      ),
    );
  }

  void _showPaymentDetails(dynamic item, String paymentMethod) {
    Navigator.pop(context); // Close payment method dialog
    
    // Show loading dialog first
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    // Get provider details from API using the correct endpoint format
    _apiService.get('/api/reservations/${item['id']}/').then((response) {
      Navigator.pop(context); // Close loading dialog
      
      String providerPhone = '';
      if (response != null) {
        // Try different possible paths to get the provider phone
        if (response['fournisseur_phone'] != null) {
          providerPhone = response['fournisseur_phone'];
        } else if (response['service_provider'] != null) {
          providerPhone = response['service_provider']['phone'] ?? '';
        } else if (response['fournisseur'] != null) {
          if (response['fournisseur'] is Map) {
            providerPhone = response['fournisseur']['phone'] ?? '';
          } else {
            providerPhone = response['fournisseur'].toString();
          }
        }
      }
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('${_translate('payment_via')} $paymentMethod'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${_translate('amount')}: ${item['montant_total']} MRU'),
              const SizedBox(height: 16),
              Text(_translate('please_transfer')),
              const SizedBox(height: 8),
              Text(
                providerPhone.isNotEmpty 
                    ? providerPhone 
                    : '43632554',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              Text(_translate('after_payment')),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: Text(_translate('upload_payment_proof')),
                onPressed: () => _uploadPaymentProof(item),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(_translate('close')),
            ),
          ],
        ),
      );
    }).catchError((error) {
      Navigator.pop(context); // Close loading dialog
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_translate('error_getting_owner_details'))),
        );
      }
    });
  }

  Future<void> _uploadPaymentProof(dynamic item) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        // OCR validation before upload
        final isValid = await _tfliteService.validatePaymentProof(File(image.path));
        if (!isValid) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(_translate('Invalid payment proof. Please upload a valid receipt.'))),
            );
          }
          return;
        }
        setState(() => _isLoadingReservations = true);
        
        // Upload the payment proof
        if (item['service_type'] != null) {
          await _apiService.uploadCommandPayment(item['id'], image.path);
          await _fetchCommands();
        } else {
          await _apiService.uploadReservationPayment(item['id'], image.path);
          await _fetchReservations();
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_translate('payment_proof_sent'))),
          );
          Navigator.pop(context); // Close payment details dialog
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading payment proof: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingReservations = false);
      }
    }
  }

  // Helper method to get provider name
  String _getProviderName(dynamic reservation) {
    if (reservation is Map) {
      // Try different possible paths to get the provider name
      if (reservation['fournisseur_name'] != null) {
        return reservation['fournisseur_name'];
      } else if (reservation['fournisseur'] != null) {
        if (reservation['fournisseur'] is Map) {
          return reservation['fournisseur']['first_name'] != null && 
                 reservation['fournisseur']['last_name'] != null
              ? '${reservation['fournisseur']['first_name']} ${reservation['fournisseur']['last_name']}'
              : reservation['fournisseur']['name'] ?? 'N/A';
        }
      } else if (reservation['service_provider'] != null) {
        if (reservation['service_provider'] is Map) {
          return reservation['service_provider']['first_name'] != null && 
                 reservation['service_provider']['last_name'] != null
              ? '${reservation['service_provider']['first_name']} ${reservation['service_provider']['last_name']}'
              : reservation['service_provider']['name'] ?? 'N/A';
        }
      }
    }
    return 'N/A';
  }

  // Helper method to get provider phone
  String _getProviderPhone(dynamic reservation) {
    if (reservation is Map) {
      // Try different possible paths to get the provider phone
      if (reservation['fournisseur_phone'] != null) {
        return reservation['fournisseur_phone'];
      } else if (reservation['fournisseur'] != null) {
        if (reservation['fournisseur'] is Map) {
          return reservation['fournisseur']['phone'] ?? 'N/A';
        }
      } else if (reservation['service_provider'] != null) {
        if (reservation['service_provider'] is Map) {
          return reservation['service_provider']['phone'] ?? 'N/A';
        }
      }
    }
    return 'N/A';
  }
} 