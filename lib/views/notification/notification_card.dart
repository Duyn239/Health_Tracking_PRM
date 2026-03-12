import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/notification.dart';
import '../../viewmodels/notification_vm.dart';
import 'notification_detail_page.dart';

class NotificationCard extends StatelessWidget {
  final AppNotification notification;

  const NotificationCard({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color iconColor;
    Color tagColor;
    Color tagTextColor = Colors.white;
    String statusText;

    // Logic mapping UI dựa trên level từ Database
    switch (notification.level) {
      case "danger":
        iconData = Icons.dangerous;
        iconColor = Colors.red;
        tagColor = const Color(0xFFDE3B40);
        statusText = "Nguy hiểm";
        break;
      case "warning":
        iconData = Icons.warning_amber_rounded;
        iconColor = const Color(0xFFEFB034);
        tagColor = const Color(0xFFEFB034);
        tagTextColor = Colors.black;
        statusText = "Cần chú ý";
        break;
      default: // stable
        iconData = Icons.check_circle;
        iconColor = const Color(0xFF20BD54);
        tagColor = const Color(0xFF20BD54);
        statusText = "Ổn định";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(iconData, color: iconColor, size: 23),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  notification.title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: tagColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(color: tagTextColor, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            notification.content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, color: Color(0xFF4B5563), height: 1.5),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Format lại thời gian (Ví dụ: 2026-01-30T22:32:00 -> 22:32 30/01/2026)
              Text(
                  _formatDateTime(notification.createdAt),
                  style: const TextStyle(fontSize: 12, color: Colors.grey)
              ),
              Row(
                children: [
                  Icon(
                    notification.isRead == 1 ? Icons.visibility : Icons.visibility_off,
                    size: 16,
                    color: const Color(0xFF565D6D),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    notification.isRead == 1 ? "Đã xem" : "Chưa xem",
                    style: const TextStyle(fontSize: 13, color: Color(0xFF565D6D)),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotificationDetailPage(notification: notification),
                        ),
                      );
                    },
                    child: _buildDetailButton(),
                  ),
                ],
              ),
            ],
          ),
        ],
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

  Widget _buildDetailButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        "Xem chi tiết",
        style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }
}