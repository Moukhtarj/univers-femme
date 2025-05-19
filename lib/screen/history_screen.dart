import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/reservation.dart';

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
            status = reservation.statut;
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
    // Extract service ID
    int serviceId = -1;
    
    if (reservation is Map) {
      if (reservation['service'] is Map && reservation['service']['id'] != null) {
        serviceId = reservation['service']['id'];
      } else if (reservation['service'] != null) {
        serviceId = int.tryParse(reservation['service'].toString()) ?? -1;
      }
    } else if (reservation is Reservation) {
      serviceId = reservation.service;
    }
    
    return FutureBuilder<Map<String, dynamic>?>(
      // Only fetch details if we have a valid service ID
      future: serviceId > 0 ? _getServiceDetails(serviceId) : Future.value(null),
      builder: (context, snapshot) {
        // Determine service details based on snapshot data
        String serviceName;
        String? imageUrl;
        dynamic price;
        
        // 1. Try to get details from the future result if available
        if (snapshot.connectionState == ConnectionState.done && 
            snapshot.data != null &&
            snapshot.hasData) {
          final serviceDetails = snapshot.data!;
          // Use nom or name field depending on what's available
          serviceName = serviceDetails['nom'] ?? serviceDetails['name'] ?? 'Service $serviceId';
          imageUrl = serviceDetails['image'];
          price = serviceDetails['prix'] ?? serviceDetails['price'];
          
          print('Found detailed service info: $serviceName, image: $imageUrl');
        }
        // 2. If future is still loading or failed, use data from reservation
        else {
          if (reservation is Map) {
            final service = reservation['service'] ?? {};
            
            if (service is Map) {
              serviceName = service['nom'] ?? service['name'] ?? reservation['service_name'] ?? 'Service $serviceId';
              imageUrl = service['image'];
              price = service['prix'] ?? service['price'];
            } else {
              serviceName = reservation['service_name'] ?? 'Service $serviceId';
            }
          } else if (reservation is Reservation) {
            serviceName = 'Service ${reservation.service}';
          } else {
            serviceName = 'Unknown Service';
          }
        }
        
        // Convert image URL to baseUrl if it's a relative path
        if (imageUrl != null && imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
          imageUrl = '${_apiService.baseUrl}$imageUrl';
        }
        
        // Debug what we're displaying
        print('Displaying service: $serviceName, serviceId: $serviceId, imageUrl: $imageUrl');
        
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
                    // Service Image or Icon
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.pink[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: snapshot.connectionState == ConnectionState.waiting
                          ? const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF06292)),
                                ),
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: imageUrl != null && imageUrl.isNotEmpty
                                  ? Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        print('Error loading image: $error');
                                        return Icon(Icons.spa, color: Colors.pink[300], size: 24);
                                      },
                                    )
                                  : Icon(Icons.spa, color: Colors.pink[300], size: 24),
                            ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Service name and category
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
                        reservation is Map 
                            ? _getStatusText(reservation['status'] ?? reservation['statut'] ?? 'pending')
                            : (reservation is Reservation 
                                ? _getStatusText(reservation.statut) 
                                : _getStatusText('pending')),
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
                if (price != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: _buildInfoRow(
                      Icons.payments,
                      '$price MRU',
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCommandCard(dynamic command, String formattedDate, Color statusColor) {
    final productName = command['product_name'] ?? 'Product';
    final address = command['address'] ?? '';
    final phone = command['phone_number'] ?? '';
    
    // Extract service/product ID if available
    int serviceId = -1;
    if (command['service'] is Map && command['service']['id'] != null) {
      serviceId = command['service']['id'];
    } else if (command['service'] != null) {
      serviceId = int.tryParse(command['service'].toString()) ?? -1;
    }
    
    return FutureBuilder<Map<String, dynamic>?>(
      // Only fetch details if we have a valid service ID
      future: serviceId > 0 ? _getServiceDetails(serviceId) : Future.value(null),
      builder: (context, snapshot) {
        // Determine service details based on snapshot data
        String? imageUrl;
        
        // 1. Try to get details from the future result if available
        if (snapshot.connectionState == ConnectionState.done && 
            snapshot.data != null &&
            snapshot.hasData) {
          final serviceDetails = snapshot.data!;
          imageUrl = serviceDetails['image'];
        }
        // 2. If future is still loading or failed, use data from command
        else {
          if (command['service'] is Map) {
            imageUrl = command['service']['image'];
          } else if (command['image'] != null) {
            imageUrl = command['image'];
          }
        }
        
        // Convert image URL to baseUrl if it's a relative path
        if (imageUrl != null && imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
          imageUrl = '${_apiService.baseUrl}$imageUrl';
        }
        
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
                    // Product Image or Icon
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.pink[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: snapshot.connectionState == ConnectionState.waiting
                          ? const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF06292)),
                                ),
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: imageUrl != null && imageUrl.isNotEmpty
                                  ? Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        print('Error loading order image: $error');
                                        return Icon(Icons.shopping_bag, color: Colors.pink[300], size: 24);
                                      },
                                    )
                                  : Icon(Icons.shopping_bag, color: Colors.pink[300], size: 24),
                            ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Product name
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            productName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF880E4F),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.selectedLanguage == 'Arabic' ? 'طلب' : 'Order',
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
                        _getStatusText(command['status'] ?? 'pending'),
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
                
                // Address
                if (address.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: _buildInfoRow(
                      Icons.location_on,
                      address,
                    ),
                  ),
                
                // Phone
                if (phone.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: _buildInfoRow(
                      Icons.phone,
                      phone,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
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
      final details = await _apiService.getServiceDetails(serviceId);
      if (details != null) {
        _serviceDetailsCache[serviceId] = details;
      }
      return details;
    } catch (e) {
      print('Error fetching service details for ID $serviceId: $e');
      return null;
    }
  }
} 