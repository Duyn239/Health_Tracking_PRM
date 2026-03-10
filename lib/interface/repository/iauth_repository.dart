abstract class IAuthRepository {
  // Trả về accountId nếu thành công
  Future<int> register(String fullName, String email, String password);

  // Trả về thông tin User nếu đúng, null nếu sai
  Future<Map<String, dynamic>?> login(String email, String password);
  Future<bool> checkEmailExists(String email);
  Future<Map<String, dynamic>?> getAccountByEmail(String email);
}