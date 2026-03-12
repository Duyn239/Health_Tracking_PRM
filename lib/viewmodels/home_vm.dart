import 'package:flutter/cupertino.dart';

import '../data/models/health_record.dart';
import '../data/models/health_tip.dart';
import '../interface/service/ihome_service.dart';

class HomeViewModel extends ChangeNotifier {
  final IHomeService _homeService;
  HomeViewModel(this._homeService);

  String _userName = "Người dùng";
  String get userName => _userName;

  List<HealthRecord> _latestRecords = [];
  List<HealthRecord> get latestRecords => _latestRecords;

  List<HealthTip> _displayTips = [];
  List<HealthTip> get displayTips => _displayTips;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchLatestHealthData(int accountId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Gọi Service lấy dữ liệu thô
      final rawData = await _homeService.getLatestHealthStats(accountId);

      // 2. Chuyển đổi thô sang Model Records (Để hiển thị MenuCard)
      _latestRecords = rawData.values
          .where((data) => data != null)
          .map((data) => HealthRecord.fromMap(data as Map<String, dynamic>))
          .toList();

      // 3. Gọi Service xử lý logic Tip (Để hiển thị HealthTipCard)
      // Toàn bộ logic level và content tip đã nằm trong Service
      _displayTips = await _homeService.getCalculatedTips(accountId, rawData);

    } catch (e) {
      debugPrint("Lỗi HomeViewModel: $e");
      _latestRecords = [];
      _displayTips = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  HealthRecord? getRecordByType(String type) {
    try {
      return _latestRecords.firstWhere((r) => r.type == type);
    } catch (e) {
      return null;
    }
  }

  void setUserName(String? name) {
    if (name != null && name.isNotEmpty) {
      _userName = name;
      notifyListeners();
    }
  }
}