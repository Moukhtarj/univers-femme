import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/api_service.dart';
import '../services/tflite_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ApiService _apiService = ApiService();
  final TFLiteService _tfliteService = TFLiteService();
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  int? _selectedReservationId;
  bool _isValidating = false;
  bool _isValid = false;
  String? _validationMessage;

  Future<void> _pickImage(int reservationId) async {
    setState(() {
      _selectedReservationId = reservationId;
      _selectedImage = null;
      _isValid = false;
      _validationMessage = null;
    });
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        await _validateImage();
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _validateImage() async {
    if (_selectedImage == null) return;
    setState(() {
      _isValidating = true;
      _validationMessage = null;
    });
    try {
      final isValid = await _tfliteService.validatePaymentProof(_selectedImage!);
      setState(() {
        _isValid = isValid;
        _validationMessage = isValid
            ? 'Payment proof is valid'
            : 'Invalid payment proof. Please upload a clear image of your payment receipt.';
      });
    } catch (e) {
      setState(() {
        _isValid = false;
        _validationMessage = 'Error validating image: $e';
      });
    } finally {
      setState(() {
        _isValidating = false;
      });
    }
  }

  Future<void> _uploadPaymentProof(int reservationId) async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first')),
      );
      return;
    }
    if (!_isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please validate the image first')),
      );
      return;
    }
    try {
      await _apiService.uploadReservationPayment(reservationId, _selectedImage!.path);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment proof uploaded successfully')),
      );
      setState(() {
        _selectedImage = null;
        _isValid = false;
        _validationMessage = null;
        _selectedReservationId = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading payment proof: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _apiService.getUserReservations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final reservations = snapshot.data ?? [];
          if (reservations.isEmpty) {
            return const Center(child: Text('No reservations found'));
          }
          return ListView.builder(
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              final reservation = reservations[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    ListTile(
                      title: Text('Reservation #${reservation['id']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Status: ${reservation['statut']}'),
                          Text('Date: ${reservation['date_debut']}'),
                        ],
                      ),
                      trailing: reservation['statut'] == 'pending'
                          ? IconButton(
                              icon: const Icon(Icons.upload_file),
                              onPressed: () => _pickImage(reservation['id']),
                            )
                          : null,
                    ),
                    if (_selectedReservationId == reservation['id'] && _selectedImage != null) ...[
                      Container(
                        height: 200,
                        width: double.infinity,
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Image.file(
                          _selectedImage!,
                          fit: BoxFit.contain,
                        ),
                      ),
                      if (_isValidating)
                        const CircularProgressIndicator()
                      else if (_validationMessage != null)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            _validationMessage!,
                            style: TextStyle(
                              color: _isValid ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                      ElevatedButton(
                        onPressed: _isValid
                            ? () => _uploadPaymentProof(reservation['id'])
                            : null,
                        child: const Text('Upload Payment Proof'),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _tfliteService.dispose();
    super.dispose();
  }
} 