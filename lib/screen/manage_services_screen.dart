import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class ManageServicesScreen extends StatefulWidget {
  const ManageServicesScreen({super.key});

  @override
  State<ManageServicesScreen> createState() => _ManageServicesScreenState();
}

class _ManageServicesScreenState extends State<ManageServicesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _error;
  String _selectedLanguage = 'en'; // Add language selection

  // Local translations
  final Map<String, Map<String, String>> _translations = {
    'en': {
      'manage_services': 'Manage Services',
      'henna_services': 'Henna Services',
      'accessories': 'Accessories',
      'melhfa_models': 'Melhfa Models',
      'hammam_services': 'Hammam Services',
      'gym_services': 'Gym Services',
      'makeup_services': 'Makeup Services',
      'no_services_found': 'No services found',
      'add_first_service': 'Add your first service',
      'service_deleted': 'Service deleted successfully',
      'service_added': 'Service added successfully',
      'error': 'Error',
      'retry': 'Retry',
      'no_auth_token': 'No authentication token found',
      'failed_to_delete': 'Failed to delete service',
      'edit': 'Edit',
      'delete': 'Delete',
      'cancel': 'Cancel',
      'save': 'Save',
      'name': 'Name',
      'description': 'Description',
      'price': 'Price',
      'image': 'Image',
      'add_service': 'Add Service',
      'edit_service': 'Edit Service',
      'service_name': 'Service Name',
      'service_description': 'Service Description',
      'service_price': 'Service Price',
      'service_image': 'Service Image',
      'loading': 'Loading...',
      'please_enter': 'Please enter',
      'please_enter_valid_number': 'Please enter a valid number',
      'active': 'Active',
      'update_service': 'Update Service',
    },
    'fr': {
      'manage_services': 'Gérer les Services',
      'henna_services': 'Services de Henné',
      'accessories': 'Accessoires',
      'melhfa_models': 'Modèles de Melhfa',
      'hammam_services': 'Services de Hammam',
      'gym_services': 'Services de Gym',
      'makeup_services': 'Services de Maquillage',
      'no_services_found': 'Aucun service trouvé',
      'add_first_service': 'Ajoutez votre premier service',
      'service_deleted': 'Service supprimé avec succès',
      'service_added': 'Service ajouté avec succès',
      'error': 'Erreur',
      'retry': 'Réessayer',
      'no_auth_token': 'Aucun token d\'authentification trouvé',
      'failed_to_delete': 'Échec de la suppression du service',
      'edit': 'Modifier',
      'delete': 'Supprimer',
      'cancel': 'Annuler',
      'save': 'Enregistrer',
      'name': 'Nom',
      'description': 'Description',
      'price': 'Prix',
      'image': 'Image',
      'add_service': 'Ajouter un Service',
      'edit_service': 'Modifier le Service',
      'service_name': 'Nom du Service',
      'service_description': 'Description du Service',
      'service_price': 'Prix du Service',
      'service_image': 'Image du Service',
      'loading': 'Chargement...',
      'please_enter': 'Veuillez entrer',
      'please_enter_valid_number': 'Veuillez entrer un nombre valide',
      'active': 'Actif',
      'update_service': 'Mettre à jour le Service',
    },
    'ar': {
      'manage_services': 'إدارة الخدمات',
      'henna_services': 'خدمات الحناء',
      'accessories': 'الإكسسوارات',
      'melhfa_models': 'نماذج الملحفة',
      'hammam_services': 'خدمات الحمام',
      'gym_services': 'خدمات الجيم',
      'makeup_services': 'خدمات المكياج',
      'no_services_found': 'لم يتم العثور على خدمات',
      'add_first_service': 'أضف خدمتك الأولى',
      'service_deleted': 'تم حذف الخدمة بنجاح',
      'service_added': 'تم إضافة الخدمة بنجاح',
      'error': 'خطأ',
      'retry': 'إعادة المحاولة',
      'no_auth_token': 'لم يتم العثور على رمز المصادقة',
      'failed_to_delete': 'فشل في حذف الخدمة',
      'edit': 'تعديل',
      'delete': 'حذف',
      'cancel': 'إلغاء',
      'save': 'حفظ',
      'name': 'الاسم',
      'description': 'الوصف',
      'price': 'السعر',
      'image': 'الصورة',
      'add_service': 'إضافة خدمة',
      'edit_service': 'تعديل الخدمة',
      'service_name': 'اسم الخدمة',
      'service_description': 'وصف الخدمة',
      'service_price': 'سعر الخدمة',
      'service_image': 'صورة الخدمة',
      'loading': 'جاري التحميل...',
      'please_enter': 'يرجى إدخال',
      'please_enter_valid_number': 'يرجى إدخال رقم صحيح',
      'active': 'نشط',
      'update_service': 'تحديث الخدمة',
    },
  };

  String _getTranslation(String key) {
    // Use selected language, fallback to English
    return _translations[_selectedLanguage]?[key] ?? _translations['en']?[key] ?? key;
  }

  // Data for different service types
  Map<String, List<Map<String, dynamic>>> _services = {
    'henna': [],
    'accessories': [],
    'melhfa': [],
    'hammam': [],
    'gym': [],
    'makeup': [],
  };

  final List<String> _serviceTypes = [
    'henna',
    'accessories',
    'melhfa',
    'hammam',
    'gym',
    'makeup',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _serviceTypes.length, vsync: this);
    _loadAllServices();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllServices() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception(_getTranslation('no_auth_token'));
      }

      // Load services for each type
      for (String serviceType in _serviceTypes) {
        await _loadServicesByType(serviceType, token);
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadServicesByType(String serviceType, String token) async {
    try {
      String endpoint = '';
      
      switch (serviceType) {
        case 'henna':
          endpoint = '${Config.apiUrl}/api/henna/';
          break;
        case 'accessories':
          endpoint = '${Config.apiUrl}/api/accessories/';
          break;
        case 'melhfa':
          endpoint = '${Config.apiUrl}/api/melhfa-models/';
          break;
        case 'hammam':
          endpoint = '${Config.apiUrl}/api/hammams/';
          break;
        case 'gym':
          endpoint = '${Config.apiUrl}/api/gyms/';
          break;
        case 'makeup':
          endpoint = '${Config.apiUrl}/api/makeup/';
          break;
      }

      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<Map<String, dynamic>> services = [];
        
        // Handle different response structures
        if (data is Map<String, dynamic>) {
          if (data.containsKey('results') && data['results'] is List) {
            services = List<Map<String, dynamic>>.from(data['results']);
          } else if (data.containsKey('data') && data['data'] is List) {
            services = List<Map<String, dynamic>>.from(data['data']);
          } else {
            // If no recognizable structure, set empty list
            print('Could not parse $serviceType services from response structure');
            print('Response keys: ${data.keys.toList()}');
            services = [];
          }
        } else if (data is List) {
          services = List<Map<String, dynamic>>.from(data);
        } else {
          print('Unexpected response format for $serviceType services');
          print('Response type: ${data.runtimeType}');
          services = [];
        }
        
        print('Loaded ${services.length} $serviceType services');
        setState(() {
          _services[serviceType] = services;
        });
      } else {
        print('Error loading $serviceType services: HTTP ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error loading $serviceType services: $e');
    }
  }

  Future<void> _deleteService(String serviceType, int serviceId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      String endpoint = '';
      
      switch (serviceType) {
        case 'henna':
          endpoint = '${Config.apiUrl}/api/henna/$serviceId/';
          break;
        case 'accessories':
          endpoint = '${Config.apiUrl}/api/accessories/$serviceId/';
          break;
        case 'melhfa':
          endpoint = '${Config.apiUrl}/api/melhfa-models/$serviceId/';
          break;
        case 'hammam':
          endpoint = '${Config.apiUrl}/api/hammams/$serviceId/';
          break;
        case 'gym':
          endpoint = '${Config.apiUrl}/api/gyms/$serviceId/';
          break;
        case 'makeup':
          endpoint = '${Config.apiUrl}/api/makeup-services/$serviceId/';
          break;
      }

      final response = await http.delete(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_getTranslation('service_deleted'))),
        );
        _loadAllServices();
      } else {
        throw Exception('${_getTranslation('failed_to_delete')}: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_getTranslation('error')}: $e')),
      );
    }
  }

  void _showAddServiceDialog(String serviceType) {
    showDialog(
      context: context,
      builder: (context) => AddServiceDialog(
        serviceType: serviceType,
        getTranslation: _getTranslation,
      ),
    ).then((_) => _loadAllServices());
  }

  void _showEditServiceDialog(String serviceType, Map<String, dynamic> service) {
    showDialog(
      context: context,
      builder: (context) => EditServiceDialog(
        serviceType: serviceType,
        service: service,
        getTranslation: _getTranslation,
      ),
    ).then((_) => _loadAllServices());
  }

  IconData _getServiceIcon(String serviceType) {
    switch (serviceType) {
      case 'henna':
        return Icons.back_hand;
      case 'accessories':
        return Icons.diamond;
      case 'melhfa':
        return Icons.checkroom;
      case 'hammam':
        return Icons.spa;
      case 'gym':
        return Icons.sports_gymnastics;
      case 'makeup':
        return Icons.brush;
      default:
        return Icons.category;
    }
  }

  Color _getServiceColor(String serviceType) {
    switch (serviceType) {
      case 'henna':
        return const Color(0xFF8E44AD);
      case 'accessories':
        return const Color(0xFFF39C12);
      case 'melhfa':
        return const Color(0xFFE74C3C);
      case 'hammam':
        return const Color(0xFF3498DB);
      case 'gym':
        return const Color(0xFF27AE60);
      case 'makeup':
        return const Color(0xFFE91E63);
      default:
        return const Color(0xFF95A5A6);
    }
  }

  String _getServiceTypeTitle(String serviceType) {
    switch (serviceType) {
      case 'henna':
        return _getTranslation('henna_services');
      case 'accessories':
        return _getTranslation('accessories');
      case 'melhfa':
        return _getTranslation('melhfa_models');
      case 'hammam':
        return _getTranslation('hammam_services');
      case 'gym':
        return _getTranslation('gym_services');
      case 'makeup':
        return _getTranslation('makeup_services');
      default:
        return 'Service';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(_getTranslation('manage_services')),
        backgroundColor: const Color.fromRGBO(255, 192, 203, 1),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: _serviceTypes.map((type) {
            return Tab(
              icon: Icon(_getServiceIcon(type)),
              text: _getServiceTypeTitle(type),
            );
          }).toList(),
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllServices,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${_getTranslation('error')}: $_error'),
                      ElevatedButton(
                        onPressed: _loadAllServices,
                        child: Text(_getTranslation('retry')),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: _serviceTypes.map((serviceType) {
                    return _buildServiceList(serviceType);
                  }).toList(),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final currentServiceType = _serviceTypes[_tabController.index];
          _showAddServiceDialog(currentServiceType);
        },
        backgroundColor: const Color.fromRGBO(255, 192, 203, 1),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildServiceList(String serviceType) {
    final services = _services[serviceType] ?? [];
    
    if (services.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getServiceIcon(serviceType),
              size: 64,
              color: _getServiceColor(serviceType).withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _getTranslation('no_services_found'),
              style: const TextStyle(
                fontSize: 18,
                color: Color(0xFF7F8C8D),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getTranslation('add_first_service'),
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF95A5A6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: service['image_url'] != null && service['image_url'].isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      service['image_url'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return CircleAvatar(
                          backgroundColor: _getServiceColor(serviceType).withOpacity(0.1),
                          child: Icon(
                            _getServiceIcon(serviceType),
                            color: _getServiceColor(serviceType),
                          ),
                        );
                      },
                    ),
                  )
                : CircleAvatar(
                    backgroundColor: _getServiceColor(serviceType).withOpacity(0.1),
                    child: Icon(
                      _getServiceIcon(serviceType),
                      color: _getServiceColor(serviceType),
                    ),
                  ),
            title: Text(
              service['name'] ?? service['title'] ?? 'Unnamed Service',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (service['price'] != null)
                  Text('Price: \$${service['price']}'),
                if (service['description'] != null)
                  Text(
                    service['description'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (service['is_active'] != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: service['is_active'] 
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      service['is_active'] ? 'Active' : 'Inactive',
                      style: TextStyle(
                        color: service['is_active'] ? Colors.green : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditServiceDialog(serviceType, service);
                } else if (value == 'delete') {
                  dynamic serviceId = service['id'];
                  _showDeleteConfirmation(serviceType, serviceId);
                }
              },
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(String serviceType, dynamic serviceId) {
    // Convert serviceId to int if it's a string
    int id;
    if (serviceId is String) {
      id = int.tryParse(serviceId) ?? 0;
    } else if (serviceId is int) {
      id = serviceId;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid service ID')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Service'),
        content: Text('Are you sure you want to delete this ${_getServiceTypeTitle(serviceType).toLowerCase()}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteService(serviceType, id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class AddServiceDialog extends StatefulWidget {
  final String serviceType;
  final String Function(String) getTranslation;

  const AddServiceDialog({
    super.key,
    required this.serviceType,
    required this.getTranslation,
  });

  @override
  State<AddServiceDialog> createState() => _AddServiceDialogState();
}

class _AddServiceDialogState extends State<AddServiceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  bool _isActive = true;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add ${_getServiceTypeTitle(widget.serviceType)}'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SwitchListTile(
                title: const Text('Active'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitService,
          child: _isSubmitting
              ? const CircularProgressIndicator()
              : const Text('Add Service'),
        ),
      ],
    );
  }

  String _getServiceTypeTitle(String serviceType) {
    switch (serviceType) {
      case 'henna':
        return 'Henna Service';
      case 'accessories':
        return 'Accessory';
      case 'melhfa':
        return 'Melhfa Model';
      case 'hammam':
        return 'Hammam Service';
      case 'gym':
        return 'Gym Service';
      case 'makeup':
        return 'Makeup Service';
      default:
        return 'Service';
    }
  }

  Future<void> _submitService() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() {
        _isSubmitting = true;
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      String endpoint = '';
      
      switch (widget.serviceType) {
        case 'henna':
          endpoint = '${Config.apiUrl}/api/henna/';
          break;
        case 'accessories':
          endpoint = '${Config.apiUrl}/api/accessories/';
          break;
        case 'melhfa':
          endpoint = '${Config.apiUrl}/api/melhfa-models/';
          break;
        case 'hammam':
          endpoint = '${Config.apiUrl}/api/hammams/';
          break;
        case 'gym':
          endpoint = '${Config.apiUrl}/api/gyms/';
          break;
        case 'makeup':
          endpoint = '${Config.apiUrl}/api/makeup/';
          break;
      }

      final serviceData = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'price': double.parse(_priceController.text),
        'is_active': _isActive,
      };

      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(serviceData),
      );

      if (response.statusCode == 201) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.getTranslation('service_added'))),
        );
      } else {
        throw Exception('Failed to add service: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.getTranslation('error')}: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}

class EditServiceDialog extends StatefulWidget {
  final String serviceType;
  final Map<String, dynamic> service;
  final String Function(String) getTranslation;

  const EditServiceDialog({
    super.key,
    required this.serviceType,
    required this.service,
    required this.getTranslation,
  });

  @override
  State<EditServiceDialog> createState() => _EditServiceDialogState();
}

class _EditServiceDialogState extends State<EditServiceDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late bool _isActive;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.service['name'] ?? '');
    _descriptionController = TextEditingController(text: widget.service['description'] ?? '');
    _priceController = TextEditingController(text: (widget.service['price'] ?? 0).toString());
    _isActive = widget.service['is_active'] ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.getTranslation('edit_service')} - ${_getServiceTypeTitle(widget.serviceType)}'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: widget.getTranslation('name')),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '${widget.getTranslation('please_enter')} ${widget.getTranslation('name').toLowerCase()}';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: widget.getTranslation('description')),
                maxLines: 3,
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: widget.getTranslation('price')),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '${widget.getTranslation('please_enter')} ${widget.getTranslation('price').toLowerCase()}';
                  }
                  if (double.tryParse(value) == null) {
                    return widget.getTranslation('please_enter_valid_number');
                  }
                  return null;
                },
              ),
              SwitchListTile(
                title: Text(widget.getTranslation('active')),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(widget.getTranslation('cancel')),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _updateService,
          child: _isSubmitting
              ? const CircularProgressIndicator()
              : Text(widget.getTranslation('update_service')),
        ),
      ],
    );
  }

  String _getServiceTypeTitle(String serviceType) {
    switch (serviceType) {
      case 'henna':
        return widget.getTranslation('henna_services');
      case 'accessories':
        return widget.getTranslation('accessories');
      case 'melhfa':
        return widget.getTranslation('melhfa_models');
      case 'hammam':
        return widget.getTranslation('hammam_services');
      case 'gym':
        return widget.getTranslation('gym_services');
      case 'makeup':
        return widget.getTranslation('makeup_services');
      default:
        return 'Service';
    }
  }

  Future<void> _updateService() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() {
        _isSubmitting = true;
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      String endpoint = '';
      
      switch (widget.serviceType) {
        case 'henna':
          endpoint = '${Config.apiUrl}/api/henna/${widget.service['id']}/';
          break;
        case 'accessories':
          endpoint = '${Config.apiUrl}/api/accessories/${widget.service['id']}/';
          break;
        case 'melhfa':
          endpoint = '${Config.apiUrl}/api/melhfa-models/${widget.service['id']}/';
          break;
        case 'hammam':
          endpoint = '${Config.apiUrl}/api/hammams/${widget.service['id']}/';
          break;
        case 'gym':
          endpoint = '${Config.apiUrl}/api/gyms/${widget.service['id']}/';
          break;
        case 'makeup':
          endpoint = '${Config.apiUrl}/api/makeup-services/${widget.service['id']}/';
          break;
      }

      final serviceData = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'price': double.parse(_priceController.text),
        'is_active': _isActive,
      };

      final response = await http.put(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(serviceData),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service updated successfully')),
        );
      } else {
        throw Exception('Failed to update service: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.getTranslation('error')}: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }
} 