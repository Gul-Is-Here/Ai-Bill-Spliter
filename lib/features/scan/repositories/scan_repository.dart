import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/services/functions_client.dart';
import '../../../core/utils/money.dart';
import '../../bill/models/bill.dart';
import 'receipt_parser.dart';

class ScanRepository {
  ScanRepository(this._functions, {FirebaseStorage? storage, FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _storage = storage ?? FirebaseStorage.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FunctionsClient _functions;
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  static const maxBytes = 1024 * 1024;

  String newBillId() => _firestore.collection('bills').doc().id;

  /// Re-encodes as JPEG, stepping quality/size down until it fits in ~1MB.
  Future<Uint8List> compress(String path) async {
    for (final (width, quality) in const [(1600, 85), (1600, 70), (1280, 60), (1024, 50)]) {
      final bytes = await FlutterImageCompress.compressWithFile(path, minWidth: width, minHeight: width, quality: quality);
      if (bytes == null) throw const AppException('error_image_unreadable');
      if (bytes.lengthInBytes <= maxBytes) return bytes;
    }
    throw const AppException('error_image_too_large');
  }

  /// Uploads to users/{uid}/receipts/{billId}.jpg and returns the Storage path.
  Future<String> upload(String billId, Uint8List bytes) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw const AppException('error_session_expired');
    final path = 'users/$uid/receipts/$billId.jpg';
    try {
      await _storage.ref(path).putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      return path;
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<Bill> scan({required String billId, required String receiptPath, required String fallbackCurrency}) async {
    final json = await _functions.call('scanReceipt', {
      'imagePath': receiptPath,
      'fractionDigits': Money.fractionDigits(fallbackCurrency),
    });
    return ReceiptParser.toBill(
      json,
      id: billId,
      fallbackCurrency: fallbackCurrency,
      receiptPath: receiptPath,
      now: DateTime.now(),
    );
  }
}
