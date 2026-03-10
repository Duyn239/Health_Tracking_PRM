abstract class IHomeRepository {
  // Sau này dùng để lấy các chỉ số sức khỏe từ bảng khác
  Future<List<Map<String, dynamic>>> getLatestStats(int accountId);
}