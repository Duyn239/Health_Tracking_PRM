import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/chart_vm.dart';
import '../../viewmodels/login_vm.dart';
import '../header/main_header.dart';
import '../footer/main_footer.dart';
import '../health_record/health_record_page.dart';
import '../home/home_page.dart';
import '../notification/notification_page.dart';
import '../setting/settings_page.dart';
import 'chart_content.dart';
import 'chart_filter_controls.dart';
import 'chart_widgets.dart';

class ChartPage extends StatefulWidget {
  const ChartPage({super.key});

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  final List<String> metrics = ['Huyết áp', 'Đường huyết', 'Cân nặng', 'SpO2'];

  @override
  void initState() {
    super.initState();
    // Tải dữ liệu biểu đồ ngay khi vào trang
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChartData();
    });
  }

  void _loadChartData() {
    final accountId = context.read<LoginViewModel>().currentAccount?.id;
    if (accountId == null) return;
    context.read<ChartViewModel>().fetchChartData(accountId);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const MainHeader(subTitle: 'Biểu đồ thống kê'),
      body: Consumer<ChartViewModel>(
        builder: (context, vm, _) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Bộ lọc Tuần/Tháng và Dropdown chỉ số ──────────────
                  ChartFilterControls(
                    selectedMetric: vm.selectedMetric,
                    metrics: metrics,
                    isWeekly: vm.isWeekly,
                    onMetricChanged: (newMetric) {
                      vm.setMetric(newMetric);
                      _loadChartData();
                    },
                    onPeriodChanged: (weekly) {
                      vm.setPeriod(weekly: weekly);
                      _loadChartData();
                    },
                  ),

                  const SizedBox(height: 20),

                  // ── Thẻ thống kê nhanh (chỉ hiện khi có dữ liệu) ───────
                  if (vm.hasData) _buildStats(vm),

                  const SizedBox(height: 16),

                  // ── Khung biểu đồ ─────────────────────────────────────
                  Container(
                    height: screenHeight * 0.45,
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                      top: 36,
                      right: 30,
                      left: 8,
                      bottom: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.07),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const ChartContentView(),
                  ),

                  const SizedBox(height: 20),

                  // ── Chú thích màu sắc ──────────────────────────────────
                  _buildLegend(vm),

                  const SizedBox(height: 24),

                  // ── Ghi chú khoảng thời gian đang xem ─────────────────
                  Center(
                    child: Text(
                      _getPeriodLabel(vm.isWeekly),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: MainFooter(
        currentIndex: 2,
        onTap: (index) {
          if (index == 2) return;
          Widget nextPage;
          switch (index) {
            case 0:
              nextPage = const HomePage();
              break;
            case 1:
              nextPage = const HealthRecordPage();
              break;
            case 3:
              nextPage = const NotificationPage();
              break;
            case 4:
              nextPage = const SettingsPage();
              break;
            default:
              nextPage = const HomePage();
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => nextPage),
          );
        },
      ),
    );
  }

  /// Thẻ thống kê chung cho tất cả loại chỉ số
  Widget _buildStats(ChartViewModel vm) {
    final unit = vm.unit;

    // Cấu hình màu sắc và nhãn theo từng loại
    Color primaryColor;
    String primaryLabel;
    switch (vm.selectedMetric) {
      case 'Huyết áp':
        primaryColor = const Color(0xFFE53935);
        primaryLabel = 'TB Tâm thu';
        break;
      case 'Đường huyết':
        primaryColor = const Color(0xFFFF8C00);
        primaryLabel = 'TB Đường huyết';
        break;
      case 'Cân nặng':
        primaryColor = const Color(0xFF43A047);
        primaryLabel = 'TB Cân nặng';
        break;
      case 'SpO2':
        primaryColor = const Color(0xFF00897B);
        primaryLabel = 'TB SpO2';
        break;
      default:
        primaryColor = const Color(0xFF379AE6);
        primaryLabel = 'Trung bình';
    }

    final String avgDisplay = vm.avgPrimary != null
        ? '${vm.avgPrimary!.toStringAsFixed(1)} $unit'
        : '--';

    // Giá trị gần nhất: lấy trực tiếp từ bản ghi mới nhất theo thời gian đo
    final String latestDisplay = () {
      if (vm.selectedMetric == 'Huyết áp') {
        final s = vm.latestPrimary?.toStringAsFixed(0) ?? '--';
        final d = vm.latestSecondary?.toStringAsFixed(0) ?? '--';
        return '$s/$d';
      }
      if (vm.selectedMetric == 'SpO2') {
        return vm.latestPrimary != null
            ? '${vm.latestPrimary!.toStringAsFixed(0)} $unit'
            : '--';
      }
      return vm.latestPrimary != null
          ? '${vm.latestPrimary!.toStringAsFixed(1)} $unit'
          : '--';
    }();

    final children = <Widget>[
      Expanded(
        child: ChartWidgets.buildStatCard(
          title: primaryLabel,
          value: avgDisplay,
          color: primaryColor,
        ),
      ),
      // Chỉ Huyết áp mới có cột TB Tâm trương
      if (vm.selectedMetric == 'Huyết áp') ...[
        const SizedBox(width: 10),
        Expanded(
          child: ChartWidgets.buildStatCard(
            title: 'TB Tâm trương',
            value: vm.avgSecondary != null
                ? '${vm.avgSecondary!.toStringAsFixed(0)} $unit'
                : '--',
            color: const Color(0xFF2028BD),
          ),
        ),
      ],
      const SizedBox(width: 10),
      Expanded(
        child: ChartWidgets.buildStatCard(
          title: 'Gần nhất',
          value: latestDisplay,
          color: const Color(0xFF379AE6),
        ),
      ),
    ];

    return Row(children: children);
  }

  /// Chú thích màu sắc phía dưới biểu đồ
  Widget _buildLegend(ChartViewModel vm) {
    switch (vm.selectedMetric) {
      case 'Huyết áp':
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ChartWidgets.buildLegendItem('Tâm thu', const Color(0xFFE53935)),
            const SizedBox(width: 28),
            ChartWidgets.buildLegendItem('Tâm trương', const Color(0xFF2028BD)),
          ],
        );
      case 'Đường huyết':
        return ChartWidgets.buildLegendItem(
            'Đường huyết', const Color(0xFFFF8C00));
      case 'Cân nặng':
        return ChartWidgets.buildLegendItem(
            'Cân nặng', const Color(0xFF43A047));
      case 'SpO2':
        return ChartWidgets.buildLegendItem(
            'SpO2', const Color(0xFF00897B));
      default:
        return const SizedBox.shrink();
    }
  }

  String _getPeriodLabel(bool isWeekly) {
    final now = DateTime.now();
    if (isWeekly) {
      final start = now.subtract(Duration(days: now.weekday - 1));
      final end = start.add(const Duration(days: 6));
      return '${start.day}/${start.month} – ${end.day}/${end.month}/${end.year}';
    } else {
      return 'Tháng ${now.month}/${now.year}';
    }
  }
}