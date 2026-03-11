import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/models/health_record.dart';
import '../../viewmodels/heath_record_vm.dart';

class EditRecordModal extends StatefulWidget {
  final HealthRecord record;

  const EditRecordModal({super.key, required this.record});

  @override
  State<EditRecordModal> createState() => _EditRecordModalState();
}

class _EditRecordModalState extends State<EditRecordModal> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _val1Controller;
  late TextEditingController _val2Controller;
  late TextEditingController _val3Controller;
  late TextEditingController _dateController;
  late TextEditingController _noteController;

  late DateTime selectedDateTime;

  @override
  void initState() {
    super.initState();
    _val1Controller = TextEditingController(text: _formatValue(widget.record.value1));
    _val2Controller = TextEditingController(text: _formatValue(widget.record.value2));
    _val3Controller = TextEditingController(text: widget.record.heartRate?.toString() ?? "");
    _noteController = TextEditingController(text: widget.record.note ?? "");

    selectedDateTime = DateTime.parse(widget.record.measuredAt);
    _dateController = TextEditingController(
      text: DateFormat('dd/MM/yyyy HH:mm').format(selectedDateTime),
    );
  }

  String _formatValue(double? v) {
    if (v == null) return "";
    return v == v.toInt() ? v.toInt().toString() : v.toString();
  }

  @override
  void dispose() {
    _val1Controller.dispose();
    _val2Controller.dispose();
    _val3Controller.dispose();
    _dateController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String? _validateRange(String? value, double min, double max, String label) {
    if (value == null || value.trim().isEmpty) {
      return 'Trống';
    }
    final n = double.tryParse(value);
    if (n == null) {
      return 'Phải là số';
    }
    if (n < min || n > max) {
      return 'Từ $min - $max';
    }
    return null;
  }

  Future<void> _handleUpdate() async {
    if (_formKey.currentState!.validate()) {
      final healthVM = context.read<HealthRecordViewModel>();

      final updatedRecord = HealthRecord(
        id: widget.record.id,
        accountId: widget.record.accountId,
        type: widget.record.type,
        value1: double.parse(_val1Controller.text),
        value2: widget.record.type == 'Huyết áp' ? double.tryParse(_val2Controller.text) : null,
        heartRate: widget.record.type == 'Huyết áp' ? int.tryParse(_val3Controller.text) : null,
        unit: widget.record.unit,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        measuredAt: selectedDateTime.toIso8601String(),
      );

      bool success = await healthVM.updateExistingRecord(updatedRecord);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text("Cập nhật thành công !!"),
              ],
            ),
            backgroundColor: Colors.green.shade600,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      title: _buildHeader(),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInputLabel("Thời điểm đo"),
                _buildDateTimePicker(),
                const SizedBox(height: 12),

                ..._buildDynamicFields(),
                const SizedBox(height: 12),

                _buildInputLabel("Ghi chú", isRequired: false),
                _buildNoteField(),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
      actions: _buildActions(),
    );
  }

  List<Widget> _buildDynamicFields() {
    if (widget.record.type == "Huyết áp") {
      return [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start, // Căn trên cùng để khi có lỗi không bị lệch hàng
          children: [
            Expanded(
              child: _buildInputField(
                  _val1Controller,
                  "Tâm thu",
                  "mmHg",
                      (v) => _validateRange(v, 70, 200, 'tâm thu')
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildInputField(
                  _val2Controller,
                  "Tâm trương",
                  "mmHg",
                      (v) {
                    final err = _validateRange(v, 40, 130, 'tâm trương');
                    if (err != null) return err;
                    final sys = double.tryParse(_val1Controller.text) ?? 0;
                    final dia = double.tryParse(v!) ?? 0;
                    if (dia >= sys && sys > 0) return 'Phải < Thu';
                    return null;
                  }
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildInputField(
            _val3Controller,
            "Nhịp tim",
            "bpm",
                (v) => _validateRange(v, 30, 200, 'nhịp tim'),
            isInteger: true
        ),
      ];
    }

    String label = widget.record.type;
    String? Function(String?)? validator;
    switch (widget.record.type) {
      case 'Đường huyết':
        validator = (v) => _validateRange(v, 10, 600, 'đường huyết');
        break;
      case 'Cân nặng':
        validator = (v) => _validateRange(v, 2, 300, 'cân nặng');
        break;
      case 'SpO2':
        validator = (v) => _validateRange(v, 50, 100, 'SpO2');
        break;
    }
    return [
      _buildInputField(_val1Controller, label, widget.record.unit, validator)
    ];
  }

  Widget _buildInputField(
      TextEditingController controller,
      String label,
      String hint,
      String? Function(String?)? validator,
      {bool isInteger = false}
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputLabel(label),
        TextFormField(
          controller: controller,
          keyboardType: isInteger
              ? TextInputType.number
              : const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            isInteger
                ? FilteringTextInputFormatter.digitsOnly
                : FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          decoration: _inputDecoration(hint: hint),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDateTimePicker() {
    return TextFormField(
      controller: _dateController,
      readOnly: true,
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: selectedDateTime,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null) {
          TimeOfDay? pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(selectedDateTime),
          );
          if (pickedTime != null) {
            setState(() {
              selectedDateTime = DateTime(pickedDate.year, pickedDate.month,
                  pickedDate.day, pickedTime.hour, pickedTime.minute);
              _dateController.text = DateFormat('dd/MM/yyyy HH:mm').format(selectedDateTime);
            });
          }
        }
      },
      decoration: _inputDecoration(hint: "Chọn lịch", suffixIcon: Icons.calendar_today),
      validator: (v) => (v == null || v.isEmpty) ? "Trống" : null,
    );
  }

  Widget _buildNoteField() {
    return TextFormField(
      controller: _noteController,
      maxLines: 2,
      decoration: _inputDecoration(hint: "Nhập ghi chú..."),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Text('Chỉnh sửa bản ghi',
                  style: TextStyle(color: Color(0xFF379AE6), fontSize: 18, fontWeight: FontWeight.bold)),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 0.5),
      ],
    );
  }

  InputDecoration _inputDecoration({required String hint, IconData? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
      suffixIcon: suffixIcon != null ? Icon(suffixIcon, size: 20, color: Color(0xFF379AE6)) : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14), // Tăng vertical padding
      isDense: false, // Tắt isDense để errorText không bị ép không gian
      errorMaxLines: 2, // Cho phép lỗi xuống dòng
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300)
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      errorStyle: const TextStyle(fontSize: 11, color: Colors.redAccent, height: 1.0),
    );
  }

  Widget _buildInputLabel(String label, {bool isRequired = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          text: label,
          style: const TextStyle(color: Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.w500),
          children: [if (isRequired) const TextSpan(text: ' *', style: TextStyle(color: Colors.red))],
        ),
      ),
    );
  }

  List<Widget> _buildActions() {
    return [
      Padding(
        padding: const EdgeInsets.only(bottom: 12, right: 12, left: 12),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12)
                ),
                child: const Text("Hủy", style: TextStyle(color: Colors.black54)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _handleUpdate,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF379AE6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12)
                ),
                child: const Text("Cập nhật", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    ];
  }
}