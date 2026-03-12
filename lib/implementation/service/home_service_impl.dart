import 'package:flutter/cupertino.dart';

import '../../data/database/database_helper.dart';
import '../../data/models/health_record.dart';
import '../../data/models/health_tip.dart';
import '../../interface/repository/ihome_repository.dart';
import '../../interface/service/ihome_service.dart';

class HomeService implements IHomeService {
  final IHomeRepository _homeRepo;
  HomeService(this._homeRepo);

  @override
  Future<Map<String, dynamic?>> getLatestHealthStats(int accountId) async {
    try {
      return await _homeRepo.getLatestHealthStats(accountId);
    } catch (e) {
      return {};
    }
  }

  @override
  Future<List<HealthTip>> getCalculatedTips(int accountId, Map<String, dynamic?> rawData) async {
    List<HealthTip> calculatedTips = [];

    try {
      // 1. Lấy ngưỡng cài đặt từ Repository/DB
      final List<Map<String, dynamic>> settings = await DatabaseHelper.instance.getAlertSettings(accountId);
      Map<String, double> thresholds = {
        for (var item in settings) item['key_name'] as String: item['value'] as double
      };

      // 2. Duyệt qua các bản ghi thô
      for (var entry in rawData.values) {
        if (entry == null) continue;

        final record = HealthRecord.fromMap(entry as Map<String, dynamic>);

        // 3. Xác định Level (Logic nghiệp vụ nằm tại Service)
        String level = _determineLevel(record, thresholds);

        // 4. Lấy nội dung Tip từ Repo
        String content = await _homeRepo.getTipContent(record.type, level);

        calculatedTips.add(HealthTip(
          type: record.type,
          level: level,
          content: content,
        ));
      }
    } catch (e) {
      debugPrint("Lỗi tại HomeService (getCalculatedTips): $e");
    }

    return calculatedTips;
  }

  // Logic xác định Level được chuyển hoàn toàn sang Service
  String _determineLevel(HealthRecord record, Map<String, double> thresholds) {
    double v1 = record.value1;
    double? v2 = record.value2;

    switch (record.type) {
      case 'Huyết áp':
        double sMax = thresholds['sys_max'] ?? 135;
        double dMax = thresholds['dia_max'] ?? 85;
        if (v1 >= sMax + 20 || (v2 != null && v2 >= dMax + 15)) return 'danger';
        if (v1 > sMax || (v2 != null && v2 > dMax) || v1 < 90) return 'warning';
        return 'stable';
      case 'Đường huyết':
        double gMax = thresholds['glu_max'] ?? 126;
        double gMin = thresholds['glu_min'] ?? 70;
        if (v1 > gMax + 50 || v1 < gMin - 10) return 'danger';
        if (v1 > gMax || v1 < gMin) return 'warning';
        return 'stable';
      case 'SpO2':
        if (v1 < 90) return 'danger';
        if (v1 < (thresholds['spo2_min'] ?? 95)) return 'warning';
        return 'stable';
      default: // Cân nặng
        double wMax = thresholds['weight_max'] ?? 80;
        double wMin = thresholds['weight_min'] ?? 45;
        if (v1 > wMax + 10 || v1 < wMin - 5) return 'danger';
        return (v1 > wMax || v1 < wMin) ? 'warning' : 'stable';
    }
  }
}