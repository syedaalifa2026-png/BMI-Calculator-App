// lib/services/app_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/bmi_record.dart';
import '../utils/app_theme.dart';
import 'firebase_service.dart';

class AppProvider extends ChangeNotifier {
  String _userName = '';
  DateTime? _birthDate;
  String _gender = 'Male';
  bool _isDarkMode = false;
  String _unitSystem = 'Metric';
  double _weight = 70.0;
  double _height = 170.0;
  double _sleepHours = 8.0;
  double _currentBMI = 0.0;
  String _currentCategory = '';
  List<BmiRecord> _history = [];
  double? _bpSystolic;
  double? _bpDiastolic;
  double? _heartRate;
  double? _bloodSugar;

  String get userName => _userName;
  DateTime? get birthDate => _birthDate;
  String get gender => _gender;
  bool get isDarkMode => _isDarkMode;
  String get unitSystem => _unitSystem;
  double get weight => _weight;
  double get height => _height;
  double get sleepHours => _sleepHours;
  double get currentBMI => _currentBMI;
  String get currentCategory => _currentCategory;
  List<BmiRecord> get history => _history;
  double? get bpSystolic => _bpSystolic;
  double? get bpDiastolic => _bpDiastolic;
  double? get heartRate => _heartRate;
  double? get bloodSugar => _bloodSugar;

  int get age {
    if (_birthDate == null) return 0;
    final now = DateTime.now();
    int a = now.year - _birthDate!.year;
    if (now.month < _birthDate!.month ||
        (now.month == _birthDate!.month && now.day < _birthDate!.day)) {
      a--;
    }
    return a;
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString('userName') ?? '';
    _gender = prefs.getString('gender') ?? 'Male';
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _unitSystem = prefs.getString('unitSystem') ?? 'Metric';
    _weight = prefs.getDouble('weight') ?? 70.0;
    _height = prefs.getDouble('height') ?? 170.0;
    _sleepHours = prefs.getDouble('sleepHours') ?? 8.0;
    final ms = prefs.getInt('birthDate');
    if (ms != null) _birthDate = DateTime.fromMillisecondsSinceEpoch(ms);

    // Load from Firebase if logged in, else local
    if (FirebaseService.isLoggedIn) {
      try {
        _history = await FirebaseService.getBMIRecords();
        // Also sync display name
        final fbName = FirebaseService.currentUser?.displayName ?? '';
        if (fbName.isNotEmpty) _userName = fbName;
      } catch (_) {
        _history = _loadLocalHistory(prefs);
      }
    } else {
      _history = _loadLocalHistory(prefs);
    }

    if (_weight > 0 && _height > 0) {
      _currentBMI = BMIUtils.calculateBMI(_weight, _height);
      _currentCategory = BMIUtils.getCategory(_currentBMI);
    }
    notifyListeners();
  }

  List<BmiRecord> _loadLocalHistory(SharedPreferences prefs) {
    try {
      final List<dynamic> list =
          jsonDecode(prefs.getString('bmi_history') ?? '[]');
      final records = list.map((e) => BmiRecord.fromJson(e)).toList();
      records.sort((a, b) => b.date.compareTo(a.date));
      return records;
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveLocalHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'bmi_history',
        jsonEncode(_history.map((r) => r.toJson()).toList()));
  }

  void setUserName(String n) {
    _userName = n;
    SharedPreferences.getInstance()
        .then((p) => p.setString('userName', n));
    notifyListeners();
  }

  void setBirthDate(DateTime d) {
    _birthDate = d;
    SharedPreferences.getInstance()
        .then((p) => p.setInt('birthDate', d.millisecondsSinceEpoch));
    notifyListeners();
  }

  void setGender(String g) {
    _gender = g;
    SharedPreferences.getInstance().then((p) => p.setString('gender', g));
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    SharedPreferences.getInstance()
        .then((p) => p.setBool('isDarkMode', _isDarkMode));
    notifyListeners();
  }

  void setUnitSystem(String u) {
    _unitSystem = u;
    SharedPreferences.getInstance()
        .then((p) => p.setString('unitSystem', u));
    notifyListeners();
  }

  void setWeight(double w) {
    _weight = w;
    SharedPreferences.getInstance().then((p) => p.setDouble('weight', w));
    notifyListeners();
  }

  void setHeight(double h) {
    _height = h;
    SharedPreferences.getInstance().then((p) => p.setDouble('height', h));
    notifyListeners();
  }

  void setSleepHours(double s) {
    _sleepHours = s;
    SharedPreferences.getInstance()
        .then((p) => p.setDouble('sleepHours', s));
    notifyListeners();
  }

  void setBpSystolic(double? v) { _bpSystolic = v; notifyListeners(); }
  void setBpDiastolic(double? v) { _bpDiastolic = v; notifyListeners(); }
  void setHeartRate(double? v) { _heartRate = v; notifyListeners(); }
  void setBloodSugar(double? v) { _bloodSugar = v; notifyListeners(); }

  void calculateBMI() {
    _currentBMI = BMIUtils.calculateBMI(_weight, _height);
    _currentCategory = BMIUtils.getCategory(_currentBMI);
    notifyListeners();
  }

  Future<void> saveBMIRecord() async {
    if (_currentBMI == 0) calculateBMI();
    final record = BmiRecord(
      id: const Uuid().v4(),
      bmi: _currentBMI,
      weight: _weight,
      height: _height,
      category: _currentCategory,
      date: DateTime.now(),
      gender: _gender,
      age: age,
      sleepHours: _sleepHours,
      bpSystolic: _bpSystolic,
      bpDiastolic: _bpDiastolic,
      heartRate: _heartRate,
      bloodSugar: _bloodSugar,
    );
    _history.insert(0, record);

    // Save to Firebase if logged in
    if (FirebaseService.isLoggedIn) {
      await FirebaseService.saveBMIRecord(record);
    }
    // Always save locally too
    await _saveLocalHistory();
    notifyListeners();
  }

  Future<void> deleteRecord(BmiRecord r) async {
    _history.removeWhere((e) => e.id == r.id);
    if (FirebaseService.isLoggedIn) {
      await FirebaseService.deleteBMIRecord(r.id);
    }
    await _saveLocalHistory();
    notifyListeners();
  }

  Future<void> clearHistory() async {
    _history.clear();
    if (FirebaseService.isLoggedIn) {
      await FirebaseService.clearAllRecords();
    }
    await _saveLocalHistory();
    notifyListeners();
  }

  // Reload from Firebase after login
  Future<void> reloadFromFirebase() async {
    if (!FirebaseService.isLoggedIn) return;
    try {
      _history = await FirebaseService.getBMIRecords();
      final fbName = FirebaseService.currentUser?.displayName ?? '';
      if (fbName.isNotEmpty) _userName = fbName;
      notifyListeners();
    } catch (_) {}
  }
}
