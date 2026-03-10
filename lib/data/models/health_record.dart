class HealthRecord {
  final int? id;
  final int accountId;
  final String type; // 'Huyết Áp', 'Đường Huyết',...
  final double value1;
  final double? value2;
  final int? heartRate;
  final String unit;
  final String? note;
  final String measuredAt;

  HealthRecord({
    this.id,
    required this.accountId,
    required this.type,
    required this.value1,
    this.value2,
    this.heartRate,
    required this.unit,
    this.note,
    required this.measuredAt
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'account_id': accountId,
    'type': type,
    'value_1': value1,
    'value_2': value2,
    'heart_rate': heartRate,
    'unit': unit,
    'note': note,
    'measured_at': measuredAt,
  };

  factory HealthRecord.fromMap(Map<String, dynamic> map) => HealthRecord(
    id: map['id'] as int?,
    accountId: map['account_id'] as int,
    type: map['type'] as String,
    // Ép kiểu num sau đó toDouble để chấp nhận cả int và double từ DB
    value1: (map['value_1'] as num).toDouble(),
    value2: map['value_2'] != null ? (map['value_2'] as num).toDouble() : null,
    heartRate: map['heart_rate'] as int?,
    unit: map['unit'] as String,
    note: map['note'] as String?,
    measuredAt: map['measured_at'] as String,
  );
}