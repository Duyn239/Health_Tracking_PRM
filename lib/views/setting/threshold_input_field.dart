import 'package:flutter/material.dart';

/// File này đã được cập nhật để hỗ trợ hiển thị giá trị mặc định và trạng thái khóa/mở khóa.
class ThresholdInputField extends StatelessWidget {
  final String label;
  final String unit;
  final String initialValue; // Giá trị mặc định hệ thống đề xuất
  final bool isEnabled;      // Trạng thái cho phép sửa (màu xám nếu false)

  const ThresholdInputField({
    super.key,
    required this.label,
    required this.unit,
    this.initialValue = "",   // Mặc định là chuỗi rỗng nếu không truyền
    this.isEnabled = false,    // Mặc định là khóa (màu xám)
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.black, fontSize: 13)),
          const SizedBox(height: 4),
          SizedBox(
            height: 40,
            child: TextField(
              enabled: isEnabled, // Điều khiển trạng thái nhập liệu
              // Sử dụng TextEditingController để hiển thị giá trị mặc định
              controller: TextEditingController(text: initialValue),
              style: TextStyle(
                color: isEnabled ? Colors.black : Colors.grey.shade600,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                filled: true,
                // Đổi màu nền thành xám nhạt khi không cho phép sửa
                fillColor: isEnabled ? Colors.white : Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                // Border khi bị disable
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                suffixIcon: Container(
                  padding: const EdgeInsets.only(right: 12),
                  alignment: Alignment.centerRight,
                  width: 60,
                  child: Text(
                      unit,
                      style: TextStyle(
                          color: isEnabled ? const Color(0xFF565D6D) : Colors.grey.shade400,
                          fontSize: 13
                      )
                  ),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
          ),
        ],
      ),
    );
  }
}