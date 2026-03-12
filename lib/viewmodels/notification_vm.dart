import 'package:flutter/material.dart';

import '../../interface/service/inotification_service.dart';
import '../data/models/notification.dart';

class NotificationViewModel extends ChangeNotifier {
  final INotificationService _notificationService;

  NotificationViewModel(this._notificationService);

  // 1. QUẢN LÝ DANH SÁCH & TRẠNG THÁI
  List<AppNotification> _notifications = [];
  List<AppNotification> get notifications => _notifications;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // 2. QUẢN LÝ SỐ LƯỢNG CHƯA ĐỌC (Badge)
  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  // Thông báo mới nhất vừa sinh ra sau khi đo
  AppNotification? _lastGeneratedNotification;
  AppNotification? get lastGeneratedNotification => _lastGeneratedNotification;

  /// 1. Lấy danh sách thông báo (có filter) và cập nhật Badge
  Future<void> fetchNotifications(
    int accountId, {
    String? level,
    String? type,
  }) async {
    _isLoading = true;
    notifyListeners();

    // Lấy danh sách filtered để hiển thị trên UI
    final results = await _notificationService.getFilteredNotifications(
      accountId,
      level: level,
      type: type,
    );
    _notifications = results.map((e) => AppNotification.fromMap(e)).toList();

    // Luôn làm mới số lượng chưa đọc dựa trên toàn bộ thông báo của user (không filter)
    await refreshUnreadCount(accountId);

    _isLoading = false;
    notifyListeners();
  }

  /// 2. Hàm chuyên biệt để refresh số lượng Badge
  /// Thường gọi sau khi thêm bản ghi mới hoặc vừa mở ứng dụng
  Future<void> refreshUnreadCount(int accountId) async {
    // Lấy toàn bộ thông báo để đếm chính xác số lượng chưa đọc (is_read = 0)
    final allNotifications = await _notificationService
        .getFilteredNotifications(accountId, level: 'all', type: 'all');

    _unreadCount = allNotifications.where((e) => e['is_read'] == 0).length;
    notifyListeners();
  }

  /// 3. Đánh dấu đã đọc và giảm số lượng Badge
  Future<void> markAsRead(int notificationId, int accountId) async {
    bool success = await _notificationService.markAsRead(notificationId);
    if (success) {
      // Cập nhật local state danh sách hiển thị
      int index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: 1);
      }

      // Refresh lại số Badge từ DB
      await refreshUnreadCount(accountId);
    }
  }

  /// 4. Lấy thông báo sau khi đo (Dùng để hiện Modal ngay sau khi Lưu)
  Future<AppNotification?> fetchNotificationAfterRecording(
    int recordId,
    int accountId,
  ) async {
    final result = await _notificationService.getResultAfterRecording(recordId);

    if (result != null) {
      _lastGeneratedNotification = AppNotification.fromMap(result);

      // Vì có thông báo mới sinh ra -> Phải tăng số Badge
      await refreshUnreadCount(accountId);

      return _lastGeneratedNotification;
    }
    return null;
  }

  /// 5. Dọn dẹp thông báo đã xem
  Future<bool> clearReadNotifications(
    int accountId, {
    String? level,
    String? type,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // 1. Thực hiện xóa trong Database
      bool success = await _notificationService.deleteReadNotifications(
        accountId,
      );

      if (success) {
        // 2. Load lại dữ liệu để đồng bộ UI và Badge
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

// Extension nhỏ để copyWith nhanh hơn (nếu model của bạn chưa có)
extension AppNotificationExtension on AppNotification {
  AppNotification copyWith({int? isRead}) {
    return AppNotification(
      id: id,
      recordId: recordId,
      title: title,
      content: content,
      level: level,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}
