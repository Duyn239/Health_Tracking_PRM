import '../../data/models/user_profile.dart';
import '../../interface/repository/isetting_repository.dart';
import '../../interface/service/isetting_service.dart';

class SettingService implements ISettingService {
  final ISettingRepository _repository;

  SettingService(this._repository);

  /// 1. Lấy dữ liệu và chuyển đổi thành Map để ViewModel dễ sử dụng
  @override
  Future<Map<String, double>> getAlertSettingsMap(int accountId) async {
    try {
      final List<Map<String, dynamic>> rawData =
      await _repository.getAlertSettings(accountId);

      // Chuyển đổi List [{key_name: 'sys_max', value: 130}, ...]
      // thành Map {'sys_max': 130.0}
      return {
        for (var item in rawData)
          item['key_name'] as String: (item['value'] as num).toDouble()
      };
    } catch (e) {
      // Log lỗi nếu cần
      return {};
    }
  }

  /// 2. Cập nhật một ngưỡng cụ thể do người dùng chỉnh sửa thủ công
  @override
  Future<bool> updateThreshold(int accountId, String key, double value) async {
    try {
      final result = await _repository.updateAlertSetting(accountId, key, value);
      // Trả về true nếu có ít nhất 1 dòng trong DB được cập nhật
      return result > 0;
    } catch (e) {
      return false;
    }
  }

  /// 3. Khôi phục về ngưỡng mặc định theo logic y khoa
  @override
  Future<bool> resetToDefault(
      int accountId,
      UserProfile profile,
      List<int> diseaseIds,
      ) async {
    try {
      // Chuyển đổi model UserProfile thành Map để tương thích với logic DB cũ
      final Map<String, dynamic> profileMap = profile.toMap();

      // Gọi repository để thực hiện việc tính toán lại (Recalculate)
      // Lưu ý: Repository nên gọi hàm `updateInitialProfile` hoặc logic tương tự
      // mà bạn đã viết trong DatabaseHelper trước đó.
      final result = await _repository.resetThresholdsToDefault(
          accountId,
          profileMap,
          diseaseIds
      );

      return result > 0;
    } catch (e) {
      return false;
    }
  }

  @override
  Map<String, String> validateAlertSettings(Map<String, String> inputData) {
    Map<String, String> errors = {};

    // 1. Hàm helper kiểm tra khoảng giá trị
    String? checkRange(String value, double min, double max, String label) {
      if (value.trim().isEmpty) return 'Vui lòng nhập $label';
      final n = double.tryParse(value);
      if (n == null) return '$label phải là số';
      if (n < min || n > max) return '$label từ $min - $max';
      return null;
    }

    // 2. Validate định dạng và khoảng an toàn
    final configs = {
      'sys_min': [70.0, 150.0, 'Tâm thu tối thiểu'],
      'sys_max': [100.0, 200.0, 'Tâm thu tối đa'],
      'dia_min': [40.0, 100.0, 'Tâm trương tối thiểu'],
      'dia_max': [70.0, 130.0, 'Tâm trương tối đa'],
      'glu_min': [40.0, 150.0, 'Đường huyết tối thiểu'],
      'glu_max': [100.0, 400.0, 'Đường huyết tối đa'],
      'weight_min': [2.0, 150.0, 'Cân nặng tối thiểu'],
      'weight_max': [40.0, 300.0, 'Cân nặng tối đa'],
      'spo2_min': [70.0, 98.0, 'SpO2 tối thiểu'],
      'spo2_max': [90.0, 100.0, 'SpO2 tối đa'],
    };

    configs.forEach((key, config) {
      final error = checkRange(inputData[key] ?? '', config[0] as double, config[1] as double, config[2] as String);
      if (error != null) errors[key] = error;
    });

    // Nếu đã có lỗi định dạng, trả về luôn để tránh lỗi parse số ở bước sau
    if (errors.isNotEmpty) return errors;

    // 3. Kiểm tra logic so sánh (Business Logic)
    double val(String key) => double.parse(inputData[key]!);

    if (val('sys_min') >= val('sys_max')) errors['sys_min'] = "Tâm thu Min phải nhỏ hơn Max";
    if (val('dia_min') >= val('dia_max')) errors['dia_min'] = "Tâm trương Min phải nhỏ hơn Max";
    if (val('sys_min') <= val('dia_min')) errors['sys_min'] = "Tâm thu phải lớn hơn tâm trương";
    if (val('glu_min') >= val('glu_max')) errors['glu_min'] = "Min phải nhỏ hơn Max";
    if (val('weight_min') >= val('weight_max')) errors['weight_min'] = "Min phải nhỏ hơn Max";
    if (val('spo2_min') >= val('spo2_max')) errors['spo2_min'] = "Min phải nhỏ hơn Max";

    return errors;
  }
}