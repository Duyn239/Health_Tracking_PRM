import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/notification_vm.dart';

class MainFooter extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const MainFooter({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Lấy số lượng chưa đọc từ ViewModel
    final unreadCount = context.watch<NotificationViewModel>().unreadCount;

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF379AE6),
      unselectedItemColor: const Color(0xFF565D6D),
      currentIndex: currentIndex,
      onTap: onTap,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Trang chủ',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.favorite_outline),
          label: 'Chỉ số',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: 'Biểu đồ',
        ),

        // Icon Thông báo với số đỏ
        BottomNavigationBarItem(
          icon: Badge(
            label: Text(unreadCount.toString()),
            isLabelVisible:
                unreadCount > 0, // Chỉ hiện khi có thông báo chưa đọc
            backgroundColor: Colors.red,
            child: const Icon(Icons.notifications_none),
          ),
          label: 'Thông báo',
        ),

        const BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          label: 'Cài đặt',
        ),
      ],
    );
  }
}
