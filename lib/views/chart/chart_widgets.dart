import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Các widget/helper dùng chung cho biểu đồ.
class ChartWidgets {
  /// Build cấu hình trục X và Y cho fl_chart.
  /// [totalDays] dùng để tính bước hiển thị nhãn trục X khi xem theo tháng.
  static FlTitlesData buildTitles({
    required String leftLabel,
    required String bottomLabel,
    required double interval,
    required List<String> bottomValues,
    int totalDays = 7,
  }) {
    // Với tháng (30+ ngày) chỉ hiện nhãn mỗi 5 ngày để tránh chồng chữ
    final int labelStep = totalDays <= 7 ? 1 : 5;

    return FlTitlesData(
      rightTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      topTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      leftTitles: AxisTitles(
        axisNameWidget: Text(
          leftLabel,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFF379AE6),
          ),
        ),
        axisNameSize: 20,
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          interval: interval,
          getTitlesWidget: (value, meta) => Text(
            value.toInt().toString(),
            style: const TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ),
      ),
      bottomTitles: AxisTitles(
        axisNameWidget: Text(
          bottomLabel,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFF379AE6),
          ),
        ),
        axisNameSize: 25,
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          interval: labelStep.toDouble(),
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            // Chỉ hiện nhãn theo bước đã tính
            if (index % labelStep != 0) return const SizedBox.shrink();
            if (index >= 0 && index < bottomValues.length) {
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  bottomValues[index],
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  /// Widget chú thích màu sắc phía dưới biểu đồ
  static Widget buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  /// Widget thẻ thống kê nhỏ (Trung bình / Gần nhất)
  static Widget buildStatCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}