import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/health_record.dart';
import 'delete_record_modal.dart';
import 'edit_record_modal.dart';

class HealthRecordCard extends StatelessWidget {
  final Map<String, dynamic> data; // Nhận Map dữ liệu gốc
  final IconData icon;

  const HealthRecordCard({
    super.key,
    required this.data,
    required this.icon,
  });

  void _showEditModal(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => EditRecordModal(
        record: HealthRecord.fromMap(data), // Khởi tạo Object từ Map ngay tại đây
      ),
    );
  }

  void _showDeleteModal(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => DeleteRecordModal( record: HealthRecord.fromMap(data)
      ),
    );
  }

  // --- HÀM HELPER XỬ LÝ SỐ ---
  String _formatNumber(dynamic v) {
    if (v == null) return "0";
    if (v is! num) return v.toString(); // Phòng hờ dữ liệu trả về không phải số

    // Nếu v là số nguyên (ví dụ 120.0 hoặc 120) thì trả về "120"
    // Nếu v là số thập phân (ví dụ 120.5) thì trả về "120.5"
    return v == v.toInt() ? v.toInt().toString() : v.toString();
  }

  @override
  Widget build(BuildContext context) {
    // Logic xử lý hiển thị giá trị
    String displayValue = _formatNumber(data['value_1']);

    if (data['type'] == 'Huyết áp' && data['value_2'] != null) {
      // Kết hợp cả value_1 và value_2 đã qua xử lý .0
      displayValue = "${_formatNumber(data['value_1'])}/${_formatNumber(data['value_2'])}";
    }

    // Logic format thời gian giữ nguyên ...
    String formattedTime = "N/A";
    if (data['measured_at'] != null) {
      try {
        DateTime dt = DateTime.parse(data['measured_at']);
        formattedTime = DateFormat('dd/MM/yyyy HH:mm').format(dt);
      } catch (_) {}
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(icon, color: const Color(0xFF379AE6), size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  data['type'] ?? "Không rõ",
                  style: const TextStyle(color: Color(0xFF171A1F), fontSize: 14, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: () => _showEditModal(context),
                child: const Icon(Icons.edit_note, color: Color(0xFF379AE6), size: 20),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => _showDeleteModal(context),
                child: const Icon(Icons.delete_outline, color: Color(0xFFDE3B40), size: 20),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Giá trị chính
          _buildValueDisplay(displayValue, data['unit'] ?? ""),

          const Spacer(),

          // Nhịp tim (Nếu có)
          if (data['heart_rate'] != null && data['heart_rate'] != 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.redAccent, size: 14),
                  const SizedBox(width: 4),
                  Text("${data['heart_rate']} bpm",
                      style: const TextStyle(color: Color(0xFF171A1F), fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),

          // Ghi chú & Thời gian
          Text(
            // Kiểm tra nếu null HOẶC nếu sau khi trim mà chuỗi rỗng
            (data['note'] == null || data['note'].toString().trim().isEmpty)
                ? "Không có ghi chú"
                : data['note'],
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF565D6D), fontSize: 12),
          ),
          const SizedBox(height: 2),
          Text(
            formattedTime,
            style: const TextStyle(color: Color(0xFF565D6D), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildValueDisplay(String val, String unit) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Color(0xFF379AE6), Color(0xFF1D4ED8)],
      ).createShader(bounds),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(val, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(width: 4),
            Text(unit, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}