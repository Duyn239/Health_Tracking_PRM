import 'package:flutter/material.dart';

/// Thanh điều khiển lọc: Tuần/Tháng + Dropdown chỉ số
class ChartFilterControls extends StatelessWidget {
  final String selectedMetric;
  final List<String> metrics;
  final bool isWeekly;
  final Function(String) onMetricChanged;
  final Function(bool) onPeriodChanged;

  const ChartFilterControls({
    super.key,
    required this.selectedMetric,
    required this.metrics,
    required this.isWeekly,
    required this.onMetricChanged,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Nút Tuần / Tháng có trạng thái active/inactive
        Row(
          children: [
            _buildTimeButton(
              label: 'Tuần',
              isActive: isWeekly,
              onTap: () => onPeriodChanged(true),
            ),
            const SizedBox(width: 8),
            _buildTimeButton(
              label: 'Tháng',
              isActive: !isWeekly,
              onTap: () => onPeriodChanged(false),
            ),
          ],
        ),
        _buildMetricDropdown(),
      ],
    );
  }

  Widget _buildTimeButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF2028BD) : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isActive ? const Color(0xFF2028BD) : Colors.grey.shade300,
          ),
          boxShadow: isActive
              ? [
            BoxShadow(
              color: const Color(0xFF2028BD).withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildMetricDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedMetric,
          dropdownColor: Colors.white,
          style: const TextStyle(
            color: Color(0xFF1A1A2E),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          items: metrics
              .map(
                (val) => DropdownMenuItem(value: val, child: Text(val)),
          )
              .toList(),
          onChanged: (v) {
            if (v != null) onMetricChanged(v);
          },
        ),
      ),
    );
  }
}