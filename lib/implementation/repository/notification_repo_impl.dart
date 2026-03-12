import '../../data/database/database_helper.dart';
import '../../interface/repository/inotification_repository.dart';

class NotificationRepository implements INotificationRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<List<Map<String, dynamic>>> getFilteredNotifications(
      int accountId, {String? level, String? type}
      ) async {
    return await _dbHelper.getFilteredNotifications(accountId, level: level, type: type);
  }

  @override
  Future<int> markAsRead(int notificationId) async {
    return await _dbHelper.markAsRead(notificationId);
  }

  // Triển khai hàm lấy thông báo theo Record ID
  @override
  Future<Map<String, dynamic>?> getNotificationByRecordId(int recordId) async {
    return await _dbHelper.getNotificationByRecordId(recordId);
  }

  @override
  Future<int> deleteReadNotifications(int accountId) async {
    return await _dbHelper.deleteReadNotifications(accountId);
  }
}