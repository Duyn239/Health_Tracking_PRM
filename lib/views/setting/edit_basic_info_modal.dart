import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/models/user_profile.dart';
import '../../viewmodels/alert_setting_vm.dart';
import '../../viewmodels/heath_record_vm.dart';
import '../../viewmodels/login_vm.dart';
import '../../viewmodels/profile_vm.dart';

class EditBasicInfoModal extends StatefulWidget {
  const EditBasicInfoModal({super.key});

  @override
  State<EditBasicInfoModal> createState() => _EditBasicInfoModalState();
}

class _EditBasicInfoModalState extends State<EditBasicInfoModal> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  String? _selectedGender;

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentData();
    });
  }

  void _loadCurrentData() {
    final profileVM = context.read<ProfileViewModel>();
    final profile = profileVM.userProfile;

    if (profile != null) {
      setState(() {
        _dobController.text = profile.dob ?? "";
        _selectedGender = profile.gender;
        _heightController.text = profile.height?.toInt().toString() ?? "";
        _weightController.text = profile.weight?.toString() ?? "";

        String currentDiseases = profileVM.getDiseasesDisplay();
        _conditions.forEach((key, value) {
          if (currentDiseases.contains(key)) {
            _conditions[key] = true;
          }
        });
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime(2000);
    if (_dobController.text.isNotEmpty) {
      try {
        initialDate = DateFormat('dd/MM/yyyy').parse(_dobController.text);
      } catch (_) {}
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _handleSave() async {
    if (_formKey.currentState!.validate()) {
      final loginVM = context.read<LoginViewModel>();
      final healthVM = context.read<HealthRecordViewModel>();
      final profileVM = context.read<ProfileViewModel>();
      final alertVM = context.read<AlertSettingViewModel>();

      final accountId = loginVM.currentAccount?.id;
      if (accountId == null) return;

      List<int> selectedIds = [];
      _conditions.forEach((key, value) {
        if (value) selectedIds.add(_diseaseMap[key]!);
      });

      final currentFullName = profileVM.userProfile?.fullName;

      final profile = UserProfile(
        accountId: accountId,
        fullName: currentFullName,
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
        await alertVM.resetToDefault(accountId, profile, selectedIds);
        await profileVM.fetchProfile(accountId);

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Thông tin và ngưỡng cảnh báo đã được cập nhật"),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.white,
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'Chỉnh sửa chỉ số cơ bản',
                        style: TextStyle(
                            color: Color(0xFF379AE6),
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Divider(),
                    const SizedBox(height: 10),

                    _buildLabel("1. Ngày sinh"),
                    TextFormField(
                      controller: _dobController,
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      decoration: _inputStyle("Ngày/tháng/năm"),
                      validator: (v) => (v == null || v.isEmpty) ? "Vui lòng chọn ngày sinh" : null,
                    ),

                    const SizedBox(height: 15),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("2. Giới tính"),
                              DropdownButtonFormField<String>(
                                value: _selectedGender,
                                dropdownColor: Colors.white,
                                items: ["Nam", "Nữ"].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
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
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly, // CHỈ cho phép chữ số (0-9)
                                ],
                                decoration: _inputStyle("VD: 170"),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return "Bắt buộc";
                                  final h = double.tryParse(v);
                                  if (h == null) return "Số không hợp lệ";
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

                    _buildLabel("4. Cân nặng (kg)"),
                    TextFormField(
                      controller: _weightController,
                      // Cho phép hiện bàn phím số có dấu chấm
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: _inputStyle("VD: 60.5"),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}')),
                      ],
                      validator: (v) {
                        if (v == null || v.isEmpty) return "Vui lòng nhập cân nặng";
                        final w = double.tryParse(v);
                        if (w == null) return "Phải là số";
                        if (w < 2 || w > 300) return "Từ 2-300kg";
                        return null;
                      },
                    ),

                    const SizedBox(height: 15),

                    _buildLabel("5. Bạn có tình trạng nào sau đây không?", isRequired: false),
                    ..._conditions.keys.map((key) => _buildCheckboxRow(key)).toList(),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _handleSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3C83F6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text("Lưu thay đổi", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 4,
            top: 4,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      errorStyle: const TextStyle(fontSize: 10, color: Colors.redAccent),
    );
  }

  Widget _buildLabel(String text, {bool isRequired = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.w500),
          children: [if (isRequired) const TextSpan(text: ' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))],
        ),
      ),
    );
  }

  Widget _buildCheckboxRow(String title) {
    return SizedBox(
      height: 35,
      child: Row(
        children: [
          Checkbox(
            value: _conditions[title],
            activeColor: const Color(0xFF379AE6),
            onChanged: (v) => setState(() => _conditions[title] = v!),
          ),
          Text(title, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}