import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
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
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> _filterOptions = [
    'all',
    'pending',
    'confirmed',
    'completed',
    'cancelled',
  ];

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
        throw Exception('No authentication token found');
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
        throw Exception('Failed to load reservations: ${response.statusCode}');
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
        throw Exception('No authentication token found');
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
            content: Text('Reservation status updated to $status'),
            backgroundColor: _getStatusColor(status),
          ),
        );
        _loadReservations();
      } else {
        throw Exception('Failed to update reservation: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
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
        title: const Text(
          'Reservations',
          style: TextStyle(
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
                    const Text(
                      'Filter Reservations',
                      style: TextStyle(
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
                        const Text(
                          'Loading reservations...',
                          style: TextStyle(
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
                              const Text(
                                'Oops! Something went wrong',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Error: $_error',
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
                                label: const Text('Try Again'),
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
                                  const Text(
                                    'No reservations found',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2C3E50),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _selectedFilter == 'all'
                                        ? 'You don\'t have any reservations yet'
                                        : 'No ${_selectedFilter} reservations found',
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
                  'Client Information',
                  Icons.person,
                  [
                    _buildInfoRow('Name', reservation['user_name'] ?? 'Unknown Client'),
                    _buildInfoRow('Phone', reservation['client_phone'] ?? 'No phone'),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Reservation Details
                _buildInfoSection(
                  'Reservation Details',
                  Icons.event,
                  [
                    _buildInfoRow('Date', _formatDate(reservation['date_debut'])),
                    _buildInfoRow('Amount', '\$${reservation['montant_total']?.toString() ?? '0'}'),
                  ],
                ),
                
                if (reservation['commentaire']?.isNotEmpty == true) ...[
                  const SizedBox(height: 20),
                  _buildInfoSection(
                    'Comments',
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
                          'Confirm',
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
                          'Complete',
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
                          'Cancel',
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
                    'View Details',
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
                            Text(
                              'Reservation #${reservation['id']}',
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
                          'Reservation Details',
                          Icons.event_note,
                          [
                            _buildDetailRow('Start Date', _formatDate(reservation['date_debut'])),
                            _buildDetailRow('End Date', _formatDate(reservation['date_fin'])),
                            // _buildDetailRow('Created', _formatDate(reservation['date_creation'])),
                            // _buildDetailRow('Modified', _formatDate(reservation['date_modification'])),
                            _buildDetailRow('Total Amount', '\$${reservation['montant_total']?.toString() ?? '0'}'),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Service Information Section
                        _buildDetailSection(
                          'Service Information',
                          Icons.business_center,
                          [
                            _buildDetailRow('Service Type', serviceType.toUpperCase()),
                            _buildDetailRow('Service Name', reservation['service_name'] ?? 'Unknown Service'),
                            if (reservation['service_description'] != null)
                              _buildDetailRow('Description', reservation['service_description']),
                          ],
                        ),
                        
                        if (reservation['commentaire']?.isNotEmpty == true) ...[
                          const SizedBox(height: 20),
                          _buildDetailSection(
                            'Comments',
                            Icons.comment,
                            [
                              _buildDetailRow('', reservation['commentaire']),
                            ],
                          ),
                        ],
                        
                        if (isPaid && reservation['preuve_paiement'] != null) ...[
                          const SizedBox(height: 20),
                          _buildDetailSection(
                            'Payment Proof',
                            Icons.receipt,
                            [
                              _buildPaymentProofRow(reservation['preuve_paiement']),
                            ],
                          ),
                        ],
                        
                        if (reservation['raison_refus']?.isNotEmpty == true) ...[
                          const SizedBox(height: 20),
                          _buildDetailSection(
                            'Rejection Reason',
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
                          child: const Text(
                            'Close',
                            style: TextStyle(
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
      return const Text(
        'No payment ',
        style: TextStyle(
          fontSize: 14,
          color: Color(0xFF7F8C8D),
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment proof document:',
          style: TextStyle(
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
                    'View Payment Proof',
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

  void _openPaymentProof(String proofUrl) {
    // This would typically open the document in a viewer or download it
    // For now, we'll show a snackbar with the URL
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening payment proof: $proofUrl'),
        backgroundColor: const Color.fromRGBO(255, 192, 203, 1),
      ),
    );
  }
}
