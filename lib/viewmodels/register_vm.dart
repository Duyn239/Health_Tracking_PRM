import 'package:flutter/material.dart';
import '../../interface/service/iauth_service.dart';

class RegisterViewModel extends ChangeNotifier {
  final IAuthService _authService;

  RegisterViewModel(this._authService);

  // --- Trạng thái (States) ---
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // --- Hành động (Actions) ---

  /// Hàm xử lý đăng ký tài khoản
  /// Trả về true nếu thành công, false nếu thất bại
  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    // Bật trạng thái loading và xóa lỗi cũ
    _setLoading(true);
    _errorMessage = null;
    notifyListeners();

    try {
      // Gọi Service để thực hiện logic nghiệp vụ (check trùng, hash pass, lưu DB)
      final errorResult = await _authService.registerUser(
        fullName: fullName,
        email: email,
        password: password,
      );

      if (errorResult == null) {
        // Đăng ký thành công
        _setLoading(false);
        return true;
      } else {
        _errorMessage = errorResult;
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = "Đã xảy ra lỗi không mong muốn. Vui lòng thử lại sau.";
      _setLoading(false);
      return false;
    }
  }

  // Hàm helper để quản lý loading nội bộ
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}