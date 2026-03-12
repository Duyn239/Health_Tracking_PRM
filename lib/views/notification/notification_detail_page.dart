import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/notification.dart';
import '../../viewmodels/login_vm.dart';
import '../../viewmodels/notification_vm.dart';
import '../chart/chart_page.dart';
import '../footer/main_footer.dart';
import '../header/main_header.dart';
import '../health_record/health_record_page.dart';
import '../home/home_page.dart';
import '../setting/settings_page.dart';
import 'notification_page.dart';

class NotificationDetailPage extends StatelessWidget {
  final AppNotification notification; // Nhận vào Model thay vì Map

  const NotificationDetailPage({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    // 1. Xác định giao diện dựa trên level của notification
    IconData iconData;
    Color themeColor;
    String statusLabel;

    switch (notification.level) {
      case "danger":
        iconData = Icons.dangerous;
        themeColor = Colors.red;
        statusLabel = "Nguy hiểm";
        break;
      case "warning":
        iconData = Icons.warning_amber_rounded;
        themeColor = const Color(0xFFEFB034);
        statusLabel = "Cần chú ý";
        break;
      default:
        iconData = Icons.check_circle;
        themeColor = const Color(0xFF20BD54);
        statusLabel = "Ổn định";
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: const MainHeader(subTitle: 'Chi tiết thông báo'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nút Quay về trang trước
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_back_ios,
                    color: Color(0xFF379AE6),
                    size: 14,
                  ),
                  SizedBox(width: 4),
                  Text(
                    "Quay về",
                    style: TextStyle(
                      color: Color(0xFF379AE6),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Ô Card căn giữa màn hình
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tiêu đề, Icon và Tag
                      Row(
                        children: [
                          Icon(iconData, color: themeColor, size: 28),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              notification.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: themeColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              statusLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Hiển thị thời gian thực từ Model
                      Text(
                        _formatDateTime(notification.createdAt),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Center(
                        child: Text(
                          "Nội dung phân tích",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF379AE6),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Nội dung chi tiết lấy từ Model content
                      Text(
                        notification.content,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF374151),
                          height: 1.6,
                        ),
                        textAlign: TextAlign.justify,
                      ),

                      const SizedBox(height: 32),

                      // Nút Xác nhận đã xem và Đánh dấu trong DB
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final loginVM = context.read<LoginViewModel>();
                            final notificationVM = context
                                .read<NotificationViewModel>();
                            final accountId = loginVM.currentAccount?.id;

                            // Gọi ViewModel để đánh dấu đã đọc VÀ truyền accountId để refresh Badge
                            if (notification.id != null && accountId != null) {
                              await notificationVM.markAsRead(
                                notification.id!,
                                accountId,
                              );
                            }

                            if (context.mounted) Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF379AE6),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "XÁC NHẬN ĐÃ XEM",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: MainFooter(
        currentIndex: 3,
        onTap: (index) {
          if (index == 3) return;
          _navigateTo(context, index);
        },
      ),
    );
  }

  String _formatDateTime(String isoString) {
    try {
      DateTime dt = DateTime.parse(isoString);
      return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return isoString;
    }
  }

  void _navigateTo(BuildContext context, int index) {
    Widget nextPage;
    switch (index) {
      case 0:
        nextPage = const HomePage();
        break;
      case 1:
        nextPage = const HealthRecordPage();
        break;
      case 2:
        nextPage = const ChartPage();
        break;
      case 3:
        nextPage = const NotificationPage();
        break;
      case 4:
        nextPage = const SettingsPage();
        break;
      default:
        nextPage = const HomePage();
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextPage),
    );
  }
}
