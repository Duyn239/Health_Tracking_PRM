import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/heath_record_vm.dart';
import '../../viewmodels/login_vm.dart';
import '../chart/chart_page.dart';
import '../footer/main_footer.dart';
import '../header/main_header.dart';
import '../home/home_page.dart';
import '../notification/notification_page.dart';
import '../setting/settings_page.dart';
import 'basic_info_modal.dart';
import 'health_record_card.dart';
import 'add_record_modal.dart';

class HealthRecordPage extends StatefulWidget {
  const HealthRecordPage({super.key});

  @override
  State<HealthRecordPage> createState() => _HealthRecordPageState();
}

class _HealthRecordPageState extends State<HealthRecordPage> {
  String selectedValue = 'Huyết áp';
  String selectedSort = 'Mới nhất';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData();
    });
  }

  Future<void> _initData() async {
    final loginVM = context.read<LoginViewModel>();
    final healthVM = context.read<HealthRecordViewModel>();
    final accountId = loginVM.currentAccount?.id;

    if (accountId != null) {
      await healthVM.checkRequirement(
          accountId,
          type: selectedValue,
          descending: selectedSort == 'Mới nhất'
      );
    }
  }

  void _onTypeChanged(String? val) {
    if (val == null) return;
    setState(() => selectedValue = val);
    _triggerFetch();
  }

  void _onSortChanged(String? val) {
    if (val == null) return;
    setState(() => selectedSort = val);
    _triggerFetch();
  }

  void _triggerFetch() {
    final loginVM = context.read<LoginViewModel>();
    final healthVM = context.read<HealthRecordViewModel>();
    if (loginVM.currentAccount?.id != null) {
      healthVM.fetchRecords(
        loginVM.currentAccount!.id!,
        selectedValue,
        descending: selectedSort == 'Mới nhất',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final healthVM = context.watch<HealthRecordViewModel>();
    final isLoading = healthVM.isLoading;
    final needsInfo = healthVM.needsBasicInfo;
    final records = healthVM.records;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const MainHeader(subTitle: "Bản ghi sức khỏe"),
      body: Stack(
        children: [
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  // Đảm bảo nội dung ít nhất phải cao bằng màn hình để Center hoạt động
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // 1. Bộ lọc luôn nằm trên cùng
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSortFilter(),
                            _buildDropdown(),
                          ],
                        ),

                        // 2. Phần nội dung chính (Danh sách hoặc Trạng thái trống)
                        records.isEmpty
                            ? _buildEmptyState(constraints.maxHeight)
                            : Column(
                          children: [
                            const SizedBox(height: 16),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.82,
                              ),
                              itemCount: records.length,
                              itemBuilder: (context, index) {
                                return _renderHealthCardFromDB(records[index]);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // if (needsInfo && !isLoading)
          //   Container(
          //     color: Colors.black.withOpacity(0.5),
          //     width: double.infinity,
          //     height: double.infinity,
          //     child: const Center(child: BasicInfoModal()),
          //   ),

          // Tìm đến đoạn cuối của body trong HealthRecordPage.dart
          if (needsInfo && !isLoading)
          // Sử dụng ModalBarrier để chặn mọi tương tác với lớp dưới
            Stack(
              children: [
                ModalBarrier(
                  dismissible: false, // KHÔNG CHO CHẠM RA NGOÀI ĐỂ TẮT
                  color: Colors.black.withOpacity(0.5), // Làm mờ nền
                ),
                const Center(
                  child: BasicInfoModal(),
                ),
              ],
            ),


        ],
      ),


      floatingActionButton: needsInfo ? null : FloatingActionButton(
        onPressed: () => _showAddRecordSheet(context),
        backgroundColor: const Color(0xFF3C83F6),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),

      bottomNavigationBar: MainFooter(
        currentIndex: 1,
        onTap: (index) {
          if (index == 1) return;
          _navigateTo(index);
        },
      ),
    );
  }

  /// Hàm Build Empty State với logic căn giữa theo chiều cao màn hình
  Widget _buildEmptyState(double availableHeight) {
    return Container(
      // Trừ đi khoảng 150px cho Header và Dropdown để icon nằm đúng trọng tâm màn hình
      constraints: BoxConstraints(minHeight: availableHeight - 150),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.description_outlined, size: 100, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              "Chưa có bản ghi $selectedValue nào",
              style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              "Dữ liệu đo sẽ xuất hiện tại đây.\nNhấn nút (+) để bắt đầu!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _renderHealthCardFromDB(Map<String, dynamic> data) {
    return HealthRecordCard(
      data: data, // Truyền nguyên Map dữ liệu từ DB vào đây
      icon: _getIconForType(data['type'] ?? ""),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'Huyết áp': return Icons.favorite;
      case 'Đường huyết': return Icons.bloodtype;
      case 'Cân nặng': return Icons.balance;
      default: return Icons.opacity;
    }
  }

  Widget _buildSortFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: 45,
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: Colors.white,
          value: selectedSort,
          icon: const Icon(Icons.swap_vert, color: Colors.blue, size: 20),
          items: ['Mới nhất', 'Cũ nhất'].map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
          onChanged: _onSortChanged,
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: 45,
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: Colors.white,
          value: selectedValue,
          icon: const Icon(Icons.filter_list, color: Colors.blue, size: 20),
          items: ['Huyết áp', 'Đường huyết', 'Cân nặng', 'SpO2'].map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
          onChanged: _onTypeChanged,
        ),
      ),
    );
  }

  void _navigateTo(int index) {
    Widget nextPage;
    switch (index) {
      case 0: nextPage = const HomePage(); break;
      case 2: nextPage = const ChartPage(); break;
      case 3: nextPage = const NotificationPage(); break;
      case 4: nextPage = const SettingsPage(); break;
      default: nextPage = const HomePage();
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => nextPage));
  }

  void _showAddRecordSheet(BuildContext context) {
    showDialog(context: context, builder: (context) => const ModalAddRecord());
  }
}