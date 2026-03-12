import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../interface/service/ihealth_record_service.dart';
import '../interface/service/isetting_service.dart';

class ChartViewModel extends ChangeNotifier {
  final IHealthRecordService _service;
  final ISettingService _settingService;

  ChartViewModel(this._service, this._settingService);

  // ─── States ───────────────────────────────────────────────────────────────

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isWeekly = true;
  bool get isWeekly => _isWeekly;

  String _selectedMetric = 'Huyết áp';
  String get selectedMetric => _selectedMetric;

  // Spots cho đường biểu đồ
  List<FlSpot> _primarySpots = [];
  List<FlSpot> get primarySpots => _primarySpots;

  List<FlSpot> _secondarySpots = [];
  List<FlSpot> get secondarySpots => _secondarySpots;

  // Nhãn trục X
  List<String> _xLabels = [];
  List<String> get xLabels => _xLabels;

  // Phạm vi trục Y
  double _minY = 0;
  double get minY => _minY;

  double _maxY = 200;
  double get maxY => _maxY;

  int _totalDays = 7;
  int get totalDays => _totalDays;

  bool get hasData => _primarySpots.isNotEmpty;

  // ─── Giá trị gần nhất (theo thời gian đo thực tế) ────────────────────────
  double? _latestPrimary;
  double? get latestPrimary => _latestPrimary;

  double? _latestSecondary;
  double? get latestSecondary => _latestSecondary;

  String? _latestMeasuredAt; // Lưu thời điểm đo gần nhất để hiển thị nếu cần
  String? get latestMeasuredAt => _latestMeasuredAt;

  // ─── Giá trị trung bình ───────────────────────────────────────────────────
  double? _avgPrimary;
  double? get avgPrimary => _avgPrimary;

  double? _avgSecondary;
  double? get avgSecondary => _avgSecondary;

  // ─── Ngưỡng cảnh báo (dùng để vẽ đường ngang trên biểu đồ) ──────────────
  // Huyết áp
  double? _sysMax;
  double? get sysMax => _sysMax;

  double? _sysMin;
  double? get sysMin => _sysMin;

  double? _diaMax;
  double? get diaMax => _diaMax;

  double? _diaMin;
  double? get diaMin => _diaMin;

  // Đường huyết
  double? _gluMax;
  double? get gluMax => _gluMax;

  double? _gluMin;
  double? get gluMin => _gluMin;

  // SpO2
  double? _spo2Min;
  double? get spo2Min => _spo2Min;

  // Cân nặng
  double? _weightMax;
  double? get weightMax => _weightMax;

  double? _weightMin;
  double? get weightMin => _weightMin;

  // Đơn vị theo loại chỉ số
  String get unit {
    switch (_selectedMetric) {
      case 'Huyết áp':    return 'mmHg';
      case 'Đường huyết': return 'mg/dL';
      case 'Cân nặng':    return 'kg';
      case 'SpO2':        return '%';
      default:            return '';
    }
  }

  // ─── Actions ──────────────────────────────────────────────────────────────

  void setMetric(String metric) {
    if (_selectedMetric == metric) return;
    _selectedMetric = metric;
    notifyListeners();
  }

  void setPeriod({required bool weekly}) {
    if (_isWeekly == weekly) return;
    _isWeekly = weekly;
    notifyListeners();
  }

  Future<void> fetchChartData(int accountId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Tải song song: dữ liệu bản ghi + ngưỡng cảnh báo
      final results = await Future.wait([
        _service.getRecordsByType(accountId, _selectedMetric, descending: false),
        _settingService.getAlertSettingsMap(accountId),
      ]);

      final records = results[0] as List<Map<String, dynamic>>;
      final thresholds = results[1] as Map<String, double>;

      // Cập nhật ngưỡng cảnh báo
      _updateThresholds(thresholds);

      // Xử lý dữ liệu biểu đồ
      final bool hasTwoValues = _selectedMetric == 'Huyết áp';
      _processData(
        records,
        valueKey: 'value_1',
        secondaryKey: hasTwoValues ? 'value_2' : null,
      );
    } catch (e) {
      debugPrint('ChartViewModel fetchChartData lỗi: $e');
      _resetData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Cập nhật ngưỡng cảnh báo từ alert_settings ──────────────────────────

  void _updateThresholds(Map<String, double> t) {
    _sysMax  = t['sys_max'];
    _sysMin  = t['sys_min'];
    _diaMax  = t['dia_max'];
    _diaMin  = t['dia_min'];
    _gluMax  = t['glu_max'];
    _gluMin  = t['glu_min'];
    _spo2Min    = t['spo2_min'];
    _weightMax  = t['weight_max'];
    _weightMin  = t['weight_min'];
  }

  // ─── Xử lý dữ liệu bản ghi ───────────────────────────────────────────────

  void _processData(
      List<Map<String, dynamic>> records, {
        required String valueKey,
        String? secondaryKey,
      }) {
    if (records.isEmpty) {
      _resetData();
      return;
    }

    // ── Lấy bản ghi GẦN NHẤT theo measured_at thực tế ──────────────────────
    // Records được lấy ASC, nên bản ghi cuối là mới nhất
    final latestRecord = records.last;
    _latestPrimary = (latestRecord[valueKey] as num?)?.toDouble();
    _latestMeasuredAt = latestRecord['measured_at'] as String?;

    if (secondaryKey != null && latestRecord[secondaryKey] != null) {
      _latestSecondary = (latestRecord[secondaryKey] as num).toDouble();
    } else {
      _latestSecondary = null;
    }

    // ── Nhóm bản ghi theo ngày để vẽ biểu đồ ───────────────────────────────
    final now = DateTime.now();
    final grouped = <int, List<Map<String, dynamic>>>{};

    if (_isWeekly) {
      final weekStart = _startOfWeek(now);
      _xLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
      _totalDays = 7;

      for (final r in records) {
        final dt = _parseDate(r['measured_at']);
        if (dt == null) continue;
        final diff = DateTime(dt.year, dt.month, dt.day)
            .difference(weekStart)
            .inDays;
        if (diff >= 0 && diff < 7) {
          grouped.putIfAbsent(diff, () => []).add(r);
        }
      }
    } else {
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      _xLabels = List.generate(daysInMonth, (i) => '${i + 1}');
      _totalDays = daysInMonth;

      for (final r in records) {
        final dt = _parseDate(r['measured_at']);
        if (dt == null) continue;
        if (dt.year == now.year && dt.month == now.month) {
          grouped.putIfAbsent(dt.day - 1, () => []).add(r);
        }
      }
    }

    _buildSpots(grouped, _totalDays, valueKey, secondaryKey);
  }

  void _buildSpots(
      Map<int, List<Map<String, dynamic>>> grouped,
      int totalDays,
      String valueKey,
      String? secondaryKey,
      ) {
    _primarySpots   = [];
    _secondarySpots = [];

    double minVal = double.infinity;
    double maxVal = double.negativeInfinity;
    final allPrimary   = <double>[];
    final allSecondary = <double>[];

    for (int i = 0; i < totalDays; i++) {
      final dayRecords = grouped[i];
      if (dayRecords == null || dayRecords.isEmpty) continue;

      // Trung bình giá trị chính trong ngày
      final primaryValues = dayRecords
          .map((r) => (r[valueKey] as num).toDouble())
          .toList();
      final primaryAvg = _average(primaryValues);
      _primarySpots.add(FlSpot(i.toDouble(), _round(primaryAvg)));
      allPrimary.add(primaryAvg);
      if (primaryAvg < minVal) minVal = primaryAvg;
      if (primaryAvg > maxVal) maxVal = primaryAvg;

      // Trung bình giá trị phụ trong ngày (chỉ Huyết áp)
      if (secondaryKey != null) {
        final secValues = dayRecords
            .where((r) => r[secondaryKey] != null)
            .map((r) => (r[secondaryKey] as num).toDouble())
            .toList();
        if (secValues.isNotEmpty) {
          final secAvg = _average(secValues);
          _secondarySpots.add(FlSpot(i.toDouble(), _round(secAvg)));
          allSecondary.add(secAvg);
          if (secAvg < minVal) minVal = secAvg;
          if (secAvg > maxVal) maxVal = secAvg;
        }
      }
    }

    // Thống kê trung bình toàn kỳ
    _avgPrimary   = allPrimary.isNotEmpty   ? _round(_average(allPrimary))   : null;
    _avgSecondary = allSecondary.isNotEmpty ? _round(_average(allSecondary)) : null;

    // Phạm vi trục Y: bao gồm cả ngưỡng cảnh báo để đường không bị cắt
    final thresholdValues = _getThresholdValues();
    for (final v in thresholdValues) {
      if (v < minVal) minVal = v;
      if (v > maxVal) maxVal = v;
    }

    if (minVal != double.infinity) {
      final pad = _yPadding();
      _minY = (minVal - pad).clamp(0.0, double.infinity);
      _maxY = maxVal + pad;
    } else {
      _setDefaultYRange();
    }
  }

  /// Lấy tất cả giá trị ngưỡng liên quan đến chỉ số đang xem
  List<double> _getThresholdValues() {
    switch (_selectedMetric) {
      case 'Huyết áp':
        return [
          if (_sysMax != null) _sysMax!,
          if (_sysMin != null) _sysMin!,
          if (_diaMax != null) _diaMax!,
          if (_diaMin != null) _diaMin!,
        ];
      case 'Đường huyết':
        return [
          if (_gluMax != null) _gluMax!,
          if (_gluMin != null) _gluMin!,
        ];
      case 'SpO2':
        return [if (_spo2Min != null) _spo2Min!];
      case 'Cân nặng':
        return [
          if (_weightMax != null) _weightMax!,
          if (_weightMin != null) _weightMin!,
        ];
      default:
        return [];
    }
  }

  double _yPadding() {
    switch (_selectedMetric) {
      case 'Huyết áp':    return 15.0;
      case 'Đường huyết': return 20.0;
      case 'Cân nặng':    return 3.0;
      case 'SpO2':        return 2.0;
      default:            return 10.0;
    }
  }

  void _setDefaultYRange() {
    switch (_selectedMetric) {
      case 'Huyết áp':    _minY = 40;  _maxY = 200; break;
      case 'Đường huyết': _minY = 40;  _maxY = 300; break;
      case 'Cân nặng':    _minY = 30;  _maxY = 150; break;
      case 'SpO2':        _minY = 85;  _maxY = 100; break;
    }
  }

  void _resetData() {
    _primarySpots    = [];
    _secondarySpots  = [];
    _xLabels         = [];
    _latestPrimary   = null;
    _latestSecondary = null;
    _latestMeasuredAt = null;
    _avgPrimary      = null;
    _avgSecondary    = null;
    _setDefaultYRange();
  }

  DateTime _startOfWeek(DateTime now) {
    final start = now.subtract(Duration(days: now.weekday - 1));
    return DateTime(start.year, start.month, start.day);
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  double _average(List<double> values) =>
      values.reduce((a, b) => a + b) / values.length;

  double _round(double value) =>
      double.parse(value.toStringAsFixed(1));

  void clearData() {
    _resetData();
    _isLoading      = false;
    _isWeekly       = true;
    _selectedMetric = 'Huyết áp';
    // Reset ngưỡng
    _sysMax = _sysMin = _diaMax = _diaMin = null;
    _gluMax = _gluMin = null;
    _spo2Min   = null;
    _weightMax = null;
    _weightMin = null;
    notifyListeners();
  }
}