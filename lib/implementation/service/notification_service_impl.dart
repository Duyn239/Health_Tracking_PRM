import '../../interface/repository/inotification_repository.dart';
import '../../interface/service/inotification_service.dart';

class NotificationService implements INotificationService {
  final INotificationRepository _notificationRepo;

  NotificationService(this._notificationRepo);

  @override
  Future<List<Map<String, dynamic>>> getFilteredNotifications(
    int accountId, {
    String? level,
    String? type,
  }) async {
    try {
      return await _notificationRepo.getFilteredNotifications(
        accountId,
        level: level,
        type: type,
      );
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> markAsRead(int notificationId) async {
    try {
      int result = await _notificationRepo.markAsRead(notificationId);
      return result > 0;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>?> getResultAfterRecording(int recordId) async {
    try {
      // Service gọi Repo để lấy Notification tương ứng với bản ghi vừa tạo
      return await _notificationRepo.getNotificationByRecordId(recordId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> deleteReadNotifications(int accountId) async {
    try {
      int result = await _notificationRepo.deleteReadNotifications(accountId);
      return result >= 0; // Trả về true nếu thực thi thành công (dù có bản ghi bị xóa hay không)
    } catch (e) {
      return false;
    }
  }
}
