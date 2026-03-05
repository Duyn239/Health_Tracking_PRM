import 'package:flutter/material.dart';

class ModalAddRecord extends StatefulWidget {
  const ModalAddRecord({super.key});

  @override
  State<ModalAddRecord> createState() => _ModalAddRecordState();
}

class _ModalAddRecordState extends State<ModalAddRecord> {
  String selectedType = 'Huyết áp';

  // Hàm tiện ích để tạo Label có dấu * đỏ
  Widget _buildRequiredLabel(String label) {
    return RichText(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Color(0xFF334155),
          fontSize: 13, // Giảm nhẹ size để vừa với layout 3 cột
          fontWeight: FontWeight.w500,
        ),
        children: const [
          TextSpan(
            text: ' *',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- PHẦN TIÊU ĐỀ ---
                Stack(
                  alignment: Alignment.center,
                  children: [
                    const Text(
                      'Thêm bản ghi mới',
                      style: TextStyle(
                        color: Color(0xFF379AE6),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 1, thickness: 1),
                const SizedBox(height: 20),

                // --- LOẠI CHỈ SỐ ---
                const Text(
                  'Loại chỉ số',
                  style: TextStyle(color: Color(0xFF334155), fontSize: 14),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedType,
                      dropdownColor: Colors.white,
                      items: ['Huyết áp', 'Đường huyết', 'Cân nặng', 'Sp02']
                          .map((String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ))
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedType = val!;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // --- PHẦN THAY ĐỔI THEO LOẠI CHỈ SỐ ---
                _buildDynamicFields(),

                const SizedBox(height: 16),

                // --- THỜI ĐIỂM ĐO ---
                _buildRequiredLabel('Thời điểm đo'),
                const SizedBox(height: 8),
                TextField(
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Chọn ngày giờ',
                    suffixIcon: const Icon(Icons.calendar_today, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onTap: () {
                    // Xử lý chọn ngày giờ
                  },
                ),
                const SizedBox(height: 16),

                // --- GHI CHÚ ---
                const Text('Ghi chú (tùy chọn)',
                    style: TextStyle(color: Color(0xFF334155), fontSize: 14)),
                const SizedBox(height: 8),
                TextField(
                  maxLines: 2,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 24),

                // --- PHẦN NÚT BẤM ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.black),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: const Text('Hủy', style: TextStyle(color: Colors.black)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3C83F6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Lưu', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicFields() {
    if (selectedType == 'Huyết áp') {
      return Row(
        children: [
          // Tâm thu
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRequiredLabel('Tâm thu'),
                const SizedBox(height: 8),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'mmHg',
                    hintStyle: const TextStyle(fontSize: 11),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Tâm trương
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRequiredLabel('Tâm trương'),
                const SizedBox(height: 8),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'mmHg',
                    hintStyle: const TextStyle(fontSize: 11),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Nhịp tim
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRequiredLabel('Nhịp tim'),
                const SizedBox(height: 8),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'bpm',
                    hintStyle: const TextStyle(fontSize: 11),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      String label = "";
      switch (selectedType) {
        case 'Đường huyết': label = "Giá trị (mg/dL)"; break;
        case 'Cân nặng': label = "Giá trị (kg)"; break;
        case 'Sp02': label = "Giá trị (%)"; break;
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRequiredLabel(label),
          const SizedBox(height: 8),
          TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        ],
      );
    }
  }
}