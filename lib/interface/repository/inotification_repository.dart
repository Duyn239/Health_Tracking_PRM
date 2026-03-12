abstract class INotificationRepository {
  Future<List<Map<String, dynamic>>> getFilteredNotifications(
      int accountId, {String? level, String? type});

  Future<int> markAsRead(int notificationId);

  Future<Map<String, dynamic>?> getNotificationByRecordId(int recordId);

  // Thêm hàm xóa thông báo đã đọc
  Future<int> deleteReadNotifications(int accountId);
}