import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../../core/errors/app_exception.dart';
import '../models/bill.dart';

class BillPage {
  const BillPage(this.bills, this.cursor);
  final List<Bill> bills;
  final DocumentSnapshot<Map<String, dynamic>>? cursor;
}

/// Offline-first: writes hit Hive immediately; Firestore persistence queues the server write.
class BillRepository {
  BillRepository(this._cache, {FirebaseFirestore? firestore, FirebaseAuth? auth, FirebaseStorage? storage})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final Box<dynamic> _cache;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  static const pageSize = 20;
  static const _cacheKey = 'bills';

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw const AppException('error_session_expired');
    return uid;
  }

  CollectionReference<Map<String, dynamic>> get _bills => _firestore.collection('users').doc(_uid).collection('bills');

  String newId() => _bills.doc().id;

  Map<String, dynamic> get _cached => Map<String, dynamic>.from(_cache.get(_cacheKey, defaultValue: const {}) as Map);

  /// Cached bills, newest first. Used for instant display and offline mode.
  List<Bill> cachedBills({String? groupId}) {
    final bills = _cached.values
        .map((e) => Bill.fromJson(Map<String, dynamic>.from(e as Map)))
        .where((b) => groupId == null || b.groupId == groupId)
        .toList()
      ..sort((x, y) => y.date.compareTo(x.date));
    return bills;
  }

  Future<void> _putCache(Bill bill) => _cache.put(_cacheKey, _cached..[bill.id] = bill.toJson());

  Future<Bill> save(Bill bill) async {
    final saved = bill.copyWith(updatedAt: DateTime.now());
    await _putCache(saved);
    final data = saved.toJson()
      ..remove('localImagePath')
      ..['updatedAt'] = FieldValue.serverTimestamp();
    // Not awaited: offline the future only completes after reconnecting; the local write is already durable.
    _bills.doc(saved.id).set(data).ignore();
    return saved;
  }

  Future<void> delete(Bill bill) async {
    await _cache.put(_cacheKey, _cached..remove(bill.id));
    _bills.doc(bill.id).delete().ignore();
    if (bill.receiptPath != null) _storage.ref(bill.receiptPath).delete().ignore();
  }

  Future<BillPage> fetchPage({DocumentSnapshot<Map<String, dynamic>>? after}) async {
    try {
      Query<Map<String, dynamic>> q = _bills.orderBy('date', descending: true).limit(pageSize);
      if (after != null) q = q.startAfterDocument(after);
      final snap = await q.get();
      final bills = snap.docs.map((d) => Bill.fromJson({...d.data(), 'updatedAt': null})).toList();
      final merged = _cached;
      for (final b in bills) {
        final local = merged[b.id];
        // Keep a pending local image reference if the upload hasn't happened yet.
        merged[b.id] = local is Map && local['localImagePath'] != null
            ? b.copyWith(localImagePath: local['localImagePath'] as String).toJson()
            : b.toJson();
      }
      await _cache.put(_cacheKey, merged);
      return BillPage(bills, snap.docs.isEmpty ? null : snap.docs.last);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  final _urlCache = <String, Future<String>>{};

  /// Every bill of a group (balances need all of them). Falls back to cache offline.
  Future<List<Bill>> fetchGroupBills(String groupId) async {
    try {
      final snap = await _bills.where('groupId', isEqualTo: groupId).get();
      final bills = snap.docs.map((d) => Bill.fromJson({...d.data(), 'updatedAt': null})).toList();
      final serverIds = bills.map((b) => b.id).toSet();
      return [...bills, ...cachedBills(groupId: groupId).where((b) => !serverIds.contains(b.id))]
        ..sort((x, y) => y.date.compareTo(x.date));
    } catch (_) {
      return cachedBills(groupId: groupId);
    }
  }

  Future<String> receiptUrl(String path) =>
      _urlCache[path] ??= _storage.ref(path).getDownloadURL()..catchError((Object _) {
        _urlCache.remove(path); // allow retry later
        return '';
      });

  /// Uploads any receipt images saved while offline. Returns how many were uploaded.
  Future<int> syncPendingImages() async {
    var uploaded = 0;
    for (final bill in cachedBills().where((b) => b.localImagePath != null)) {
      final file = File(bill.localImagePath!);
      if (!file.existsSync()) {
        await _putCache(bill.copyWith(clearLocalImage: true));
        continue;
      }
      try {
        final path = 'users/$_uid/receipts/${bill.id}.jpg';
        await _storage.ref(path).putFile(file, SettableMetadata(contentType: 'image/jpeg'));
        await save(bill.copyWith(receiptPath: path, clearLocalImage: true));
        uploaded++;
      } catch (_) {
        // Still offline or transient error: stays queued for the next reconnect.
      }
    }
    return uploaded;
  }
}
