import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/models/health_record.dart';
import '../../viewmodels/heath_record_vm.dart';
import '../../viewmodels/login_vm.dart';

class ModalAddRecord extends StatefulWidget {
  const ModalAddRecord({super.key});

  @override
  State<ModalAddRecord> createState() => _ModalAddRecordState();
}

class _ModalAddRecordState extends State<ModalAddRecord> {
  final _formKey = GlobalKey<FormState>();
  String selectedType = 'Huyết áp';

  // Controllers
  final TextEditingController _val1Controller = TextEditingController();
  final TextEditingController _val2Controller = TextEditingController();
  final TextEditingController _val3Controller = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  DateTime selectedDateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _dateController.text = "";
  }

  // --- HÀM VALIDATE CHI TIẾT ---
  String? _validateRange(String? value, double min, double max, String label) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập $label';
    }
    final n = double.tryParse(value);
    if (n == null) {
      return '$label phải là định dạng số';
    }
    if (n < min || n > max) {
      return '$label hợp lệ từ $min đến $max';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),


        child: Form(
          key: _formKey, // Form quản lý trạng thái lỗi
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const Divider(height: 1, thickness: 1),
                  const SizedBox(height: 20),

                  _buildLabel('Loại chỉ số'),
                  const SizedBox(height: 8),
                  _buildTypeDropdown(),
                  const SizedBox(height: 20),

                  _buildDynamicFields(),
                  const SizedBox(height: 20),

                  _buildRequiredLabel('Thời điểm đo'),
                  const SizedBox(height: 8),
                  _buildDateTimePicker(),
                  const SizedBox(height: 20),

                  _buildLabel('Ghi chú (tùy chọn)'),
                  const SizedBox(height: 8),
                  _buildNoteField(),
                  const SizedBox(height: 30),

                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: Colors.white,
          isExpanded: true,
          value: selectedType,
          items: ['Huyết áp', 'Đường huyết', 'Cân nặng', 'SpO2']
              .map((val) => DropdownMenuItem(value: val, child: Text(val)))
              .toList(),
          onChanged: (val) {
            setState(() {
              selectedType = val!;
              // XÓA TRẠNG THÁI LỖI: Khi đổi loại, reset form để các ô đỏ biến mất
              _formKey.currentState?.reset();

              _val1Controller.clear();
              _val2Controller.clear();
              _val3Controller.clear();
            });
          },
        ),
      ),
    );
  }

  Widget _buildDynamicFields() {
    if (selectedType == 'Huyết áp') {
      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: _buildInputField(
                      'Tâm thu',
                      'mmHg',
                      _val1Controller,
                          (v) => _validateRange(v, 70, 200, 'chỉ số tâm thu')
                  )
              ),
              const SizedBox(width: 10),
              Expanded(
                  child: _buildInputField(
                      'Tâm trương',
                      'mmHg',
                      _val2Controller,
                          (v) {
                        final err = _validateRange(v, 40, 130, 'chỉ số tâm trương');
                        if (err != null) return err;

                        // So sánh tâm thu và tâm trương
                        final sys = double.tryParse(_val1Controller.text) ?? 0;
                        final dia = double.tryParse(v!) ?? 0;
                        if (dia >= sys && sys > 0) {
                          return 'Tâm trương phải nhỏ hơn tâm thu';
                        }
                        return null;
                      }
                  )
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInputField(
            'Nhịp tim',
            'bpm',
            _val3Controller,
                (v) => _validateRange(v, 30, 200, 'nhịp tim'),
            isIntegerOnly: true, // Thêm flag này để biết là chỉ nhận số nguyên
          ),
        ],
      );
    }

    String label = "";
    String unit = "";
    String? Function(String?)? validator;

    switch (selectedType) {
      case 'Đường huyết':
        label = "Giá trị Đường huyết"; unit = "mg/dL";
        validator = (v) => _validateRange(v, 10, 600, 'chỉ số đường huyết');
        break;
      case 'Cân nặng':
        label = "Cân nặng hiện tại"; unit = "kg";
        validator = (v) => _validateRange(v, 2, 300, 'trọng lượng cơ thể');
        break;
      case 'SpO2':
        label = "Chỉ số SpO2"; unit = "%";
        validator = (v) => _validateRange(v, 50, 100, 'nồng độ oxy (SpO2)');
        break;
    }

    return _buildInputField(label, unit, _val1Controller, validator);
  }

  // --- CÁC WIDGET PHỤ TRỢ ---

  Widget _buildInputField(
      String label,
      String hint,
      TextEditingController controller,
      String? Function(String?)? validator,
      {bool isIntegerOnly = false} // Mặc định là false cho các chỉ số khác
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRequiredLabel(label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          // Nếu là số nguyên thì dùng bàn phím số thuần túy, không có dấu thập phân
          keyboardType: isIntegerOnly
              ? TextInputType.number
              : const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(fontSize: 14),
          inputFormatters: [
            isIntegerOnly
                ? FilteringTextInputFormatter.digitsOnly // Chặn mọi ký tự không phải số (bao gồm dấu . và ,)
                : FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            errorMaxLines: 2,
            errorStyle: const TextStyle(fontSize: 11, color: Colors.redAccent),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Stack(
      alignment: Alignment.center,
      children: [
        const Text(
          'Thêm bản ghi mới',
          style: TextStyle(color: Color(0xFF379AE6), fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _dateController,
          readOnly: true,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Chọn ngày và giờ đo',
            hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
            suffixIcon: const Icon(Icons.calendar_month, size: 20, color: Color(0xFF379AE6)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            errorStyle: const TextStyle(fontSize: 11, color: Colors.redAccent),
          ),
          // --- THÊM VALIDATE Ở ĐÂY ---
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng chọn thời gian thực hiện phép đo';
            }
            return null;
          },
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime.now(), // Không cho chọn ngày ở tương lai
            );
            if (pickedDate != null) {
              TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (pickedTime != null) {
                setState(() {
                  selectedDateTime = DateTime(
                    pickedDate.year,
                    pickedDate.month,
                    pickedDate.day,
                    pickedTime.hour,
                    pickedTime.minute,
                  );
                  _dateController.text = DateFormat('dd/MM/yyyy HH:mm').format(selectedDateTime);
                });
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildNoteField() {
    return TextFormField(
      controller: _noteController,
      maxLines: 2,
      decoration: InputDecoration(
        hintText: 'Nhập tình trạng sức khỏe hiện tại...',
        hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Hủy', style: TextStyle(color: Colors.black54)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _submitData,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF379AE6),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Lưu bản ghi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  void _submitData() async {
    if (_formKey.currentState!.validate()) {
      final loginVM = context.read<LoginViewModel>();
      final healthVM = context.read<HealthRecordViewModel>();
      final accountId = loginVM.currentAccount?.id;

      if (accountId == null) return;

      // Xác định đơn vị dựa trên loại chỉ số
      String unit = "";
      switch (selectedType) {
        case 'Huyết áp': unit = "mmHg"; break;
        case 'Đường huyết': unit = "mg/dL"; break;
        case 'Cân nặng': unit = "kg"; break;
        case 'SpO2': unit = "%"; break;
      }

      final newRecord = HealthRecord(
        accountId: accountId,
        type: selectedType,
        value1: double.parse(_val1Controller.text),
        value2: selectedType == 'Huyết áp' ? double.tryParse(_val2Controller.text) : null,
        heartRate: selectedType == 'Huyết áp' ? int.tryParse(_val3Controller.text) : null,
        unit: unit, // unit xác định dựa trên selectedType
        note: _noteController.text.trim(),
        measuredAt: selectedDateTime.toIso8601String(),
      );

      bool success = await healthVM.addNewRecord(newRecord);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  "Đã lưu bản ghi $selectedType thành công !!",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            duration: const Duration(seconds: 2),
          ),
        );

        Navigator.pop(context);
      }
    }
  }

  Widget _buildLabel(String label) {
    return Text(label, style: const TextStyle(color: Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.w500));
  }

  Widget _buildRequiredLabel(String label) {
    return RichText(
      text: TextSpan(
        text: label,
        style: const TextStyle(color: Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.w500),
        children: const [TextSpan(text: ' *', style: TextStyle(color: Colors.red))],
      ),
    );
  }
}