import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/login_vm.dart';
import '../../viewmodels/profile_vm.dart';

import 'package:health_tracking/views/profile/profile_avatar.dart';
import 'package:health_tracking/views/profile/profile_info_tile.dart';
import '../chart/chart_page.dart';
import '../header/main_header.dart';
import '../footer/main_footer.dart';
import '../health_record/health_record_page.dart';
import '../home/home_page.dart';
import '../notification/notification_page.dart';
import '../setting/settings_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Context read: chỉ lấy dữ liệu
      // KHÔNG rebuild UI
      final loginVM = context.read<LoginViewModel>();
      final profileVM = context.read<ProfileViewModel>();

      if (loginVM.currentAccount?.id != null) {
        profileVM.fetchProfile(loginVM.currentAccount!.id!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // watch → rebuild khi notifyListeners()
    final profileVM = context.watch<ProfileViewModel>();
    final loginVM = context.watch<LoginViewModel>();
    final profile = profileVM.userProfile;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const MainHeader(subTitle: 'Hồ sơ cá nhân'),
      body: profileVM.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildBackButton(context),
                  const SizedBox(height: 10),

                  // Avatar dùng chung cho toàn bộ người dùng
                  ProfileAvatar(
                    name: profileVM.getDisplayValue(profile?.fullName),
                    id: "ID tài khoản: ${profile?.accountId ?? 'N/A'}",
                    imageUrl:
                        'assets/avatar_default.png', // Sử dụng asset chung
                  ),

                  const SizedBox(height: 25),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          ProfileInfoTile(
                            icon: Icons.person_outline,
                            label: "Họ và tên",
                            value: profileVM.getDisplayValue(profile?.fullName),
                          ),
                          _buildDivider(),
                          ProfileInfoTile(
                            icon: Icons.email_outlined,
                            label: "Gmail",
                            value: loginVM.currentAccount?.email ?? "Chưa có",
                          ),
                          _buildDivider(),
                          ProfileInfoTile(
                            icon: Icons.cake_outlined,
                            label: "Ngày sinh",
                            value: profileVM.getDisplayValue(profile?.dob),
                          ),
                          _buildDivider(),
                          ProfileInfoTile(
                            icon: Icons.transgender_outlined,
                            label: "Giới tính",
                            value: profileVM.getDisplayValue(profile?.gender),
                          ),
                          _buildDivider(),
                          ProfileInfoTile(
                            icon: Icons.height_outlined,
                            label: "Chiều cao",
                            value: profileVM.getDisplayValue(
                              profile?.height?.toInt().toString(),
                              unit: " cm",
                            ),
                          ),
                          _buildDivider(),
                          ProfileInfoTile(
                            icon: Icons.monitor_weight_outlined,
                            label: "Cân nặng",
                            value: profileVM.getDisplayValue(
                              profile?.weight,
                              unit: " kg",
                            ),
                          ),
                          _buildDivider(),
                          ProfileInfoTile(
                            icon: Icons.medical_services_outlined,
                            label: "Tình trạng",
                            value: profileVM.getDiseasesDisplay(),
                            /// xử lí sau
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
      bottomNavigationBar: MainFooter(
        currentIndex: 4,
        onTap: (index) {
          if (index == 4) return;
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
            default:
              nextPage = const SettingsPage();
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => nextPage),
          );
        },
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SettingsPage()),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.arrow_back_ios, size: 18, color: Color(0xFF379AE6)),
            SizedBox(width: 5),
            Text(
              "Quay về trang cài đặt",
              style: TextStyle(
                color: Color(0xFF379AE6),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 60,
      endIndent: 20,
      color: Colors.grey.shade100,
    );
  }
}
