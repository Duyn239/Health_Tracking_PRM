abstract class INotificationService {
  Future<List<Map<String, dynamic>>> getFilteredNotifications(
      int accountId, {String? level, String? type});

  Future<bool> markAsRead(int notificationId);

  Future<Map<String, dynamic>?> getResultAfterRecording(int recordId);

  // Thêm hàm xóa thông báo đã đọc
  Future<bool> deleteReadNotifications(int accountId);
}