import 'package:flutter/material.dart';
import 'package:health_tracking/views/profile/profile_page.dart';
import '../chart/chart_page.dart';
import '../footer/main_footer.dart';
import '../header/main_header.dart';
import '../health_record/health_record_page.dart';
import '../home/home_page.dart';
import '../notification/notification_page.dart';
import 'alert_setting_page.dart';
import 'medical_sources_page.dart'; // Import trang mới tạo

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const MainHeader(subTitle: 'Cài đặt'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Thông tin người dùng
            _buildUserHeader(),

            const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),

            // 2. Danh sách Menu
            _buildMenuItem(
              icon: Icons.person_outline,
              text: 'Hồ sơ cá nhân',
              color: Colors.black,
              onTap: () => _navigateTo(const ProfilePage()),
            ),

            _buildMenuItem(
              icon: Icons.settings_outlined,
              text: 'Cài đặt cảnh báo',
              color: Colors.black,
              onTap: () => _navigateTo(const AlertSettingPage()),
            ),

            // --- MỤC MỚI THÊM VÀO ---
            _buildMenuItem(
              icon: Icons.menu_book_outlined,
              text: 'Nguồn tài liệu y khoa',
              color: Colors.black,
              onTap: () => _navigateTo(const MedicalSourcesPage()),
            ),
            // ------------------------

            const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),

            // 3. Nút Đăng xuất
            _buildMenuItem(
              icon: Icons.logout,
              text: 'Đăng xuất',
              color: const Color(0xFFDE3B40),
              onTap: () {
                // Xử lý đăng xuất ở đây
              },
            ),

            const SizedBox(height: 20),

            // 4. Hình ảnh minh họa
            _buildIllustration(),

            const SizedBox(height: 20),

            // 5. Bản quyền
            const Text(
              '© 2026 Health Tracker. All rights reserved.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: MainFooter(
        currentIndex: 4,
        onTap: (index) => _onFooterTap(index),
      ),
    );
  }

  // --- WIDGET HELPER METHODS ---

  Widget _buildUserHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Color(0xFF1A237E),
            child: Text('A', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Admin User', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text('admin@healthtracker.com', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          'assets/health-tracking-setting.webp',
          height: 300,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }

  // --- NAVIGATION LOGIC ---

  void _navigateTo(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  void _onFooterTap(int index) {
    if (index == 4) return;
    Widget nextPage;
    switch (index) {
      case 0: nextPage = const HomePage(); break;
      case 1: nextPage = const HealthRecordPage(); break;
      case 2: nextPage = const ChartPage(); break;
      case 3: nextPage = const NotificationPage(); break;
      default: nextPage = const HomePage();
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => nextPage));
  }
}