import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Kiểm tra nếu DB đã mở thì trả về, nếu chưa thì tiến hành khởi tạo
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('health_app_pro.db');
    return _database!;
  }

  // Khởi tạo file database trong bộ nhớ điện thoại
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,      // Gọi khi ứng dụng được cài đặt lần đầu
      onConfigure: _onConfigure, // Cấu hình hệ thống (như khóa ngoại)
    );
  }

  // Bật tính năng khóa ngoại (Foreign Keys) để ràng buộc dữ liệu giữa các bảng
  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // HÀM TẠO CẤU TRÚC BẢNG (SCHEMA)
  Future _createDB(Database db, int version) async {
    const textType = 'TEXT NOT NULL';
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const realType = 'REAL NOT NULL';
    const nullText = 'TEXT';
    const nullReal = 'REAL';

    // 1. Bảng tài khoản: Lưu Email và Mật khẩu
    await db.execute('''CREATE TABLE accounts (
      id $idType, email TEXT UNIQUE NOT NULL, password $textType, created_at $textType
    )''');

    // 2. Bảng hồ sơ: Lưu thông tin cá nhân, liên kết với accounts qua account_id
    await db.execute('''CREATE TABLE user_profile (
      id $idType, account_id INTEGER UNIQUE, full_name $nullText,
      dob $nullText, gender $nullText, height $nullReal, weight $nullReal, updated_at $nullText,
      FOREIGN KEY (account_id) REFERENCES accounts (id) ON DELETE CASCADE
    )''');

    // 3. Bảng bệnh mục: Danh mục các loại bệnh nền có sẵn (Tăng HA, Tiểu đường...)
    await db.execute('''CREATE TABLE diseases (id $idType, name TEXT NOT NULL UNIQUE)''');

    // 4. Bảng trung gian: Lưu danh sách bệnh nền của từng người dùng cụ thể
    await db.execute('''CREATE TABLE user_diseases (
      account_id INTEGER, disease_id INTEGER,
      PRIMARY KEY (account_id, disease_id),
      FOREIGN KEY (account_id) REFERENCES accounts (id) ON DELETE CASCADE,
      FOREIGN KEY (disease_id) REFERENCES diseases (id) ON DELETE CASCADE
    )''');

    // 5. Bảng nhật ký sức khỏe: Lưu kết quả đo (Huyết áp, Đường huyết, SpO2, Cân nặng)
    await db.execute('''CREATE TABLE health_records (
      id $idType, account_id INTEGER, type $textType, value_1 $realType, value_2 REAL,
      heart_rate INTEGER, unit $textType, note $nullText, measured_at $textType,
      FOREIGN KEY (account_id) REFERENCES accounts (id) ON DELETE CASCADE
    )''');

    // 6. Bảng ngưỡng cảnh báo: Lưu Min/Max cá nhân hóa cho từng tài khoản
    await db.execute('''CREATE TABLE alert_settings (
      id $idType, account_id INTEGER, key_name $textType, value $realType, unit $textType,
      FOREIGN KEY (account_id) REFERENCES accounts (id) ON DELETE CASCADE
    )''');

    // 7. Bảng lời khuyên: Kho dữ liệu chứa các câu tư vấn y khoa theo từng cấp độ
    await db.execute('''CREATE TABLE health_tips (
      id $idType, type $textType, level $textType, content $textType
    )''');

    // 8. Bảng thông báo: Lưu các cảnh báo được sinh ra sau mỗi lần người dùng đo
    await db.execute('''CREATE TABLE notifications (
      id $idType, record_id INTEGER UNIQUE, title $textType, content $textType,
      level $textType, is_read INTEGER DEFAULT 0, created_at $textType,
      FOREIGN KEY (record_id) REFERENCES health_records (id) ON DELETE CASCADE
    )''');

    // Nạp dữ liệu mẫu ban đầu (Diseases & Tips)
    await _seedData(db);
  }

  Future<void> _seedData(Database db) async {
    final diseases = [
      'Tăng huyết áp',   // ID: 1
      'Tiểu đường',      // ID: 2
      'Bệnh tim mạch',   // ID: 3
      'Bệnh hô hấp'      // ID: 4
    ];
    for (var name in diseases) {
      await db.insert('diseases', {'name': name});
    }

    final tips = [
      {'type': 'Huyết áp', 'level': 'stable', 'content': 'Huyết áp của bạn rất tốt. Hãy duy trì chế độ ăn ít muối và tập thể dục đều đặn.'},
      {'type': 'Huyết áp', 'level': 'warning', 'content': 'Huyết áp hơi cao. Bạn nên hạn chế chất kích thích và nghỉ ngơi nhiều hơn.'},
      {'type': 'Huyết áp', 'level': 'danger', 'content': 'Huyết áp đang ở mức báo động! Hãy nghỉ ngơi ngay và tham vấn ý kiến bác sĩ.'},

      {'type': 'Đường huyết', 'level': 'stable', 'content': 'Chỉ số đường huyết ổn định. Tiếp tục duy trì chế độ ăn giàu chất xơ.'},
      {'type': 'Đường huyết', 'level': 'warning', 'content': 'Đường huyết hơi cao. Hạn chế tinh bột và đồ ngọt trong các bữa ăn.'},
      {'type': 'Đường huyết', 'level': 'danger', 'content': 'Chỉ số đường huyết quá cao. Bạn cần kiểm tra lại thực đơn hoặc gặp bác sĩ.'},

      {'type': 'Cân nặng', 'level': 'stable', 'content': 'Cân nặng của bạn đang ở mức lý tưởng so với chiều cao.'},
      {'type': 'Cân nặng', 'level': 'warning', 'content': 'Bạn có dấu hiệu thừa cân. Hãy chú ý kiểm soát calo nạp vào.'},
      {'type': 'Cân nặng', 'level': 'danger', 'content': 'Chỉ số BMI cho thấy bạn đang béo phì. Cần có kế hoạch giảm cân khoa học.'},

      {'type': 'SpO2', 'level': 'stable', 'content': 'Nồng độ oxy trong máu bình thường.'},
      {'type': 'SpO2', 'level': 'danger', 'content': 'Nồng độ oxy xuống thấp! Hãy tập hít thở sâu và tìm nơi thoáng khí.'},
    ];

    for (var tip in tips) {
      await db.insert('health_tips', tip);
    }
  }

  // ==========================================================
  // 1. AUTH & REGISTER
  // ==========================================================

  Future<int> register(String fullName, String email, String password) async {
    final db = await instance.database;

    // Sử dụng transaction (Giao dịch) để đảm bảo tính toàn vẹn:
    // Nếu việc tạo tài khoản thành công nhưng tạo Profile thất bại,
    // hệ thống sẽ tự động hủy (rollback) cả hai để tránh dữ liệu bị lỗi.
    return await db.transaction((txn) async {

      // Bước 1: Chèn thông tin đăng nhập vào bảng 'accounts'
      int accountId = await txn.insert('accounts', {
        'email': email,
        'password': password,
        'created_at': DateTime.now().toIso8601String(), // Lưu thời gian đăng ký dạng chuỗi ISO
      });

      // Bước 2: Dùng accountId vừa tạo ở trên để khởi tạo hồ sơ trong bảng 'user_profile'
      await txn.insert('user_profile', {
        'account_id': accountId, // Liên kết (Foreign Key) tới tài khoản vừa tạo
        'full_name': fullName,
        'updated_at': DateTime.now().toIso8601String(),
      });

      return accountId; // Trả về ID của tài khoản để sử dụng cho các màn hình sau
    });
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    final db = await instance.database;
    final res = await db.rawQuery('''
      SELECT a.*, p.full_name FROM accounts a
      JOIN user_profile p ON a.id = p.account_id
      WHERE a.email = ? AND a.password = ?
    ''', [email, password]);
    return res.isNotEmpty ? res.first : null;
  }

  // ==========================================================
  // 2. CRUD HEALTH RECORDS
  // ==========================================================

  // Lấy toàn bộ danh sách 4 chỉ số
  Future<List<Map<String, dynamic>>> getAllHealthRecords(int accountId) async {
    final db = await instance.database;
    return await db.query('health_records', where: 'account_id = ?', whereArgs: [accountId]);
  }

  // Lấy theo loại + Sắp xếp (Latest <-> Oldest)
  Future<List<Map<String, dynamic>>> getRecordsByType(int accountId, String type, {bool descending = true}) async {
    final db = await instance.database;
    String order = descending ? 'DESC' : 'ASC';
    return await db.query('health_records',
        where: 'account_id = ? AND type = ?',
        whereArgs: [accountId, type],
        orderBy: 'measured_at $order');
  }

  // Lấy bản ghi mới nhất của cả 4 loại
  Future<Map<String, dynamic?>> getLatestRecords(int accountId) async {
    final db = await instance.database;
    Map<String, dynamic?> latest = {};
    List<String> types = ['Huyết áp', 'Đường huyết', 'Cân nặng', 'SpO2'];
    for (var type in types) {
      var res = await db.query('health_records',
          where: 'account_id = ? AND type = ?',
          whereArgs: [accountId, type],
          orderBy: 'measured_at DESC', limit: 1);
      latest[type] = res.isNotEmpty ? res.first : null;
    }
    return latest;
  }

  Future<int> insertHealthRecord(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.transaction((txn) async {
      int id = await txn.insert('health_records', row);
      await _generateNotification(txn, row, id); // Tự động tạo thông báo khi thêm
      return id;
    });
  }

  Future<int> updateHealthRecord(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.transaction((txn) async {
      int id = row['id'];
      await txn.update('health_records', row, where: 'id = ?', whereArgs: [id]);
      // Xóa thông báo cũ và tạo lại theo chỉ số mới cập nhật
      await txn.delete('notifications', where: 'record_id = ?', whereArgs: [id]);
      await _generateNotification(txn, row, id);
      return id;
    });
  }

  Future<int> deleteHealthRecord(int id) async {
    final db = await instance.database;
    return await db.delete('health_records', where: 'id = ?', whereArgs: [id]);
  }

  // ==========================================================
  // 3. NOTIFICATIONS LOGIC
  // ==========================================================

  /// Lấy ngưỡng --> So sánh --> Phân loại Level --> Lấy lời khuyên.
  Future<void> _generateNotification(Transaction txn, Map<String, dynamic> record, int recordId) async {
    String level = 'stable';
    String type = record['type'] as String;
    int accountId = record['account_id'] as int;
    double v1 = record['value_1'] as double;
    double? v2 = record['value_2']; // Dùng cho tâm trương của Huyết áp

    // 1. Lấy tất cả ngưỡng cài đặt của người dùng này
    final settings = await txn.query('alert_settings',
        where: 'account_id = ?', whereArgs: [accountId]);

    // Chuyển List settings thành Map để dễ truy xuất
    Map<String, double> thresholds = {
      for (var item in settings) item['key_name'] as String: item['value'] as double
    };

    // 2. Logic so sánh dựa trên từng loại chỉ số
    if (type == 'Huyết áp') {
      double sysMax = thresholds['sys_max'] ?? 130.0;
      double diaMax = thresholds['dia_max'] ?? 85.0;
      double sysMin = thresholds['sys_min'] ?? 90.0;

      if (v1 > sysMax + 10 || (v2 != null && v2 > diaMax + 10)) {
        level = 'danger';
      } else if (v1 > sysMax || (v2 != null && v2 > diaMax) || v1 < sysMin) {
        level = 'warning';
      }
    }
    else if (type == 'Đường huyết') {
      double gluMax = thresholds['glu_max'] ?? 100.0;
      double gluMin = thresholds['glu_min'] ?? 70.0;

      if (v1 > gluMax + 20 || v1 < gluMin - 10) {
        level = 'danger';
      } else if (v1 > gluMax || v1 < gluMin) {
        level = 'warning';
      }
    }
    else if (type == 'Cân nặng') {
      double wMax = thresholds['weight_max'] ?? 75.0;
      double wMin = thresholds['weight_min'] ?? 45.0;

      if (v1 > wMax + 5 || v1 < wMin - 5) {
        level = 'danger';
      } else if (v1 > wMax || v1 < wMin) {
        level = 'warning';
      }
    }
    else if (type == 'SpO2') {
      double spo2Min = thresholds['spo2_min'] ?? 95.0;

      if (v1 < spo2Min - 3) {
        level = 'danger';
      } else if (v1 < spo2Min) {
        level = 'warning';
      }
    }

    // 3. Lấy lời khuyên tương ứng với Level vừa tính được
    var tips = await txn.query('health_tips',
        where: 'type = ? AND level = ?',
        whereArgs: [type, level],
        limit: 1);

    String content = tips.isNotEmpty
        ? tips.first['content'] as String
        : "Chỉ số ${type} của bạn đã được ghi nhận.";

    // 4. Lưu thông báo
    await txn.insert('notifications', {
      'record_id': recordId,
      'title': level == 'stable' ? 'Theo dõi $type' : 'Cảnh báo $type',
      'content': content,
      'level': level,
      'is_read': 0,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getFilteredNotifications(int accountId, {String? level, String? type}) async {
    final db = await instance.database;
    String query = 'SELECT n.* FROM notifications n JOIN health_records r ON n.record_id = r.id WHERE r.account_id = ?';
    List<dynamic> args = [accountId];

    if (level != null && level != 'all') {
      query += ' AND n.level = ?';
      args.add(level);
    }
    if (type != null && type != 'all') {
      query += ' AND r.type = ?';
      args.add(type);
    }
    query += ' ORDER BY n.created_at DESC';
    return await db.rawQuery(query, args);
  }

  Future<int> markAsRead(int notificationId) async {
    final db = await instance.database;
    return await db.update('notifications', {'is_read': 1}, where: 'id = ?', whereArgs: [notificationId]);
  }

  // ==========================================================
  // 4. USER PROFILE & INITIAL SETUP
  // ==========================================================

  Future<int> updateInitialProfile(int accountId, Map<String, dynamic> profileData, List<int> diseaseIds) async {
    final db = await instance.database;

    // Sử dụng transaction để đảm bảo 3 bước dưới đây phải thành công cùng nhau
    return await db.transaction((txn) async {

      // BƯỚC 1: CẬP NHẬT THÔNG TIN CÁ NHÂN (Chiều cao, cân nặng, ngày sinh...)
      // Biến 'profileData' chính là Map chứa: {height, weight, dob, gender, full_name}
      // Nó sẽ ghi đè các giá trị này vào bản ghi có account_id tương ứng
      await txn.update('user_profile', profileData,
          where: 'account_id = ?', whereArgs: [accountId]);

      // BƯỚC 2: CẬP NHẬT DANH SÁCH BỆNH NỀN
      // - Đầu tiên: Xóa hết các bệnh nền cũ của user này (để làm sạch dữ liệu)
      await txn.delete('user_diseases', where: 'account_id = ?', whereArgs: [accountId]);

      // - Sau đó: Thêm lại danh sách ID bệnh mới mà người dùng đã chọn (vòng lặp for)
      for (int dId in diseaseIds) {
        await txn.insert('user_diseases', {'account_id': accountId, 'disease_id': dId});
      }

      // BƯỚC 3: TỰ ĐỘNG CÀI ĐẶT NGƯỠNG CẢNH BÁO (ALERTS)
      // Đây là phần thông minh nhất:
      // Dựa trên chiều cao/cân nặng/bệnh nền vừa lưu, hàm này sẽ tự tính ra:
      // - Cân nặng mục tiêu (BMI)
      // - Huyết áp an toàn cho người bệnh tim/thận (nếu có)
      // - Đường huyết an toàn...
      // Sau đó lưu vào bảng 'alert_settings'
      await _createDefaultAlertSettings(txn, accountId, profileData);

      return 1; // Trả về 1 để báo hiệu cập nhật thành công hoàn toàn
    });
  }

  Future<void> _createDefaultAlertSettings(Transaction txn, int accountId, Map<String, dynamic> profile) async {
    // 1. Lấy dữ liệu đầu vào
    double height = profile['height'] ?? 160.0; // cm
    double weight = profile['weight'] ?? 60.0; // kg

    // Lấy danh sách ID bệnh nền (1: Tăng huyết áp, 2: Tiểu đường, 3: Tim mạch, 4: Hô hấp)
    final userDiseases = await txn.query('user_diseases',
        columns: ['disease_id'], where: 'account_id = ?', whereArgs: [accountId]);
    List<int> dIds = userDiseases.map((e) => e['disease_id'] as int).toList();

    bool hasHypertension = dIds.contains(1);
    bool hasDiabetes = dIds.contains(2);
    bool hasHeartDisease = dIds.contains(3);
    bool hasRespiratory = dIds.contains(4);

    // --- LOGIC TÍNH TOÁN CHI TIẾT ---

    // A. Huyết áp (mmHg)
    // Mặc định: 90-130 (Tâm thu), 60-85 (Tâm trương)
    double sysMin = 90.0;
    double sysMax = (hasHypertension || hasHeartDisease) ? 125.0 : 130.0;
    double diaMin = 60.0;
    double diaMax = (hasHypertension || hasHeartDisease) ? 80.0 : 85.0;

    // B. Đường huyết (mg/dL - Lúc đói)
    // Mặc định: 70-100. Nếu bị tiểu đường: 80-130 (Theo ADA)
    double gluMin = hasDiabetes ? 80.0 : 70.0;
    double gluMax = hasDiabetes ? 130.0 : 100.0;

    // C. Cân nặng (kg)
    // Tính theo BMI chuẩn 18.5 - 23.0
    double weightMin = 18.5 * (height / 100) * (height / 100);
    double weightMax = 23.0 * (height / 100) * (height / 100);

    // D. SpO2 (%)
    // Mặc định: 95-100. Nếu có bệnh hô hấp: 92-100
    double spo2Min = hasRespiratory ? 92.0 : 95.0;
    double spo2Max = 100.0;

    // --- LƯU VÀO DATABASE ---
    // Định nghĩa danh sách các key để insert
    List<Map<String, dynamic>> settings = [
      // Huyết áp
      {'account_id': accountId, 'key_name': 'sys_min', 'value': sysMin, 'unit': 'mmHg'},
      {'account_id': accountId, 'key_name': 'sys_max', 'value': sysMax, 'unit': 'mmHg'},
      {'account_id': accountId, 'key_name': 'dia_min', 'value': diaMin, 'unit': 'mmHg'},
      {'account_id': accountId, 'key_name': 'dia_max', 'value': diaMax, 'unit': 'mmHg'},
      // Đường huyết
      {'account_id': accountId, 'key_name': 'glu_min', 'value': gluMin, 'unit': 'mg/dL'},
      {'account_id': accountId, 'key_name': 'glu_max', 'value': gluMax, 'unit': 'mg/dL'},
      // Cân nặng
      {'account_id': accountId, 'key_name': 'weight_min', 'value': double.parse(weightMin.toStringAsFixed(1)), 'unit': 'kg'},
      {'account_id': accountId, 'key_name': 'weight_max', 'value': double.parse(weightMax.toStringAsFixed(1)), 'unit': 'kg'},
      // SpO2
      {'account_id': accountId, 'key_name': 'spo2_min', 'value': spo2Min, 'unit': '%'},
      {'account_id': accountId, 'key_name': 'spo2_max', 'value': spo2Max, 'unit': '%'},
    ];

    // Thực hiện insert
    for (var s in settings) {
      await txn.insert('alert_settings', s);
    }
  }

  // ==========================================================
  // 5. ALERT SETTINGS CRUD
  // ==========================================================

  Future<List<Map<String, dynamic>>> getAlertSettings(int accountId) async {
    final db = await instance.database;
    return await db.query('alert_settings', where: 'account_id = ?', whereArgs: [accountId]);
  }

  Future<int> updateAlertSetting(int accountId, String keyName, double newValue) async {
    final db = await instance.database;
    return await db.update('alert_settings', {'value': newValue},
        where: 'account_id = ? AND key_name = ?', whereArgs: [accountId, keyName]);
  }
}