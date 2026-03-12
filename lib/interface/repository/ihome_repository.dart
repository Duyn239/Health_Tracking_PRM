abstract class IHomeRepository {
  // Lấy bản ghi mới nhất của cả 4 loại chỉ số (Huyết áp, Đường huyết, Cân nặng, SpO2)
  Future<Map<String, dynamic?>> getLatestHealthStats(int accountId);

  Future<String> getTipContent(String type, String level);
}