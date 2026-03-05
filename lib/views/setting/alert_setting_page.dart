import 'package:flutter/material.dart';
import 'package:health_tracking/views/setting/threshold_input_field.dart';
import '../footer/main_footer.dart';
import '../header/main_header.dart';
import '../home/home_page.dart';
import '../health_record/health_record_page.dart';
import '../chart/chart_page.dart';
import '../notification/notification_page.dart';
import '../setting/settings_page.dart';
import 'alert_section_group.dart';
import 'basic_info_card.dart';

class AlertSettingPage extends StatefulWidget {
  const AlertSettingPage({super.key});

  @override
  State<AlertSettingPage> createState() => _AlertSettingPageState();
}

class _AlertSettingPageState extends State<AlertSettingPage> {
  // Trạng thái cho phép chỉnh sửa hay không
  bool isEditing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const MainHeader(subTitle: 'Cài đặt cảnh báo'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nút quay về
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const Row(
                children: [
                  Icon(Icons.arrow_back_ios, color: Color(0xFF379AE6), size: 18),
                  Text(
                    "Quay lại",
                    style: TextStyle(color: Color(0xFF379AE6), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const BasicInfoCard(),
            const SizedBox(height: 24),

            // 2. Nhóm Huyết Áp - Fake dữ liệu mặc định
            AlertSectionGroup(
              title: "Huyết Áp",
              unitLabel: "Ngưỡng cảnh báo (mmHg)",
              children: [
                ThresholdInputField(label: "Tâm thu tối thiểu", unit: "mmHg", initialValue: "90", isEnabled: isEditing),
                ThresholdInputField(label: "Tâm thu tối đa", unit: "mmHg", initialValue: "140", isEnabled: isEditing),
                ThresholdInputField(label: "Tâm trương tối thiểu", unit: "mmHg", initialValue: "60", isEnabled: isEditing),
                ThresholdInputField(label: "Tâm trương tối đa", unit: "mmHg", initialValue: "90", isEnabled: isEditing),
              ],
            ),

            // 3. Nhóm Đường huyết
            AlertSectionGroup(
              title: "Đường huyết",
              unitLabel: "Ngưỡng cảnh báo (mg/dL)",
              children: [
                ThresholdInputField(label: "Giá trị tối thiểu", unit: "mg/dL", initialValue: "70", isEnabled: isEditing),
                ThresholdInputField(label: "Giá trị tối đa", unit: "mg/dL", initialValue: "130", isEnabled: isEditing),
              ],
            ),

            // 4. Nhóm Cân nặng
            AlertSectionGroup(
              title: "Cân nặng",
              unitLabel: "Ngưỡng cảnh báo (kg)",
              children: [
                ThresholdInputField(label: "Giá trị tối thiểu", unit: "kg", initialValue: "45", isEnabled: isEditing),
                ThresholdInputField(label: "Giá trị tối đa", unit: "kg", initialValue: "90", isEnabled: isEditing),
              ],
            ),

            // 5. Nhóm SpO2
            AlertSectionGroup(
              title: "SpO2",
              unitLabel: "Ngưỡng cảnh báo (%)",
              children: [
                ThresholdInputField(label: "Giá trị tối thiểu", unit: "%", initialValue: "94", isEnabled: isEditing),
                ThresholdInputField(label: "Giá trị tối đa", unit: "%", initialValue: "100", isEnabled: isEditing),
              ],
            ),

            const SizedBox(height: 30),

            // 6. Nút bấm cuối trang
            _buildBottomButtons(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: MainFooter(
        currentIndex: 4,
        onTap: (index) {
          if (index == 4) return;
          Widget nextPage;
          switch (index) {
            case 0: nextPage = const HomePage(); break;
            case 1: nextPage = const HealthRecordPage(); break;
            case 2: nextPage = const ChartPage(); break;
            case 3: nextPage = const NotificationPage(); break;
            case 4: nextPage = const SettingsPage(); break;
            default: nextPage = const HomePage();
          }
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => nextPage));
        },
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Nút đổi tên và chức năng dựa trên biến isEditing
        ElevatedButton(
          onPressed: () {
            setState(() {
              isEditing = true; // Kích hoạt chế độ sửa
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isEditing ? Colors.grey[200] : const Color(0xFFF1F8FD),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(
            isEditing ? "Đang chỉnh sửa..." : "Chỉnh sửa cài đặt",
            style: TextStyle(color: isEditing ? Colors.grey : const Color(0xFF379AE6)),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: isEditing ? () {
            setState(() {
              isEditing = false; // Lưu xong thì khóa lại
            });
            // Thêm logic lưu dữ liệu ở đây
          } : null, // Disable nút lưu nếu không ở chế độ edit
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF379AE6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text("Lưu cấu hình", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}