// lib/services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/bmi_record.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static User? get currentUser => _auth.currentUser;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();
  static bool get isLoggedIn => _auth.currentUser != null;

  // ── AUTH ────────────────────────────────────────────────
  static Future<UserCredential?> register(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw _authError(e.code);
    }
  }

  static Future<UserCredential?> login(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw _authError(e.code);
    }
  }

  static Future<void> logout() => _auth.signOut();

  static Future<void> updateDisplayName(String name) async {
    await _auth.currentUser?.updateDisplayName(name);
  }

  static Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  static String _authError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  // ── USER PROFILE ────────────────────────────────────────
  static Future<void> saveUserProfile({
    required String name,
  }) async {
    final uid = currentUser?.uid;
    if (uid == null) return;
    await _db.collection('users').doc(uid).set({
      'name': name,
      'email': currentUser?.email,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<Map<String, dynamic>?> getUserProfile() async {
    final uid = currentUser?.uid;
    if (uid == null) return null;
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  // ── BMI RECORDS ─────────────────────────────────────────
  static CollectionReference<Map<String, dynamic>> _recordsRef() {
    return _db
        .collection('users')
        .doc(currentUser!.uid)
        .collection('bmi_records');
  }

  static Future<void> saveBMIRecord(BmiRecord record) async {
    if (!isLoggedIn) return;
    await _recordsRef().doc(record.id).set({
      'id': record.id,
      'bmi': record.bmi,
      'weight': record.weight,
      'height': record.height,
      'category': record.category,
      'date': record.date.toIso8601String(),
      'gender': record.gender,
      'age': record.age,
      'sleepHours': record.sleepHours,
      'bpSystolic': record.bpSystolic,
      'bpDiastolic': record.bpDiastolic,
      'heartRate': record.heartRate,
      'bloodSugar': record.bloodSugar,
      'userId': currentUser!.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<List<BmiRecord>> getBMIRecords() async {
    if (!isLoggedIn) return [];
    final snap = await _recordsRef().orderBy('date', descending: true).get();
    return snap.docs.map((doc) => _recordFromDoc(doc.data())).toList();
  }

  static Stream<List<BmiRecord>> bmiRecordsStream() {
    if (!isLoggedIn) return Stream.value([]);
    return _recordsRef().orderBy('date', descending: true).snapshots().map(
        (snap) => snap.docs.map((doc) => _recordFromDoc(doc.data())).toList());
  }

  static Future<void> deleteBMIRecord(String id) async {
    if (!isLoggedIn) return;
    await _recordsRef().doc(id).delete();
  }

  static Future<void> clearAllRecords() async {
    if (!isLoggedIn) return;
    final snap = await _recordsRef().get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  static BmiRecord _recordFromDoc(Map<String, dynamic> d) {
    return BmiRecord(
      id: d['id'],
      bmi: (d['bmi'] as num).toDouble(),
      weight: (d['weight'] as num).toDouble(),
      height: (d['height'] as num).toDouble(),
      category: d['category'],
      date: DateTime.parse(d['date']),
      gender: d['gender'],
      age: d['age'],
      sleepHours: (d['sleepHours'] as num).toDouble(),
      bpSystolic:
          d['bpSystolic'] != null ? (d['bpSystolic'] as num).toDouble() : null,
      bpDiastolic: d['bpDiastolic'] != null
          ? (d['bpDiastolic'] as num).toDouble()
          : null,
      heartRate:
          d['heartRate'] != null ? (d['heartRate'] as num).toDouble() : null,
      bloodSugar:
          d['bloodSugar'] != null ? (d['bloodSugar'] as num).toDouble() : null,
    );
  }
}
