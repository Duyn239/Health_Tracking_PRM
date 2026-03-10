abstract class ISettingRepository {
  Future<List<Map<String, dynamic>>> getAlertSettings(int accountId);
  Future<int> updateAlertSetting(int accountId, String keyName, double newValue);

  // Hàm mới để phục vụ logic reset
  Future<int> resetThresholdsToDefault(
      int accountId,
      Map<String, dynamic> profileData,
      List<int> diseaseIds
      );
}