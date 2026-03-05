import 'package:flutter/material.dart';

class MenuCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final String time;
  final String? heartRate;
  final IconData icon;
  final Color color;
  final Color iconColor;

  const MenuCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.time,
    this.heartRate,
    required this.icon,
    required this.color,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Tiêu đề và Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                Flexible(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8), // Khoảng cách nhỏ sau tiêu đề

            // 2. GIÁ TRỊ CHÍNH (Đã đẩy lên cao hơn)
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF323842),
                  ),
                  children: [
                    TextSpan(
                      text: ' $unit',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(), // Đẩy toàn bộ phần thông tin phụ xuống đáy Card

            // 3. NHỊP TIM (Nếu có)
            if (heartRate != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  "Nhịp tim: $heartRate",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF323842),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            // 4. THỜI GIAN ĐO
            Text(
              time,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade400,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}