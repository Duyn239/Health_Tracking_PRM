import 'package:flutter/material.dart';
import 'delete_record_modal.dart';
import 'edit_record_modal.dart'; // Import file modal mới

class HealthRecordCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String unit;
  final String note;
  final String time;

  const HealthRecordCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.unit,
    required this.note,
    required this.time,
  });

  void _showEditModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => EditRecordModal(title: title), // Gọi Widget Modal tách riêng
    );
  }

  // Hàm hiển thị Modal Xóa
  void _showDeleteModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => DeleteRecordModal(title: title),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              Icon(icon, color: const Color(0xFF379AE6), size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF171A1F),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: () => _showEditModal(context),
                child: const Icon(Icons.edit_note, color: Color(0xFF379AE6), size: 20),
              ),
              const SizedBox(width: 4),
// Icon Delete đã được kích hoạt
              GestureDetector(
                onTap: () => _showDeleteModal(context),
                child: const Icon(Icons.delete_outline, color: Color(0xFFDE3B40), size: 20),
              ),            ],
          ),
          const SizedBox(height: 10),
          ShaderMask(
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
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    unit,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          Text(
            note,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF565D6D), fontSize: 12),
          ),
          const SizedBox(height: 2),
          Text(
            time,
            style: const TextStyle(color: Color(0xFF565D6D), fontSize: 11),
          ),
        ],
      ),
    );
  }
}