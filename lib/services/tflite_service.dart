import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class TFLiteService {
  static final TFLiteService _instance = TFLiteService._internal();
  factory TFLiteService() => _instance;
  TFLiteService._internal();

  /// Checks if the image contains the required payment proof information
  /// in Arabic, French, or English.
  Future<bool> validatePaymentProof(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final recognizedText = await textRecognizer.processImage(inputImage);
      final text = recognizedText.text.toLowerCase();

      // Required keywords in different languages
      final receiverKeywords = [
        'receveur', 'receiver', 'المستلم', 'bénéficiaire', 'destinataire'
      ];
      final amountKeywords = [
        'montant', 'amount', 'المبلغ', 'envoyé', 'sent'
      ];
      final idKeywords = [
        'trs id', 'transaction id', 'رقم العملية', 'id', 'identifiant'
      ];
      final dateKeywords = [
        'date', 'heure', 'time', 'التاريخ', 'الوقت'
      ];
      final successKeywords = [
        'transfert réussi', 'transfer successful', 'تم التحويل', 'effectué', 'réussi', 'success'
      ];

      // Check for presence of at least one keyword from each group
      bool hasReceiver = receiverKeywords.any((k) => text.contains(k));
      bool hasAmount = amountKeywords.any((k) => text.contains(k));
      bool hasId = idKeywords.any((k) => text.contains(k));
      bool hasDate = dateKeywords.any((k) => text.contains(k));
      bool hasSuccess = successKeywords.any((k) => text.contains(k));

      // You can print the recognized text for debugging
      print('OCR recognized text: $text');

      // Require at least 4 out of 5 fields to be present
      int score = [hasReceiver, hasAmount, hasId, hasDate, hasSuccess].where((b) => b).length;
      return score >= 4;
    } catch (e) {
      print('Error validating payment proof: $e');
      return false;
    }
  }

  void dispose() {
    // No cleanup needed for this implementation
  }
} 