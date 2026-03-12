import 'package:flutter/material.dart';
import '../../interface/service/inotification_service.dart';
import '../data/models/notification.dart';

class NotificationViewModel extends ChangeNotifier {
  final INotificationService _notificationService;

  NotificationViewModel(this._notificationService);

  // Danh sách thông báo (Dùng cho màn hình danh sách thông báo)
  List<AppNotification> _notifications = [];
  List<AppNotification> get notifications => _notifications;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Thông báo mới nhất vừa sinh ra sau khi đo
  AppNotification? _lastGeneratedNotification;
  AppNotification? get lastGeneratedNotification => _lastGeneratedNotification;

  /// 1. Lấy danh sách thông báo (có filter)
  Future<void> fetchNotifications(int accountId, {String? level, String? type}) async {
    _isLoading = true;
    notifyListeners();

    final results = await _notificationService.getFilteredNotifications(
      accountId,
      level: level,
      type: type,
    );

    _notifications = results.map((e) => AppNotification.fromMap(e)).toList();

    _isLoading = false;
    notifyListeners();
  }

  /// 2. Đánh dấu đã đọc
  Future<void> markAsRead(int notificationId) async {
    bool success = await _notificationService.markAsRead(notificationId);
    if (success) {
      // Cập nhật local state để UI thay đổi ngay lập tức
      int index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = AppNotification(
          id: _notifications[index].id,
          recordId: _notifications[index].recordId,
          title: _notifications[index].title,
          content: _notifications[index].content,
          level: _notifications[index].level,
          isRead: 1,
          createdAt: _notifications[index].createdAt,
        );
        notifyListeners();
      }
    }
  }

  /// 3. Lấy thông báo sau khi đo (Mấu chốt của bạn)
  Future<AppNotification?> fetchNotificationAfterRecording(int recordId) async {
    final result = await _notificationService.getResultAfterRecording(recordId);

    if (result != null) {
      _lastGeneratedNotification = AppNotification.fromMap(result);
      notifyListeners();
      return _lastGeneratedNotification;
    }
    return null;
  }

  Future<bool> clearReadNotifications(int accountId, {String? level, String? type}) async {
    try {
      _isLoading = true;
      notifyListeners();

      // 1. Thực hiện xóa trong Database thông qua Service
      bool success = await _notificationService.deleteReadNotifications(accountId);

      if (success) {
        // 2. Load lại dữ liệu mới nhất từ DB để đồng bộ danh sách hiển thị
        // Truyền lại level và type để đảm bảo người dùng đang lọc gì thì vẫn hiện cái đó
        await fetchNotifications(accountId, level: level, type: type);
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      debugPrint("Error clearing notifications: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}