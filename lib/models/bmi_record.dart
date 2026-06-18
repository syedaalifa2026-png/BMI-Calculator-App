// lib/models/bmi_record.dart
class BmiRecord {
  final String id;
  final double bmi;
  final double weight;
  final double height;
  final String category;
  final DateTime date;
  final String gender;
  final int age;
  final double sleepHours;
  final double? bpSystolic;
  final double? bpDiastolic;
  final double? heartRate;
  final double? bloodSugar;

  BmiRecord({
    required this.id, required this.bmi, required this.weight,
    required this.height, required this.category, required this.date,
    required this.gender, required this.age, required this.sleepHours,
    this.bpSystolic, this.bpDiastolic, this.heartRate, this.bloodSugar,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'bmi': bmi, 'weight': weight, 'height': height,
    'category': category, 'date': date.millisecondsSinceEpoch,
    'gender': gender, 'age': age, 'sleepHours': sleepHours,
    'bpSystolic': bpSystolic, 'bpDiastolic': bpDiastolic,
    'heartRate': heartRate, 'bloodSugar': bloodSugar,
  };

  factory BmiRecord.fromJson(Map<String, dynamic> json) => BmiRecord(
    id: json['id'], bmi: (json['bmi'] as num).toDouble(),
    weight: (json['weight'] as num).toDouble(),
    height: (json['height'] as num).toDouble(),
    category: json['category'],
    date: DateTime.fromMillisecondsSinceEpoch(json['date']),
    gender: json['gender'], age: json['age'],
    sleepHours: (json['sleepHours'] as num).toDouble(),
    bpSystolic: json['bpSystolic'] != null ? (json['bpSystolic'] as num).toDouble() : null,
    bpDiastolic: json['bpDiastolic'] != null ? (json['bpDiastolic'] as num).toDouble() : null,
    heartRate: json['heartRate'] != null ? (json['heartRate'] as num).toDouble() : null,
    bloodSugar: json['bloodSugar'] != null ? (json['bloodSugar'] as num).toDouble() : null,
  );
}
