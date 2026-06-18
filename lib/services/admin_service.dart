// lib/services/admin_service.dart
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String adminUid = 'NDZE609FisQ9Vq1Oy6cVimJvIxD3';

  static bool get isAdmin => _auth.currentUser?.uid == adminUid;
  static String? get currentUid => _auth.currentUser?.uid;

  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
        log('getAllUsers - Current UID: ${_auth.currentUser?.uid}',
          name: 'AdminService');
        log('getAllUsers - isAdmin: $isAdmin', name: 'AdminService');
      final snap = await _db.collection('users').get();
      List<Map<String, dynamic>> users = [];
      for (final doc in snap.docs) {
        final data = doc.data();
        try {
          final records = await _db
              .collection('users')
              .doc(doc.id)
              .collection('bmi_records')
              .get();
          double totalBmi = 0;
          for (final r in records.docs) {
            totalBmi += (r.data()['bmi'] as num?)?.toDouble() ?? 0;
          }
          double avgBmi =
              records.docs.isNotEmpty ? totalBmi / records.docs.length : 0;
          users.add({
            'uid': doc.id,
            'name': data['name'] ?? 'Unknown',
            'email': data['email'] ?? '',
            'updatedAt': data['updatedAt'],
            'recordCount': records.docs.length,
            'avgBmi': avgBmi,
          });
        } catch (e) {
          users.add({
            'uid': doc.id,
            'name': data['name'] ?? 'Unknown',
            'email': data['email'] ?? '',
            'updatedAt': data['updatedAt'],
            'recordCount': 0,
            'avgBmi': 0.0,
          });
        }
      }
      return users;
    } catch (e, st) {
      log('getAllUsers error: $e', error: e, stackTrace: st, name: 'AdminService');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getUserRecords(String uid) async {
    try {
      final snap = await _db
          .collection('users')
          .doc(uid)
          .collection('bmi_records')
          .orderBy('date', descending: true)
          .get();
      return snap.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
    } catch (e, st) {
      log('getUserRecords error: $e', error: e, stackTrace: st, name: 'AdminService');
      return [];
    }
  }

  static Future<void> deleteUser(String uid) async {
    try {
      final records = await _db
          .collection('users')
          .doc(uid)
          .collection('bmi_records')
          .get();
      final batch = _db.batch();
      for (final doc in records.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(_db.collection('users').doc(uid));
      await batch.commit();
      await _logAction('delete_user', {'uid': uid});
    } catch (e, st) {
      log('deleteUser error: $e', error: e, stackTrace: st, name: 'AdminService');
    }
  }

  static Future<void> deleteRecord(String uid, String recordId) async {
    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('bmi_records')
          .doc(recordId)
          .delete();
      await _logAction('delete_record', {'uid': uid, 'recordId': recordId});
    } catch (e, st) {
      log('deleteRecord error: $e', error: e, stackTrace: st, name: 'AdminService');
    }
  }

  static Future<Map<String, dynamic>> getStats() async {
    try {
      log('getStats - Current UID: ${_auth.currentUser?.uid}', name: 'AdminService');
      log('getStats - isAdmin: $isAdmin', name: 'AdminService');
      final users = await _db.collection('users').get();
      int totalRecords = 0;
      double totalBmi = 0;
      Map<String, int> categoryCount = {
        'Underweight': 0,
        'Normal': 0,
        'Overweight': 0,
        'Obese': 0,
      };
      for (final user in users.docs) {
        try {
          final records = await _db
              .collection('users')
              .doc(user.id)
              .collection('bmi_records')
              .get();
          totalRecords += records.docs.length;
          for (final rec in records.docs) {
            final bmi = (rec.data()['bmi'] as num?)?.toDouble() ?? 0;
            final cat = rec.data()['category'] as String? ?? '';
            totalBmi += bmi;
            if (categoryCount.containsKey(cat)) {
              categoryCount[cat] = categoryCount[cat]! + 1;
            }
          }
        } catch (e, st) {
          log('Error fetching records for user ${user.id}: $e',
              error: e, stackTrace: st, name: 'AdminService');
        }
      }
      return {
        'totalUsers': users.docs.length,
        'totalRecords': totalRecords,
        'avgBmi': totalRecords > 0 ? totalBmi / totalRecords : 0.0,
        'categoryCount': categoryCount,
      };
    } catch (e, st) {
      log('getStats error: $e', error: e, stackTrace: st, name: 'AdminService');
      return {
        'totalUsers': 0,
        'totalRecords': 0,
        'avgBmi': 0.0,
        'categoryCount': {
          'Underweight': 0,
          'Normal': 0,
          'Overweight': 0,
          'Obese': 0
        },
      };
    }
  }

  static Future<void> _logAction(
      String action, Map<String, dynamic> data) async {
    try {
      await _db.collection('admin_logs').add({
        'action': action,
        'data': data,
        'adminUid': adminUid,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e, st) {
      log('logAction error: $e', error: e, stackTrace: st, name: 'AdminService');
    }
  }

  static Future<List<Map<String, dynamic>>> getAdminLogs() async {
    try {
      final snap = await _db
          .collection('admin_logs')
          .orderBy('timestamp', descending: true)
          .limit(100)
          .get();
      return snap.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
    } catch (e, st) {
      log('getAdminLogs error: $e', error: e, stackTrace: st, name: 'AdminService');
      return [];
    }
  }
}
