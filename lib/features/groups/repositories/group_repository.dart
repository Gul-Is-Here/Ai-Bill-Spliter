import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../../core/errors/app_exception.dart';
import '../models/group.dart';

/// Offline-first like BillRepository: Hive first, Firestore queued.
class GroupRepository {
  GroupRepository(this._cache, {FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final Box<dynamic> _cache;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const _cacheKey = 'groups';

  CollectionReference<Map<String, dynamic>> get _groups {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw const AppException('error_session_expired');
    return _firestore.collection('users').doc(uid).collection('groups');
  }

  String newId() => _groups.doc().id;

  Map<String, dynamic> get _cached => Map<String, dynamic>.from(_cache.get(_cacheKey, defaultValue: const {}) as Map);

  List<Group> cachedGroups() => _cached.values
      .map((e) => Group.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  Group? cachedGroup(String id) {
    final raw = _cached[id];
    return raw == null ? null : Group.fromJson(Map<String, dynamic>.from(raw as Map));
  }

  Future<List<Group>> fetchAll() async {
    try {
      final snap = await _groups.get();
      final groups = snap.docs.map((d) => Group.fromJson(d.data())).toList();
      final serverIds = groups.map((g) => g.id).toSet();
      // Keep groups created offline that the server hasn't seen yet.
      final merged = {
        for (final g in cachedGroups().where((g) => !serverIds.contains(g.id))) g.id: g.toJson(),
        for (final g in groups) g.id: g.toJson(),
      };
      await _cache.put(_cacheKey, merged);
      return cachedGroups();
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<Group> save(Group group) async {
    await _cache.put(_cacheKey, _cached..[group.id] = group.toJson());
    _groups.doc(group.id).set(group.toJson()).ignore();
    return group;
  }

  Future<void> delete(String id) async {
    await _cache.put(_cacheKey, _cached..remove(id));
    _groups.doc(id).delete().ignore();
  }
}
