import 'package:flutter/cupertino.dart';
import '../data/models/health_record.dart';
import '../data/models/user_profile.dart';
import '../interface/service/ihealth_record_service.dart';

class HealthRecordViewModel extends ChangeNotifier {
  final IHealthRecordService _service;

  // Trạng thái loading để hiển thị ProgressIndicator trên UI
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Cờ kiểm tra xem user có cần nhập thông tin cơ bản (chiều cao, cân nặng...) không
  bool _needsBasicInfo = false;
  bool get needsBasicInfo => _needsBasicInfo;

  // Danh sách các bản ghi sức khỏe (Huyết áp, Đường huyết...) lấy từ DB
  List<Map<String, dynamic>> _records = [];
  List<Map<String, dynamic>> get records => _records;

  // Quản lý trạng thái sắp xếp (Mới nhất: true/DESC, Cũ nhất: false/ASC)
  bool _isDescending = true;
  bool get isDescending => _isDescending;

  HealthRecordViewModel(this._service);

  /// Kiểm tra yêu cầu thông tin cơ bản khi người dùng vừa vào trang.
  /// Nếu đã hoàn thành, thực hiện tải danh sách bản ghi đầu tiên.
  Future<void> checkRequirement(
    int accountId, {
    String type = 'Huyết áp', // Mặc định hiển thị Huyết áp
    bool descending = true,
  }) async {
    _isLoading = true;
    _isDescending = descending;
    notifyListeners();

    try {
      // 1. Check xem Profile đã đầy đủ chiều cao/cân nặng chưa
      bool isCompleted = await _service.isBasicInfoCompleted(accountId);
      _needsBasicInfo = !isCompleted;

      // 2. Nếu đã hoàn thành, lấy dữ liệu bản ghi thực tế
      if (isCompleted) {
        _records = await _service.getRecordsByType(
          accountId,
          type,
          descending: _isDescending,
        );
      } else {
        _records = []; // Đảm bảo danh sách rỗng nếu chưa đủ thông tin
      }
    } catch (e) {
      debugPrint("Lỗi checkRequirement: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tải lại danh sách bản ghi khi người dùng thay đổi bộ lọc (Loại bệnh hoặc Sắp xếp).
  Future<void> fetchRecords(
    int accountId,
    String type, {
    bool? descending,
  }) async {
    _isLoading = true;

    // Cập nhật lại kiểu sắp xếp nếu người dùng chọn từ Dropdown Sort
    if (descending != null) _isDescending = descending;
    notifyListeners();

    try {
      // Truy vấn dữ liệu thực tế từ Database thông qua Service
      _records = await _service.getRecordsByType(
        accountId,
        type,
        descending: _isDescending,
      );
    } catch (e) {
      debugPrint("Lỗi fetchRecords: $e");
      _records = []; // Trả về rỗng để UI hiển thị Empty State
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Xử lý lưu thông tin cá nhân ban đầu (chiều cao, cân nặng, bệnh nền).
  /// Sau khi lưu thành công, sẽ tự động chuyển trạng thái màn hình để người dùng bắt đầu đo đạc.
  Future<bool> handleSaveBasicInfo({
    required int accountId,
    required UserProfile profile,
    required List<int> diseaseIds,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      bool success = await _service.saveBasicHealthInfo(
        accountId: accountId,
        profile: profile,
        diseaseIds: diseaseIds,
      );

      if (success) {
        _needsBasicInfo = false; // Tắt modal/overlay yêu cầu nhập thông tin
        // Tải lại danh sách (thường sẽ là rỗng) để chuẩn bị hiển thị nút Thêm bản ghi
        await fetchRecords(accountId, 'Huyết áp');
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Lỗi handleSaveBasicInfo: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Dọn dẹp dữ liệu khi người dùng đăng xuất hoặc chuyển tài khoản.
  void clearState() {
    _records = [];
    _needsBasicInfo = false;
    _isLoading = false;
    _isDescending = true;
    notifyListeners();
  }

  /// ==================== CRUD ======================

  Future<bool> addNewRecord(HealthRecord record) async {
    _isLoading = true;
    notifyListeners();

    try {
      bool success = await _service.addRecord(record.toMap());

      if (success) {
        // Tải lại danh sách theo loại của bản ghi vừa thêm
        await fetchRecords(record.accountId, record.type);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Lỗi addNewRecord VM: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<bool> updateExistingRecord(HealthRecord record) async {
    if (record.id == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      bool success = await _service.updateRecord(record.toMap());
      if (success) {
        await fetchRecords(record.accountId, record.type);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Lỗi updateExistingRecord VM: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<bool> deleteExistingRecord(int id, int accountId, String type) async {
    _isLoading = true;
    notifyListeners();

    try {
      bool success = await _service.deleteRecord(id);
      if (success) {
        await fetchRecords(accountId, type);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Lỗi deleteExistingRecord VM: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


}
