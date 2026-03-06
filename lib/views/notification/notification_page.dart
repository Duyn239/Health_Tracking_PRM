import 'package:flutter/material.dart';
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
  String selectedStatus = "Tất cả";
  String selectedMetric = "Tất cả";

  final List<String> metrics = ["Tất cả", "Huyết áp", "Đường huyết", "SpO2", "Cân nặng"];

  final List<Map<String, dynamic>> fakeData = [
    {
      "title": "Huyết áp cao",
      "content": "Huyết áp tâm thu của bạn đã vượt ngưỡng: 141/74 mmHg.",
      "type": "Nguy hiểm",
      "metric": "Huyết áp",
      "time": "22:32 30/01/2026",
      "isRead": true,
    },
    {
      "title": "Nồng độ oxy thấp",
      "content": "Chỉ số SpO2 đạt 92%. Hãy chú ý nghỉ ngơi.",
      "type": "Cần chú ý",
      "metric": "SpO2",
      "time": "20:15 30/01/2026",
      "isRead": true,
    },
    {
      "title": "Đường huyết ổn định",
      "content": "Chỉ số đường huyết sáng nay rất tốt: 95 mg/dL.",
      "type": "Ổn định",
      "metric": "Đường huyết",
      "time": "07:30 30/01/2026",
      "isRead": false,
    },
    {
      "title": "Cân nặng",
      "content": "Chỉ số đường huyết sáng nay rất tốt: 95 mg/dL.",
      "type": "Ổn định",
      "metric": "Cân nặng",
      "time": "07:30 30/01/2026",
      "isRead": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Logic lọc dữ liệu kép
    final displayData = fakeData.where((item) {
      final matchStatus = selectedStatus == "Tất cả" || item["type"] == selectedStatus;
      final matchMetric = selectedMetric == "Tất cả" || item["metric"] == selectedMetric;
      return matchStatus && matchMetric;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: const MainHeader(subTitle: 'Thông cáo kết quả'),
      body: Column(
        children: [
          // --- 1. Nhóm Filter Trạng thái (Giữ nguyên dạng nút bấm) ---
          Container(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ["Tất cả", "Ổn định", "Cần chú ý", "Nguy hiểm"]
                  .map((label) => FilterItem(
                label: label,
                isSelected: selectedStatus == label,
                onTap: () => setState(() => selectedStatus = label),
              ))
                  .toList(),
            ),
          ),

          // --- 2. Dropdown nhỏ chọn Chỉ số (Đặt ở dưới) ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Hiển thị: ${displayData.length} thông báo",
                  style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
                // Dropdown nhỏ gọn
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
                        setState(() => selectedMetric = newValue!);
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
            child: displayData.isEmpty
                ? const Center(child: Text("Không có dữ liệu phù hợp"))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: displayData.length,
              itemBuilder: (context, index) => NotificationCard(data: displayData[index]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: MainFooter(
        currentIndex: 3,
        onTap: (index) {
          if (index == 3) return;
          Widget nextPage;
          switch (index) {
            case 0: nextPage = const HomePage(); break;
            case 1: nextPage = const HealthRecordPage(); break;
            case 2: nextPage = const ChartPage(); break;
            case 4: nextPage = const SettingsPage(); break;
            default: nextPage = const HomePage();
          }
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => nextPage));
        },
      ),
    );
  }
}