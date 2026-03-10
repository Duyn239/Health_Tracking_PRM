import '../../data/models/user_profile.dart';

abstract class IProfileRepository {
  // Cập nhật profile, bệnh nền và khởi tạo ngưỡng mặc định
  Future<int> updateInitialProfile({
    required int accountId,
    required UserProfile profile,
    required List<int> diseaseIds,
  });

  // Lấy thông tin hồ sơ cá nhân
  Future<Map<String, dynamic>?> getProfile(int accountId);

  /// Lấy danh sách TÊN các loại bệnh nền của người dùng (Dùng để hiển thị lên Profile)
  Future<List<String>> getDiseasesByAccountId(int accountId);
}