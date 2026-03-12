import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/chart_vm.dart';
import 'chart_widgets.dart';

class ChartContentView extends StatelessWidget {
  const ChartContentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChartViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF2028BD)),
          );
        }

        if (!vm.hasData) {
          return _buildEmptyState(vm);
        }

        switch (vm.selectedMetric) {
          case 'Huyết áp':
            return _buildLineChart(vm,
              primaryColor: const Color(0xFFE53935),
              secondaryColor: const Color(0xFF2028BD),
              showSecondary: true,
            );
          case 'Đường huyết':
            return _buildLineChart(vm,
              primaryColor: const Color(0xFFFF8C00),
              showSecondary: false,
            );
          case 'Cân nặng':
            return _buildBarChart(vm);
          case 'SpO2':
            return _buildLineChart(vm,
              primaryColor: const Color(0xFF00897B),
              showSecondary: false,
            );
          default:
            return const Center(child: Text('Đang cập nhật...'));
        }
      },
    );
  }

  // ─── Empty state ──────────────────────────────────────────────────────────

  Widget _buildEmptyState(ChartViewModel vm) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_rounded, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            vm.isWeekly
                ? 'Chưa có dữ liệu trong tuần này'
                : 'Chưa có dữ liệu trong tháng này',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ─── LineChart ────────────────────────────────────────────────────────────

  Widget _buildLineChart(
      ChartViewModel vm, {
        required Color primaryColor,
        Color? secondaryColor,
        required bool showSecondary,
      }) {
    final yRange   = vm.maxY - vm.minY;
    final interval = yRange <= 20 ? 2.0
        : yRange <= 60  ? 10.0
        : yRange <= 100 ? 20.0
        : 30.0;

    String tooltipPrimaryLabel() {
      switch (vm.selectedMetric) {
        case 'Huyết áp':    return 'Tâm thu';
        case 'Đường huyết': return 'Đường huyết';
        case 'SpO2':        return 'SpO2';
        default:            return vm.selectedMetric;
      }
    }

    return LineChart(
      LineChartData(
        minY: vm.minY,
        maxY: vm.maxY,
        minX: 0,
        maxX: (vm.totalDays - 1).toDouble(),

        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: interval,
          verticalInterval: 1,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: Colors.grey.shade200, strokeWidth: 1),
          getDrawingVerticalLine: (_) =>
              FlLine(color: Colors.grey.shade100, strokeWidth: 1),
        ),

        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.shade200),
        ),

        titlesData: ChartWidgets.buildTitles(
          leftLabel: vm.unit,
          bottomLabel: vm.isWeekly ? 'Thứ' : 'Ngày',
          interval: interval,
          bottomValues: vm.xLabels,
          totalDays: vm.totalDays,
        ),

        // ── Đường ngưỡng cảnh báo ngang ──────────────────────────────────
        extraLinesData: ExtraLinesData(
          horizontalLines: _buildThresholdLines(vm),
        ),

        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) =>
                const Color(0xFF2028BD).withOpacity(0.85),
            getTooltipItems: (spots) => spots.map((spot) {
              final label = spot.barIndex == 0
                  ? tooltipPrimaryLabel()
                  : 'Tâm trương';
              return LineTooltipItem(
                '$label\n${spot.y.toStringAsFixed(1)} ${vm.unit}',
                const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              );
            }).toList(),
          ),
        ),

        lineBarsData: [
          // Đường chính
          LineChartBarData(
            spots: vm.primarySpots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: primaryColor,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                radius: 4,
                color: Colors.white,
                strokeWidth: 2.5,
                strokeColor: primaryColor,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: primaryColor.withOpacity(0.07),
            ),
          ),

          // Đường phụ (chỉ Huyết áp - Tâm trương)
          if (showSecondary && vm.secondarySpots.isNotEmpty)
            LineChartBarData(
              spots: vm.secondarySpots,
              isCurved: true,
              curveSmoothness: 0.3,
              color: secondaryColor ?? Colors.blue,
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2.5,
                  strokeColor: secondaryColor ?? Colors.blue,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: (secondaryColor ?? Colors.blue).withOpacity(0.07),
              ),
            ),
        ],
      ),
    );
  }

  // ─── Tạo danh sách đường ngưỡng ngang ─────────────────────────────────────

  List<HorizontalLine> _buildThresholdLines(ChartViewModel vm) {
    final lines = <HorizontalLine>[];

    switch (vm.selectedMetric) {
      case 'Huyết áp':
      // Ngưỡng tâm thu
        if (vm.sysMax != null) {
          lines.add(_thresholdLine(
            y: vm.sysMax!,
            color: const Color(0xFFE53935),
            label: 'Tối đa: ${vm.sysMax!.toInt()} mmHg',
          ));
        }
        if (vm.sysMin != null) {
          lines.add(_thresholdLine(
            y: vm.sysMin!,
            color: const Color(0xFFE53935),
            label: 'Tối thiểu: ${vm.sysMin!.toInt()} mmHg',
            isDashed: true,
          ));
        }
        // Ngưỡng tâm trương
        if (vm.diaMax != null) {
          lines.add(_thresholdLine(
            y: vm.diaMax!,
            color: const Color(0xFF2028BD),
            label: 'Tối đa: ${vm.diaMax!.toInt()} mmHg',
          ));
        }
        if (vm.diaMin != null) {
          lines.add(_thresholdLine(
            y: vm.diaMin!,
            color: const Color(0xFF2028BD),
            label: 'Tối thiểu: ${vm.diaMin!.toInt()} mmHg',
            isDashed: true,
          ));
        }
        break;

      case 'Đường huyết':
        if (vm.gluMax != null) {
          lines.add(_thresholdLine(
            y: vm.gluMax!,
            color: const Color(0xFFFF8C00),
            label: 'Tối đa: ${vm.gluMax!.toInt()} mg/dL',
          ));
        }
        if (vm.gluMin != null) {
          lines.add(_thresholdLine(
            y: vm.gluMin!,
            color: const Color(0xFFFF8C00),
            label: 'Tối thiểu: ${vm.gluMin!.toInt()} mg/dL',
            isDashed: true,
          ));
        }
        break;

      case 'SpO2':
        if (vm.spo2Min != null) {
          lines.add(_thresholdLine(
            y: vm.spo2Min!,
            color: const Color(0xFF00897B),
            label: 'Tối thiểu: ${vm.spo2Min!.toInt()}%',
            isDashed: true,
          ));
        }
        break;

      default:
        break;
    }

    return lines;
  }

  /// Helper tạo một đường ngưỡng ngang
  HorizontalLine _thresholdLine({
    required double y,
    required Color color,
    required String label,
    bool isDashed = false,
  }) {
    return HorizontalLine(
      y: y,
      color: color.withOpacity(0.7),
      strokeWidth: 1.5,
      dashArray: isDashed ? [6, 4] : null, // nét đứt = min, nét liền = max
      label: HorizontalLineLabel(
        show: true,
        alignment: Alignment.topRight,
        padding: const EdgeInsets.only(right: 4, bottom: 2),
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
        labelResolver: (_) => label,
      ),
    );
  }

  // ─── BarChart (Cân nặng) ──────────────────────────────────────────────────

  Widget _buildBarChart(ChartViewModel vm) {
    final yRange   = vm.maxY - vm.minY;
    final interval = yRange <= 10 ? 1.0 : yRange <= 30 ? 5.0 : 10.0;
    const barColor = Color(0xFF43A047);

    final barGroups = vm.primarySpots.map((spot) {
      return BarChartGroupData(
        x: spot.x.toInt(),
        barRods: [
          BarChartRodData(
            toY: spot.y,
            fromY: vm.minY,
            color: barColor,
            width: vm.isWeekly ? 22 : 8,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        minY: vm.minY,
        maxY: vm.maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: interval,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: Colors.grey.shade200, strokeWidth: 1),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.shade200),
        ),
        titlesData: ChartWidgets.buildTitles(
          leftLabel: vm.unit,
          bottomLabel: vm.isWeekly ? 'Thứ' : 'Ngày',
          interval: interval,
          bottomValues: vm.xLabels,
          totalDays: vm.totalDays,
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) =>
                const Color(0xFF43A047).withOpacity(0.85),
            getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                BarTooltipItem(
                  'Cân nặng\n${rod.toY.toStringAsFixed(1)} kg',
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
          ),
        ),
        barGroups: barGroups,
        // ── Đường ngưỡng cảnh báo cân nặng ──────────────────────────────
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            if (vm.weightMax != null)
              _thresholdLine(
                y: vm.weightMax!,
                color: const Color(0xFF43A047),
                label: 'Tối đa: ${vm.weightMax!.toStringAsFixed(1)} kg',
              ),
            if (vm.weightMin != null)
              _thresholdLine(
                y: vm.weightMin!,
                color: const Color(0xFF43A047),
                label: 'Tối thiểu: ${vm.weightMin!.toStringAsFixed(1)} kg',
                isDashed: true,
              ),
          ],
        ),
      ),
    );
  }
}