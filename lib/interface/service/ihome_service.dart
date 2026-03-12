import '../../data/models/health_tip.dart';

abstract class IHomeService {
  Future<Map<String, dynamic?>> getLatestHealthStats(int accountId);
  // Hàm mới: Xử lý logic tổng hợp để trả về danh sách Tip hoàn chỉnh
  Future<List<HealthTip>> getCalculatedTips(int accountId, Map<String, dynamic?> rawData);
}