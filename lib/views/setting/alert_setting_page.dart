import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/alert_setting_vm.dart';
import '../../viewmodels/login_vm.dart';
import '../../viewmodels/profile_vm.dart';
import '../../views/setting/threshold_input_field.dart';
import '../footer/main_footer.dart';
import '../header/main_header.dart';
import '../home/home_page.dart';
import '../health_record/health_record_page.dart';
import '../chart/chart_page.dart';
import '../notification/notification_page.dart';
import 'alert_section_group.dart';
import 'basic_info_card.dart';

class AlertSettingPage extends StatefulWidget {
  const AlertSettingPage({super.key});

  @override
  State<AlertSettingPage> createState() => _AlertSettingPageState();
}

class _AlertSettingPageState extends State<AlertSettingPage> {
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  void _fetchData() {
    final accountId = context.read<LoginViewModel>().currentAccount?.id;
    if (accountId != null) {
      context.read<AlertSettingViewModel>().loadSettings(accountId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final alertVM = context.watch<AlertSettingViewModel>();
    final profileVM = context.watch<ProfileViewModel>();

    // LOGIC: Kiểm tra xem người dùng đã nhập profile chưa
    final bool hasBasicInfo = profileVM.userProfile != null &&
        (profileVM.userProfile!.height ?? 0) > 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const MainHeader(subTitle: 'Cài đặt cảnh báo'),
      body: alertVM.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBackButton(),
            const SizedBox(height: 16),

            // --- BANNER CẢNH BÁO ---
            if (!hasBasicInfo) _buildWarningBanner(),

            const BasicInfoCard(),
            const SizedBox(height: 16),

            // 1. NHÓM HUYẾT ÁP
            AlertSectionGroup(
              title: "Huyết Áp",
              unitLabel: "Ngưỡng cảnh báo (mmHg)",
              onReset: () => _showConfirmResetDialog(),
              isEnabled: hasBasicInfo, // Sử dụng biến kiểm tra chỉ số ban đầu
              children: [
                _buildField(alertVM, "Tâm thu tối thiểu", "mmHg", "sys_min"),
                _buildField(alertVM, "Tâm thu tối đa", "mmHg", "sys_max"),
                _buildField(alertVM, "Tâm trương tối thiểu", "mmHg", "dia_min"),
                _buildField(alertVM, "Tâm trương tối đa", "mmHg", "dia_max"),
              ],
            ),

            // 2. NHÓM ĐƯỜNG HUYẾT
            AlertSectionGroup(
              title: "Đường huyết",
              unitLabel: "Ngưỡng cảnh báo (mg/dL)",
              children: [
                _buildField(alertVM, "Giá trị tối thiểu", "mg/dL", "glu_min"),
                _buildField(alertVM, "Giá trị tối đa", "mg/dL", "glu_max"),
              ],
            ),

            // 3. NHÓM CÂN NẶNG
            AlertSectionGroup(
              title: "Cân nặng",
              unitLabel: "Ngưỡng cảnh báo (kg)",
              children: [
                _buildField(alertVM, "Giá trị tối thiểu", "kg", "weight_min"),
                _buildField(alertVM, "Giá trị tối đa", "kg", "weight_max"),
              ],
            ),

            // 4. NHÓM SPO2
            AlertSectionGroup(
              title: "SpO2",
              unitLabel: "Ngưỡng cảnh báo (%)",
              children: [
                _buildField(alertVM, "Giá trị tối thiểu", "%", "spo2_min"),
                _buildField(alertVM, "Giá trị tối đa", "%", "spo2_max"),
              ],
            ),

            const SizedBox(height: 30),
            // Truyền hasBasicInfo vào để xử lý disable nút
            _buildBottomButtons(context, alertVM, hasBasicInfo),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: MainFooter(
        currentIndex: 4,
        onTap: (index) => _navigateTo(index),
      ),
    );
  }

  // Widget hiển thị Banner cảnh báo
  Widget _buildWarningBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Vui lòng cập nhật Chỉ số sức khỏe ban đầu để có thể chỉnh sửa ngưỡng cảnh báo.",
              style: TextStyle(color: Colors.orange.shade900, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(AlertSettingViewModel vm, String label, String unit, String key) {
    return ThresholdInputField(
      label: label,
      unit: unit,
      isEnabled: isEditing,
      controller: vm.controllers[key],
      errorText: vm.errors[key],
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: const Row(
        children: [
          Icon(Icons.arrow_back_ios, color: Color(0xFF379AE6), size: 18),
          const Text("Quay lại", style: TextStyle(color: Color(0xFF379AE6), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showConfirmResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        titlePadding: EdgeInsets.zero,
        title: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: const BoxDecoration(
            color: Color(0xFF379AE6),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
          ),
          child: const Center(
            child: Text(
              "Xác nhận khôi phục",
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        content: const Text(
          "Toàn bộ ngưỡng cảnh báo sẽ được tính toán lại dựa trên hồ sơ sức khỏe của bạn. Các thay đổi hiện tại sẽ bị ghi đè.",
          style: TextStyle(color: Colors.black87, fontSize: 14),
        ),
        actionsPadding: const EdgeInsets.only(right: 16, bottom: 16),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFBDBDBD),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Hủy"),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleResetAction();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF44336),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Khôi phục"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleResetAction() async {
    final profileVM = context.read<ProfileViewModel>();
    final alertVM = context.read<AlertSettingViewModel>();
    final loginVM = context.read<LoginViewModel>();

    final accountId = loginVM.currentAccount?.id;
    final profile = profileVM.userProfile;

    final Map<String, int> diseaseMap = {
      'Tăng huyết áp': 1, 'Tiểu đường': 2, 'Bệnh tim mạch': 3, 'Bệnh hô hấp': 4,
    };

    final List<int> diseaseIds = profileVM.diseases
        .where((name) => diseaseMap.containsKey(name))
        .map((name) => diseaseMap[name]!)
        .toList();

    if (accountId != null && profile != null) {
      bool success = await alertVM.resetToDefault(accountId, profile, diseaseIds);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã khôi phục ngưỡng mặc định"), backgroundColor: Colors.green),
        );
      }
    }
  }

  Widget _buildBottomButtons(BuildContext context, AlertSettingViewModel alertVM, bool hasBasicInfo) {
    final accountId = context.read<LoginViewModel>().currentAccount?.id;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          // Vô hiệu hóa nút nếu chưa có profile
          onPressed: hasBasicInfo ? () async {
            if (isEditing) {
              // --- TRƯỜNG HỢP ẤN "HỦY" ---
              // 1. Nếu có accountId, nạp lại dữ liệu cũ từ DB để ghi đè các thay đổi tạm thời
              if (accountId != null) {
                await alertVM.loadSettings(accountId);
              }
              // 2. Xóa sạch các thông báo lỗi validate cũ
              alertVM.clearErrors();
            }

            // 3. Chuyển đổi trạng thái giữa Chỉnh sửa <-> Xem
            setState(() {
              isEditing = !isEditing;
            });
          } : null,

          style: ElevatedButton.styleFrom(
            backgroundColor: hasBasicInfo
                ? (isEditing ? Colors.grey[200] : const Color(0xFFF1F8FD))
                : Colors.grey.shade100,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),

          child: Text(
            isEditing ? "Hủy chỉnh sửa" : "Chỉnh sửa cài đặt",
            style: TextStyle(
                color: hasBasicInfo
                    ? (isEditing ? Colors.black54 : const Color(0xFF379AE6))
                    : Colors.grey.shade400
            ),
          ),
        ),
        const SizedBox(width: 12),

        ElevatedButton(
          onPressed: (isEditing && accountId != null && hasBasicInfo)
              ? () async {
            // Thực hiện validate qua Service (như đã tách logic trước đó)
            if (alertVM.validateSettings()) {
              bool success = await alertVM.saveAllSettings(accountId);
              if (success && mounted) {
                setState(() => isEditing = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Lưu cấu hình thành công"),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Vui lòng kiểm tra các ô báo lỗi"),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          } : null,

          style: ElevatedButton.styleFrom(
            backgroundColor: (isEditing && hasBasicInfo)
                ? const Color(0xFF379AE6)
                : Colors.grey.shade300,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text("Lưu cấu hình", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  void _navigateTo(int index) {
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