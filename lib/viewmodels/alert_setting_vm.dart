import 'package:flutter/material.dart';
import '../../data/models/user_profile.dart';
import '../../interface/service/isetting_service.dart';

class AlertSettingViewModel extends ChangeNotifier {
  final ISettingService _service;

  AlertSettingViewModel(this._service);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // 1. Quản lý tập trung các Controller để UI không bị reset khi Rebuild
  final Map<String, TextEditingController> controllers = {
    'sys_min': TextEditingController(),
    'sys_max': TextEditingController(),
    'dia_min': TextEditingController(),
    'dia_max': TextEditingController(),
    'glu_min': TextEditingController(),
    'glu_max': TextEditingController(),
    'weight_min': TextEditingController(),
    'weight_max': TextEditingController(),
    'spo2_min': TextEditingController(),
    'spo2_max': TextEditingController(),
  };

  /// 2. Hàm Tải dữ liệu từ Service và đổ vào các Controller
  Future<void> loadSettings(int accountId) async {
    _setLoading(true);
    try {
      final settings = await _service.getAlertSettingsMap(accountId);

      // Đổ dữ liệu vào từng controller tương ứng với key trong DB
      settings.forEach((key, value) {
        if (controllers.containsKey(key)) {
          // Xử lý hiển thị số đẹp: 130.0 -> "130", 60.5 -> "60.5"
          controllers[key]!.text = value % 1 == 0
              ? value.toInt().toString()
              : value.toString();
        }
      });
    } catch (e) {
      debugPrint("Lỗi loadSettings: $e");
    } finally {
      _setLoading(false);
    }
  }

  /// 3. Hàm Lưu tất cả thay đổi từ các ô nhập liệu vào Database
  Future<bool> saveAllSettings(int accountId) async {
    _setLoading(true);
    try {
      bool allSuccess = true;

      // Duyệt qua tất cả controller để lưu từng cái một
      for (var entry in controllers.entries) {
        double? val = double.tryParse(entry.value.text);
        if (val != null) {
          final success = await _service.updateThreshold(accountId, entry.key, val);
          if (!success) allSuccess = false;
        }
      }
      return allSuccess;
    } catch (e) {
      debugPrint("Lỗi saveAllSettings: $e");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // String? validateSettings() {
  //   // Hàm trợ giúp lấy giá trị số từ controller
  //   double? getValue(String key) => double.tryParse(controllers[key]?.text ?? '');
  //
  //   // --- 1. Kiểm tra nhập liệu trống hoặc sai định dạng ---
  //   for (var entry in controllers.entries) {
  //     if (entry.value.text.trim().isEmpty) {
  //       return "Vui lòng không để trống các ô nhập liệu";
  //     }
  //     if (double.tryParse(entry.value.text) == null) {
  //       return "Dữ liệu tại '${entry.key}' phải là chữ số";
  //     }
  //   }
  //
  //   // --- 2. Logic Huyết Áp ---
  //   double sMin = getValue('sys_min')!;
  //   double sMax = getValue('sys_max')!;
  //   double dMin = getValue('dia_min')!;
  //   double dMax = getValue('dia_max')!;
  //
  //   if (sMin >= sMax) return "Huyết áp: Tâm thu tối thiểu phải nhỏ hơn tối đa";
  //   if (dMin >= dMax) return "Huyết áp: Tâm trương tối thiểu phải nhỏ hơn tối đa";
  //   if (sMin <= dMin) return "Huyết áp: Chỉ số Tâm thu phải lớn hơn Tâm trương";
  //
  //   // --- 3. Logic Đường huyết ---
  //   double gMin = getValue('glu_min')!;
  //   double gMax = getValue('glu_max')!;
  //   if (gMin >= gMax) return "Đường huyết: Giá trị tối thiểu phải nhỏ hơn tối đa";
  //
  //   // --- 4. Logic Cân nặng ---
  //   double wMin = getValue('weight_min')!;
  //   double wMax = getValue('weight_max')!;
  //   if (wMin >= wMax) return "Cân nặng: Giá trị tối thiểu phải nhỏ hơn tối đa";
  //   if (wMin <= 0) return "Cân nặng phải lớn hơn 0";
  //
  //   // --- 5. Logic SpO2 ---
  //   double spMin = getValue('spo2_min')!;
  //   double spMax = getValue('spo2_max')!;
  //   if (spMin >= spMax) return "SpO2: Giá trị tối thiểu phải nhỏ hơn tối đa";
  //   if (spMax > 100) return "SpO2 không thể vượt quá 100%";
  //   if (spMin < 0) return "SpO2 không thể là số âm";
  //
  //   return null; // Mọi thứ đều ổn
  // }

  // Map lưu trữ thông báo lỗi cho từng trường (Key khớp với controllers)
  Map<String, String?> errors = {};

  // Hàm xóa sạch lỗi (Dùng khi ấn Hủy hoặc bắt đầu Validate mới)
  void clearErrors() {
    errors.clear();
    notifyListeners();
  }

  bool validateSettings() {
    // 1. Xóa toàn bộ lỗi cũ trước khi kiểm tra
    errors.clear();

    double? getValue(String key) => double.tryParse(controllers[key]?.text ?? '');

    // --- 2. Kiểm tra nhập liệu trống ---
    controllers.forEach((key, controller) {
      if (controller.text.trim().isEmpty) {
        errors[key] = "Không được để trống";
      } else if (double.tryParse(controller.text) == null) {
        errors[key] = "Phải là chữ số";
      }
    });

    // Nếu đã có lỗi trống thì dừng để người dùng nhập đủ đã, tránh lỗi logic bên dưới
    if (errors.isNotEmpty) {
      notifyListeners();
      return false;
    }

    // --- 3. Logic Huyết Áp ---
    double sMin = getValue('sys_min')!;
    double sMax = getValue('sys_max')!;
    double dMin = getValue('dia_min')!;
    double dMax = getValue('dia_max')!;

    if (sMin >= sMax) errors['sys_min'] = "Tâm thu: Min ≥ Max";
    if (dMin >= dMax) errors['dia_min'] = "Tâm trương: Min ≥ Max";
    if (sMin <= dMin) errors['sys_min'] = "Tâm thu phải > Tâm trương";

    // --- 4. Logic Đường huyết ---
    if (getValue('glu_min')! >= getValue('glu_max')!) {
      errors['glu_min'] = "Giá trị Min ≥ Max";
    }

    // --- 5. Logic Cân nặng ---
    double wMin = getValue('weight_min')!;
    if (wMin >= getValue('weight_max')!) errors['weight_min'] = "Giá trị Min ≥ Max";
    if (wMin <= 0) errors['weight_min'] = "Cân nặng phải > 0";

    // --- 6. Logic SpO2 ---
    double spMin = getValue('spo2_min')!;
    double spMax = getValue('spo2_max')!;
    if (spMin >= spMax) errors['spo2_min'] = "Giá trị Min ≥ Max";
    if (spMax > 100) errors['spo2_max'] = "SpO2 không quá 100%";
    if (spMin < 0) errors['spo2_min'] = "Không được là số âm";

    // Cập nhật giao diện để hiện chữ đỏ
    notifyListeners();

    // Trả về true nếu không có bất kỳ lỗi nào
    return errors.isEmpty;
  }

  /// 4. Hàm Khôi phục mặc định (Reset) dựa trên UserProfile
  Future<bool> resetToDefault(int accountId, UserProfile profile, List<int> diseaseIds) async {
    _setLoading(true);
    try {
      // Gọi service thực hiện reset trong DB
      bool success = await _service.resetToDefault(accountId, profile, diseaseIds);

      if (success) {
        // Sau khi reset trong DB thành công, load lại để cập nhật con số mới lên TextField
        await loadSettings(accountId);
      }
      return success;
    } catch (e) {
      debugPrint("Lỗi resetToDefault: $e");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Hàm helper để quản lý trạng thái loading
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Đừng quên dispose các controller để tránh rò rỉ bộ nhớ (Memory Leak)
  @override
  void dispose() {
    for (var c in controllers.values) {
      c.dispose();
    }
    super.dispose();
  }
}