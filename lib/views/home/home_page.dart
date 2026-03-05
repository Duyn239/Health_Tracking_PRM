import 'package:flutter/material.dart';
import '../header/main_header.dart';
import '../footer/main_footer.dart';
import '../chart/chart_page.dart';
import '../health_record/health_record_page.dart';
import '../notification/notification_page.dart';
import '../setting/settings_page.dart';
import 'health_tip_card.dart';
import 'menu_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _navigateTo(Widget page) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const MainHeader(subTitle: 'Xin chào chủ nhân !!'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Chỉ số sức khỏe gần nhất ",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF565D6D)),
            ),
            const SizedBox(height: 20),

            // Lưới hiển thị 4 chỉ số sức khỏe gần nhất
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              childAspectRatio: 1.2, // Chỉnh lại tỉ lệ để không bị tràn khi thêm dòng
              children: const [
                MenuCard(
                  title: "Huyết áp",
                  value: "120/80",
                  unit: "mmHg",
                  heartRate: "72bpm", // Chỉ số nhịp tim riêng cho huyết áp
                  time: "22:32 30/01/2026",
                  icon: Icons.favorite,
                  color: Color(0xFFFFE8E8),
                  iconColor: Colors.redAccent,
                ),
                MenuCard(
                  title: "Đường huyết",
                  value: "95",
                  unit: "mg/dL",
                  time: "07:15 31/01/2026",
                  icon: Icons.water_drop,
                  color: Color(0xFFE3F2FD),
                  iconColor: Color(0xFF379AE6),
                ),
                MenuCard(
                  title: "Cân nặng",
                  value: "65.5",
                  unit: "kg",
                  time: "08:00 29/01/2026",
                  icon: Icons.monitor_weight,
                  color: Color(0xFFE8F5E9),
                  iconColor: Colors.green,
                ),
                MenuCard(
                  title: "SpO2",
                  value: "98",
                  unit: "%",
                  time: "21:10 30/01/2026",
                  icon: Icons.bolt,
                  color: Color(0xFFFFF3E0),
                  iconColor: Colors.orangeAccent,
                ),
              ],
            ),

            const SizedBox(height: 30),
            const Text("Lời khuyên từ chuyên gia",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF565D6D))),

            const SizedBox(height: 15),

            // 4 Lời khuyên cho 4 chỉ số
            const HealthTipCard(
              content: "Huyết áp của bạn đang ở mức lý tưởng. Hãy duy trì chế độ ăn ít muối và tập thể dục đều đặn.",
              gradientColors: [Color(0xFFEF5350), Color(0xFFC62828)],
            ),
            const SizedBox(height: 12),
            const HealthTipCard(
              content: "Chỉ số đường huyết sau ăn của bạn hơi cao. Hãy hạn chế đồ ngọt và tinh bột trắng vào buổi tối.",
              gradientColors: [Color(0xFF42A5F5), Color(0xFF1565C0)],
            ),
            const SizedBox(height: 12),
            const HealthTipCard(
              content: "Cân nặng của bạn đã giảm 1kg so với tuần trước. Tuyệt vời! Hãy tiếp tục duy trì cường độ tập luyện này.",
              gradientColors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
            ),
            const SizedBox(height: 12),
            const HealthTipCard(
              content: "Nồng độ Oxy trong máu (SpO2) rất tốt. Nếu bạn cảm thấy khó thở, hãy thực hiện bài tập hít thở sâu.",
              gradientColors: [Color(0xFFFFA726), Color(0xFFEF6C00)],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: MainFooter(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) return;
          List<Widget> pages = [
            const HomePage(),
            const HealthRecordPage(),
            const ChartPage(),
            const NotificationPage(),
            const SettingsPage()
          ];
          _navigateTo(pages[index]);
        },
      ),
    );
  }
}