import 'package:flutter/material.dart';

/// trang thiết lập chỉ số sức khỏe ban đầu trước khi được tạo bản ghi skhoe
class BasicInfoModal extends StatefulWidget {
  const BasicInfoModal({super.key});

  @override
  State<BasicInfoModal> createState() => _BasicInfoModalState();
}

class _BasicInfoModalState extends State<BasicInfoModal> {
  // Trạng thái cho các checkbox
  Map<String, bool> conditions = {
    "Tăng huyết áp": false,
    "Tiểu đường": false,
    "Bệnh tim mạch": false,
    "Bệnh hô hấp": false,
  };

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tiêu đề và nút X
              Stack(
                alignment: Alignment.center,
                children: [
                  const Center(
                    child: Text(
                      'Thiết lập theo dõi sức khỏe ban đầu',
                      style: TextStyle(
                          color: Color(0xFF379AE6),
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, color: Colors.grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(color: Colors.grey),
              const SizedBox(height: 10),

              // 1. Ngày sinh
              _buildLabel("1. Ngày sinh"),
              _buildTextField("Ngày/tháng/năm"),

              const SizedBox(height: 15),

              // 2. Giới tính & 3. Chiều cao
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("2. Giới tính"),
                        _buildTextField("Nam/Nữ"),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("3. Chiều cao (cm)"),
                        _buildTextField("170"),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // 4. Cân nặng
              _buildLabel("4. Cân nặng (kg)"),
              _buildTextField("60"),

              const SizedBox(height: 15),

              // 5. Câu hỏi tình trạng - KHÔNG CÓ DẤU *
              _buildLabel("5. Bạn có tình trạng nào sau đây không?", isRequired: false),
              const SizedBox(height: 5),
              ...conditions.keys.map((String key) {
                return _buildCheckboxRow(key);
              }).toList(),

              const SizedBox(height: 20),

              // Nút Hủy và Lưu
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child:
                    const Text("Hủy", style: TextStyle(color: Colors.black)),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3C83F6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child:
                    const Text("Lưu", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Cập nhật hàm Label để hỗ trợ dấu * đỏ
  Widget _buildLabel(String text, {bool isRequired = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.w500),
          children: [
            if (isRequired)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint) {
    return SizedBox(
      height: 40,
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildCheckboxRow(String title) {
    return SizedBox(
      height: 35,
      child: Row(
        children: [
          Transform.scale(
            scale: 0.9,
            child: Checkbox(
              value: conditions[title],
              activeColor: const Color(0xFF2028BD),
              onChanged: (bool? value) {
                setState(() {
                  conditions[title] = value!;
                });
              },
            ),
          ),
          Text(title, style: const TextStyle(fontSize: 13, color: Colors.black)),
        ],
      ),
    );
  }
}