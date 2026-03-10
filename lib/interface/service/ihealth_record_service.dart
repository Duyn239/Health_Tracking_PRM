import '../../data/models/user_profile.dart';

abstract class IHealthRecordService {
  // 1. Kiểm tra xem user đã hoàn thành thông tin cơ bản chưa
  Future<bool> isBasicInfoCompleted(int accountId);

  // 2. Lưu thông tin Profile và Bệnh lý ban đầu
  Future<bool> saveBasicHealthInfo({
    required int accountId,
    required UserProfile profile,
    required List<int> diseaseIds,
  });

  // 3. THÊM MỚI: Lấy danh sách bản ghi theo loại (Huyết áp, Đường huyết...)
  Future<List<Map<String, dynamic>>> getRecordsByType(
      int accountId,
      String type,
      {bool descending = true}
      );
}