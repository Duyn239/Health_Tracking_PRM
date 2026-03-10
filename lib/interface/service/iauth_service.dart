import '../../data/models/account.dart';

abstract class IAuthService {
  // Trả về một chuỗi thông báo lỗi nếu thất bại, hoặc null nếu thành công
  Future<String?> registerUser({
    required String fullName,
    required String email,
    required String password,
  });

  Future<bool> isEmailAvailable(String email);
  Future<Map<String, dynamic>?> loginUser(String email, String password);
}