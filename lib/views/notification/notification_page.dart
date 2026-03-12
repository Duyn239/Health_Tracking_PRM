import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/login_vm.dart';
import '../../viewmodels/notification_vm.dart';
import '../chart/chart_page.dart';
import '../header/main_header.dart';
import '../footer/main_footer.dart';
import '../health_record/health_record_page.dart';
import '../home/home_page.dart';
import '../setting/settings_page.dart';
import 'filter_item.dart';
import 'notification_card.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final Map<String, String> statusMap = {
    "Tất cả": "all",
    "Ổn định": "stable",
    "Cần chú ý": "warning",
    "Nguy hiểm": "danger"
  };

  String selectedStatus = "Tất cả";
  String selectedMetric = "Tất cả";
  final List<String> metrics = ["Tất cả", "Huyết áp", "Đường huyết", "SpO2", "Cân nặng"];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchNotifications());
  }

  void _fetchNotifications() {
    final loginVM = context.read<LoginViewModel>();
    final notificationVM = context.read<NotificationViewModel>();
    final accountId = loginVM.currentAccount?.id;

    if (accountId != null) {
      notificationVM.fetchNotifications(
        accountId,
        level: statusMap[selectedStatus],
        type: selectedMetric == "Tất cả" ? "all" : selectedMetric,
      );
    }
  }

  // Hàm hiển thị Dialog xác nhận xóa
  void _showDeleteConfirmDialog(int accountId) {
    // 1. Lưu lại các instance và giá trị filter hiện tại trước khi vào Dialog
    final notificationVM = context.read<NotificationViewModel>();
    final messenger = ScaffoldMessenger.of(context);

    // Lấy giá trị filter thực tế từ statusMap và dropdown
    final String currentLevel = statusMap[selectedStatus] ?? 'all';
    final String currentType = selectedMetric == "Tất cả" ? "all" : selectedMetric;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Center(
          child: Text(
            "Xóa thông báo",
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        content: const Text(
          "Bạn có chắc chắn muốn xóa tất cả các thông báo đã xem không? Hành động này không thể hoàn tác.",
          textAlign: TextAlign.left,
          style: TextStyle(color: Color(0xFF4B5563), fontSize: 15),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        actions: [
          Row(
            children: [
              // Nút Hủy - Bo tròn, nền xám
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE5E7EB),
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Hủy", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              // Nút Xóa - Bo tròn, nền đỏ
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    // Đóng dialog trước
                    Navigator.pop(dialogContext);

                    // Gọi xóa và truyền kèm filter để danh sách sau khi load lại không bị nhảy
                    final success = await notificationVM.clearReadNotifications(
                      accountId,
                      level: currentLevel,
                      type: currentType,
                    );

                    if (success) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.white, size: 20),
                              SizedBox(width: 10),
                              Text("Đã dọn dẹp các thông báo đã xem"),
                            ],
                          ),
                          backgroundColor: const Color(0xFF20BD54),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          margin: const EdgeInsets.all(15),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Xóa", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notificationVM = context.watch<NotificationViewModel>();
    final displayData = notificationVM.notifications;
    final isLoading = notificationVM.isLoading;
    final loginVM = context.read<LoginViewModel>();

    // Kiểm tra xem có thông báo nào đã đọc để hiển thị nút xóa không
    bool hasReadNotifications = displayData.any((n) => n.isRead == 1);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: const MainHeader(subTitle: 'Thông cáo kết quả'),
      body: Column(
        children: [
          // --- 1. Nhóm Filter Trạng thái ---
          Container(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: statusMap.keys.map((label) => FilterItem(
                label: label,
                isSelected: selectedStatus == label,
                onTap: () {
                  setState(() => selectedStatus = label);
                  _fetchNotifications();
                },
              )).toList(),
            ),
          ),

          // --- 2. Dropdown và Nút Dọn dẹp ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      isLoading ? "Đang tải..." : "Hiển thị: ${displayData.length} thông báo",
                      style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 8),
                    // Nút dọn dẹp thông báo đã xem
                    if (hasReadNotifications && !isLoading)
                      GestureDetector(
                        onTap: () => _showDeleteConfirmDialog(loginVM.currentAccount!.id!),
                        child: const Tooltip(
                          message: "Xóa thông báo đã xem",
                          child: Icon(Icons.delete_sweep_outlined, size: 20, color: Colors.redAccent),
                        ),
                      ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      dropdownColor: Colors.white,
                      value: selectedMetric,
                      icon: const Icon(Icons.filter_list, size: 16, color: Colors.blue),
                      style: const TextStyle(color: Colors.blue, fontSize: 13, fontWeight: FontWeight.bold),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() => selectedMetric = newValue);
                          _fetchNotifications();
                        }
                      },
                      items: metrics.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // --- 3. Danh sách thông báo ---
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : displayData.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: displayData.length,
              itemBuilder: (context, index) => NotificationCard(
                notification: displayData[index],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: MainFooter(
        currentIndex: 3,
        onTap: (index) {
          if (index == 3) return;
          _navigateTo(index);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text("Không có thông báo nào phù hợp",
              style: TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  void _navigateTo(int index) {
    Widget nextPage;
    switch (index) {
      case 0: nextPage = const HomePage(); break;
      case 1: nextPage = const HealthRecordPage(); break;
      case 2: nextPage = const ChartPage(); break;
      case 4: nextPage = const SettingsPage(); break;
      default: nextPage = const HomePage();
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => nextPage));
  }
}