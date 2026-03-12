import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/models/user_profile.dart';
import '../../viewmodels/heath_record_vm.dart';
import '../../viewmodels/login_vm.dart';

class BasicInfoModal extends StatefulWidget {
  const BasicInfoModal({super.key});

  @override
  State<BasicInfoModal> createState() => _BasicInfoModalState();
}

class _BasicInfoModalState extends State<BasicInfoModal> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  String? _selectedGender;
  DateTime? _selectedDate;

  // Mapping bệnh lý
  final Map<String, int> _diseaseMap = {
    'Tăng huyết áp': 1,
    'Tiểu đường': 2,
    'Bệnh tim mạch': 3,
    'Bệnh hô hấp': 4,
  };

  final Map<String, bool> _conditions = {
    "Tăng huyết áp": false,
    "Tiểu đường": false,
    "Bệnh tim mạch": false,
    "Bệnh hô hấp": false,
  };

  // Hàm chọn ngày sinh với giới hạn thực tế
  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20), // Gợi ý mặc định 20 tuổi
      firstDate: DateTime(now.year - 120), // Giới hạn tối đa 120 tuổi
      lastDate: now,
      helpText: "CHỌN NGÀY SINH",
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _handleSave() async {
    if (_formKey.currentState!.validate()) {
      final loginVM = context.read<LoginViewModel>();
      final healthVM = context.read<HealthRecordViewModel>();
      final accountId = loginVM.currentAccount?.id;

      if (accountId == null) return;

      List<int> selectedIds = [];
      _conditions.forEach((key, value) {
        if (value) selectedIds.add(_diseaseMap[key]!);
      });

      final profile = UserProfile(
        accountId: accountId,
        dob: _dobController.text,
        gender: _selectedGender,
        height: double.tryParse(_heightController.text),
        weight: double.tryParse(_weightController.text),
      );

      bool success = await healthVM.handleSaveBasicInfo(
        accountId: accountId,
        profile: profile,
        diseaseIds: selectedIds,
      );

      if (success && mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // CHẶN NÚT BACK HỆ THỐNG
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Thiết lập sức khỏe ban đầu',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color(0xFF379AE6),
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Divider(),
                  const SizedBox(height: 15),

                  // 1. Ngày sinh
                  _buildLabel("1. Ngày sinh"),
                  TextFormField(
                    controller: _dobController,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    decoration: _inputStyle("Chọn ngày/tháng/năm"),
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Vui lòng chọn ngày sinh";
                      return null;
                    },
                  ),

                  const SizedBox(height: 15),

                  // 2. Giới tính & 3. Chiều cao
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("2. Giới tính"),
                            DropdownButtonFormField<String>(
                              dropdownColor: Colors.white,
                              value: _selectedGender,
                              items: ["Nam", "Nữ"]
                                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                                  .toList(),
                              onChanged: (v) => setState(() => _selectedGender = v),
                              decoration: _inputStyle("Chọn"),
                              validator: (v) => v == null ? "Cần chọn" : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("3. Chiều cao (cm)"),
                            TextFormField(
                              controller: _heightController,
                              keyboardType: TextInputType.number,
                              decoration: _inputStyle("VD: 170"),
                              validator: (v) {
                                if (v == null || v.isEmpty) return "Bắt buộc";
                                final h = double.tryParse(v);
                                if (h == null) return "Phải là số";
                                if (h < 50 || h > 250) return "Từ 50-250cm";
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // 4. Cân nặng
                  _buildLabel("4. Cân nặng (kg)"),
                  TextFormField(
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: _inputStyle("VD: 60.5"),
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Vui lòng nhập cân nặng";
                      final w = double.tryParse(v);
                      if (w == null) return "Phải là số";
                      if (w < 2 || w > 300) return "Từ 2-300kg";
                      return null;
                    },
                  ),

                  const SizedBox(height: 15),

                  // 5. Bệnh nền
                  _buildLabel("5. Tiền sử bệnh lý (nếu có)", isRequired: false),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: _conditions.keys.map((key) => _buildCheckboxRow(key)).toList(),
                    ),
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3C83F6),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("HOÀN TẤT THIẾT LẬP",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),

                  const SizedBox(height: 15),
                  const Text(
                    "* Bạn cần nhập các thông tin cơ bản trên để hệ thống có cơ sở tính toán và cảnh báo sức khỏe chính xác.",
                    style: TextStyle(fontSize: 11, color: Colors.redAccent, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
      errorStyle: const TextStyle(fontSize: 10, color: Colors.redAccent),
      filled: true,
      fillColor: Colors.white,
    );
  }

  Widget _buildLabel(String text, {bool isRequired = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B), fontWeight: FontWeight.w600),
          children: [if (isRequired) const TextSpan(text: ' *', style: TextStyle(color: Colors.red))],
        ),
      ),
    );
  }

  Widget _buildCheckboxRow(String title) {
    return InkWell(
      onTap: () => setState(() => _conditions[title] = !_conditions[title]!),
      child: Row(
        children: [
          Checkbox(
            value: _conditions[title],
            activeColor: const Color(0xFF3C83F6),
            onChanged: (v) => setState(() => _conditions[title] = v!),
          ),
          Text(title, style: const TextStyle(fontSize: 14, color: Color(0xFF475569))),
        ],
      ),
    );
  }
}