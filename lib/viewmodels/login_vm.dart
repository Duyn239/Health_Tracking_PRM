import 'package:flutter/material.dart';
import '../data/models/account.dart';
import '../interface/service/iauth_service.dart';

class LoginViewModel extends ChangeNotifier {
  final IAuthService _authService;

  LoginViewModel(this._authService);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Đối tượng Account sau khi login thành công
  Account? _currentAccount;
  Account? get currentAccount => _currentAccount;

  // Thêm biến để giữ tên tạm thời
  String? _tempFullName;
  String? get tempFullName => _tempFullName;


  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _tempFullName = null; // Reset tên trước khi login mới
    notifyListeners();

    try {
      // 1. Nhận Map từ Service (Map này đã chứa dữ liệu JOIN từ DB)
      final Map<String, dynamic>? userData = await _authService.loginUser(
        email,
        password,
      );

      if (userData != null) {
        // 2. Trích xuất full_name trực tiếp từ Map
        _tempFullName = userData['full_name'];

        // 3. Chuyển Map thành Object Account để lưu session
        _currentAccount = Account.fromMap(userData);

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      // Lấy thông báo lỗi sạch từ Exception đã throw ở Service
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _currentAccount = null; // Đây chính là chìa khóa để ProxyProvider kích hoạt clearData
    notifyListeners(); // Thông báo để chuỗi Provider thực hiện update
  }
}
