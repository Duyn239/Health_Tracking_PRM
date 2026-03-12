import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../viewmodels/login_vm.dart';
import '../../viewmodels/home_vm.dart';
import '../../data/models/health_record.dart';
import '../../data/models/health_tip.dart'; // Đảm bảo import model HealthTip

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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loginVM = Provider.of<LoginViewModel>(context, listen: false);
      final homeVM = Provider.of<HomeViewModel>(context, listen: false);

      if (loginVM.tempFullName != null) {
        homeVM.setUserName(loginVM.tempFullName);
      }

      final accountId = loginVM.currentAccount?.id;
      if (accountId != null) {
        homeVM.fetchLatestHealthData(accountId);
      }
    });
  }

  /// Hàm xác định màu Gradient dựa trên LOẠI chỉ số (Type)
  List<Color> _getTipGradient(String type) {
    switch (type) {
      case 'Huyết áp':
      // Màu đỏ (Gốc đỏ đậm)
        return [const Color(0xFFEF5350), const Color(0xFFC62828)];
      case 'Đường huyết':
      // Màu xanh dương
        return [const Color(0xFF42A5F5), const Color(0xFF1565C0)];
      case 'Cân nặng':
      // Màu xanh lá
        return [const Color(0xFF66BB6A), const Color(0xFF2E7D32)];
      case 'SpO2':
      // Màu vàng cam
        return [const Color(0xFFFFA726), const Color(0xFFEF6C00)];
      default:
      // Màu mặc định (Xám/Xanh nhạt) nếu không khớp loại
        return [const Color(0xFF90A4AE), const Color(0xFF455A64)];
    }
  }

  /// Widget hiển thị danh sách lời khuyên hoặc thông báo trống
  Widget _buildTipsSection(HomeViewModel homeVM) {
    if (homeVM.displayTips.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(Icons.lightbulb_circle_outlined, size: 50, color: Colors.grey.shade300),
            const SizedBox(height: 10),
            Text(
              "Chưa có lời khuyên nào",
              style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 5),
            const Text(
              "Hãy thực hiện đo chỉ số sức khỏe để chuyên gia đưa ra lời khuyên cho bạn.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: homeVM.displayTips.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final tip = homeVM.displayTips[index];
        return HealthTipCard(
          content: tip.content,
          gradientColors: _getTipGradient(tip.type),
        );
      },
    );
  }

  Widget _buildDynamicMenuCard(HomeViewModel homeVM, String type) {
    final HealthRecord? record = homeVM.getRecordByType(type);
    final Map<String, dynamic> uiConfig = {
      "Huyết áp": {"icon": Icons.favorite, "color": const Color(0xFFFFE8E8), "iconColor": Colors.redAccent, "defaultUnit": "mmHg"},
      "Đường huyết": {"icon": Icons.water_drop, "color": const Color(0xFFE3F2FD), "iconColor": const Color(0xFF379AE6), "defaultUnit": "mg/dL"},
      "Cân nặng": {"icon": Icons.monitor_weight, "color": const Color(0xFFE8F5E9), "iconColor": Colors.green, "defaultUnit": "kg"},
      "SpO2": {"icon": Icons.bolt, "color": const Color(0xFFFFF3E0), "iconColor": Colors.orangeAccent, "defaultUnit": "%"},
    };

    final config = uiConfig[type]!;

    if (record == null) {
      return MenuCard(
        title: type,
        value: "---",
        unit: config['defaultUnit'],
        time: "Chưa có dữ liệu",
        icon: config['icon'],
        color: config['color'],
        iconColor: config['iconColor'],
      );
    }

    String displayValue = type == "Huyết áp"
        ? "${record.value1.toInt()}/${record.value2?.toInt() ?? 0}"
        : (record.value1 == record.value1.toInt() ? record.value1.toInt().toString() : record.value1.toStringAsFixed(1));

    String displayTime;
    try {
      displayTime = DateFormat('HH:mm dd/MM').format(DateTime.parse(record.measuredAt));
    } catch (e) {
      displayTime = record.measuredAt;
    }

    return MenuCard(
      title: type,
      value: displayValue,
      unit: record.unit,
      heartRate: record.heartRate != null ? "${record.heartRate} bpm" : null,
      note: record.note,
      time: displayTime,
      icon: config['icon'],
      color: config['color'],
      iconColor: config['iconColor'],
    );
  }

  void _navigateTo(Widget page) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    final homeVM = Provider.of<HomeViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: MainHeader(subTitle: 'Xin chào, ${homeVM.userName} !!'),
      body: homeVM.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: () async {
          final loginVM = Provider.of<LoginViewModel>(context, listen: false);
          if (loginVM.currentAccount?.id != null) {
            await homeVM.fetchLatestHealthData(loginVM.currentAccount!.id!);
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Chỉ số sức khỏe gần nhất",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF565D6D)),
              ),
              const SizedBox(height: 20),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                childAspectRatio: 1.2,
                children: [
                  _buildDynamicMenuCard(homeVM, "Huyết áp"),
                  _buildDynamicMenuCard(homeVM, "Đường huyết"),
                  _buildDynamicMenuCard(homeVM, "Cân nặng"),
                  _buildDynamicMenuCard(homeVM, "SpO2"),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                "Lời khuyên từ chuyên gia",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF565D6D)),
              ),
              const SizedBox(height: 15),

              // Gọi Section hiển thị Tips động
              _buildTipsSection(homeVM),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: MainFooter(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) return;
          List<Widget> pages = [const HomePage(), const HealthRecordPage(), const ChartPage(), const NotificationPage(), const SettingsPage()];
          _navigateTo(pages[index]);
        },
      ),
    );
  }
}