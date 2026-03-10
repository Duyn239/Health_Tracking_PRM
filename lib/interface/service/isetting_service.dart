import '../../data/models/user_profile.dart';

abstract class ISettingService {
  /// Lấy Map các ngưỡng cảnh báo (Key: tên ngưỡng, Value: giá trị)
  Future<Map<String, double>> getAlertSettingsMap(int accountId);

  /// Cập nhật một ngưỡng cụ thể
  Future<bool> updateThreshold(int accountId, String key, double value);

  /// Khôi phục về ngưỡng mặc định theo logic y khoa
  Future<bool> resetToDefault(
    int accountId,
    UserProfile profile,
    List<int> diseaseIds,
  );
}
