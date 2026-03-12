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
    clearData(); // <--- Xóa sạch dữ liệu cũ ngay khi bắt đầu load cho ID mới
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


  // Map lưu trữ thông báo lỗi cho từng trường (Key khớp với controllers)
  Map<String, String?> errors = {};

  // Hàm xóa sạch lỗi (Dùng khi ấn Hủy hoặc bắt đầu Validate mới)
  void clearErrors() {
    errors.clear();
    notifyListeners();
  }

  bool validateSettings() {
    // 1. Thu thập dữ liệu từ các Controller thành Map<String, String>
    Map<String, String> inputData = controllers.map((key, controller) => MapEntry(key, controller.text));

    // 2. Gọi Service check logic
    final result = _service.validateAlertSettings(inputData);

    // 3. Cập nhật kết quả lỗi lên UI
    errors = result;
    notifyListeners();

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


  // xóa data trong các controller để account mới k bị dính data cũ
  void clearData() {
    for (var controller in controllers.values) {
      controller.clear();
    }
    errors.clear();
    _isLoading = false;
    // Không cần notifyListeners ở đây vì ProxyProvider sẽ xử lý sau đó
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