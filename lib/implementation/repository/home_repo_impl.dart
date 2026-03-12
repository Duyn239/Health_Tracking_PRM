import '../../interface/repository/ihome_repository.dart';
import '../../data/database/database_helper.dart';

class HomeRepository implements IHomeRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<Map<String, dynamic?>> getLatestHealthStats(int accountId) async {
    // Gọi hàm getLatestRecords đã viết sẵn trong DatabaseHelper của bạn
    return await _dbHelper.getLatestRecords(accountId);
  }

  @override
  Future<String> getTipContent(String type, String level) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'health_tips',
      where: 'type = ? AND level = ?',
      whereArgs: [type, level],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return maps.first['content'] as String;
    }
    return "Hãy duy trì lối sống lành mạnh và kiểm tra sức khỏe định kỳ.";
  }
}