import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/models/health_record.dart';
import '../../viewmodels/heath_record_vm.dart';
import '../../viewmodels/login_vm.dart';

class DeleteRecordModal extends StatelessWidget {
  final HealthRecord record;

  const DeleteRecordModal({super.key, required this.record});

  // Hàm định dạng số hiển thị (loại bỏ .0 nếu là số nguyên)
  String _formatValue(double? v) {
    if (v == null) return "";
    return v == v.toInt() ? v.toInt().toString() : v.toString();
  }

  Future<void> _handleDelete(BuildContext context) async {
    final healthVM = context.read<HealthRecordViewModel>();
    final loginVM = context.read<LoginViewModel>();
    final accountId = loginVM.currentAccount?.id;

    if (accountId == null || record.id == null) return;

    // Gọi hàm xóa từ VM
    bool success = await healthVM.deleteExistingRecord(
        record.id!,
        accountId,
        record.type,
    );

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Đã xóa bản ghi ${record.type} thành công !!"),
          backgroundColor: Colors.redAccent,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateTime measuredAt = DateTime.parse(record.measuredAt);
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(measuredAt);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      title: _buildHeader(context),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInputLabel("Thời điểm đo"),
              _buildReadOnlyField(text: dateStr, suffixIcon: Icons.calendar_today),

              if (record.type == "Huyết áp") ...[
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputLabel("Tâm thu"),
                          _buildReadOnlyField(text: _formatValue(record.value1), hint: "mmHg"),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputLabel("Tâm trương"),
                          _buildReadOnlyField(text: _formatValue(record.value2), hint: "mmHg"),
                        ],
                      ),
                    ),
                  ],
                ),
                _buildInputLabel("Nhịp tim"),
                _buildReadOnlyField(text: record.heartRate?.toString() ?? "", hint: "bpm"),
              ] else ...[
                // Các loại khác: Đường huyết, Cân nặng, SpO2...
                _buildInputLabel("${record.type} (${record.unit})"),
                _buildReadOnlyField(text: _formatValue(record.value1)),
              ],

              _buildInputLabel("Ghi chú"),
              _buildReadOnlyField(text: record.note ?? "Không có ghi chú", maxLines: 2),
              const SizedBox(height: 10),
              const Text(
                "* Hành động này không thể hoàn tác.",
                style: TextStyle(color: Colors.redAccent, fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
      actions: _buildActions(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
          child: SizedBox(
            height: 40, // Cố định chiều cao để Stack căn giữa chuẩn
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 1. Tiêu đề căn giữa tuyệt đối
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Color(0xFFDE3B40), size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'XÓA BẢN GHI',
                      style: TextStyle(
                        color: Color(0xFFDE3B40),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                // 2. Nút đóng nằm ở bên phải
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1, thickness: 0.5),
      ],
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text(
        label,
        style: const TextStyle(color: Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildReadOnlyField({required String text, String? hint, IconData? suffixIcon, int maxLines = 1}) {
    return TextField(
      controller: TextEditingController(text: text),
      enabled: false, // Vô hiệu hóa chỉnh sửa
      maxLines: maxLines,
      style: const TextStyle(color: Colors.black87, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: suffixIcon != null ? Icon(suffixIcon, size: 18) : null,
        filled: true,
        fillColor: const Color(0xFFF1F5F9), // Màu nền xám để phân biệt với ô Edit
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: const Text("Hủy", style: TextStyle(color: Colors.black54)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _handleDelete(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDE3B40),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Xóa", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    ];
  }
}