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
      // --- HUYẾT ÁP ---
      {'type': 'Huyết áp', 'level': 'stable', 'content': 'Chỉ số huyết áp của bạn đang ở mức lý tưởng. Hãy duy trì chế độ ăn ít muối và tập thể dục ít nhất 30 phút mỗi ngày.'},
      {'type': 'Huyết áp', 'level': 'warning', 'content': 'Huyết áp đang nằm ngoài ngưỡng an toàn (quá cao hoặc quá thấp). Bạn nên nghỉ ngơi, tránh thay đổi tư thế đột ngột và hạn chế chất kích thích.'},
      {'type': 'Huyết áp', 'level': 'danger', 'content': 'Cảnh báo: Huyết áp đang ở mức báo động! Hãy ngồi nghỉ tĩnh lặng ngay lập tức và tham vấn ý kiến bác sĩ nếu có dấu hiệu chóng mặt, tức ngực.'},

      // --- ĐƯỜNG HUYẾT ---
      {'type': 'Đường huyết', 'level': 'stable', 'content': 'Chỉ số đường huyết ổn định. Hãy tiếp tục duy trì thực đơn giàu chất xơ và kiểm tra định kỳ cả lúc đói lẫn sau khi ăn.'},
      {'type': 'Đường huyết', 'level': 'warning', 'content': 'Đường huyết đang có sự biến động bất thường. Bạn nên điều chỉnh lại lượng tinh bột, đồ ngọt trong bữa ăn và bổ sung thêm nước lọc.'},
      {'type': 'Đường huyết', 'level': 'danger', 'content': 'Nguy hiểm: Đường huyết quá cao hoặc quá thấp! Cần kiểm tra lại thực đơn ngay, nếu thấy bủn rủn tay chân hoặc lơ mơ, hãy bổ sung đường nhẹ hoặc gặp bác sĩ.'},

      // --- CÂN NẶNG ---
      {'type': 'Cân nặng', 'level': 'stable', 'content': 'Cân nặng của bạn đang ở mức rất tốt so với chiều cao. Hãy duy trì thói quen ăn uống và sinh hoạt hiện tại.'},
      {'type': 'Cân nặng', 'level': 'warning', 'content': 'Bạn có dấu hiệu thừa cân hoặc thiếu cân nhẹ. Hãy chú ý cân bằng lại lượng Calo nạp vào và kiểm tra lại chế độ vận động hàng ngày.'},
      {'type': 'Cân nặng', 'level': 'danger', 'content': 'Chỉ số trọng lượng đang ở mức cảnh báo béo phì hoặc suy nhược. Bạn nên lập kế hoạch giảm/tăng cân khoa học để tránh ảnh hưởng đến xương khớp và tim mạch.'},

      // --- SPO2 ---
      {'type': 'SpO2', 'level': 'stable', 'content': 'Nồng độ oxy trong máu bình thường (96-100%). Hệ hô hấp của bạn đang hoạt động rất hiệu quả.'},
      {'type': 'SpO2', 'level': 'warning', 'content': 'Nồng độ oxy hơi thấp. Hãy kiểm tra lại môi trường xung quanh có thông thoáng không, thực hiện hít thở sâu và đều để cải thiện.'},
      {'type': 'SpO2', 'level': 'danger', 'content': 'Cấp cứu: Nồng độ oxy xuống mức nguy hiểm! Hãy nằm tư thế nghiêng hoặc ngồi thẳng để dễ thở và tìm kiếm sự hỗ trợ y tế ngay lập tức.'},
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

  // Kiểm tra xem email đã tồn tại trong bảng accounts chưa
  Future<bool> isEmailExists(String email) async {
    final db = await instance.database;
    final res = await db.query(
      'accounts',
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()], // Chuẩn hóa email trước khi check
    );
    return res.isNotEmpty;
  }

  // Trong class DatabaseHelper
  Future<Map<String, dynamic>?> getAccountByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'accounts',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
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
    double? v2 = record['value_2'];

    // 1. Lấy ngưỡng cài đặt cá nhân
    final settings = await txn.query('alert_settings',
        where: 'account_id = ?', whereArgs: [accountId]);

    Map<String, double> thresholds = {
      for (var item in settings) item['key_name'] as String: item['value'] as double
    };

    String statusDetail = "";
    String actionRequired = "";

    // 2. Logic so sánh chi tiết cho từng loại chỉ số
    switch (type) {
      case 'Huyết áp':
        double sysMax = thresholds['sys_max'] ?? 135.0;
        double diaMax = thresholds['dia_max'] ?? 85.0;
        String valStr = "${v1.toInt()}/${v2?.toInt()} mmHg";

        if (v1 >= sysMax + 25 || (v2 != null && v2 >= diaMax + 15)) {
          level = 'danger';
          statusDetail = "Cao nghiêm trọng ($valStr)";
          actionRequired = "Nguy cơ tăng huyết áp cấp cứu. Hãy ngồi nghỉ và liên hệ y tế nếu thấy đau đầu, tức ngực.";
        } else if (v1 > sysMax || (v2 != null && v2 > diaMax)) {
          level = 'warning';
          statusDetail = "Hơi cao ($valStr)";
          actionRequired = "Vượt ngưỡng an toàn. Bạn nên giảm muối, tránh căng thẳng và kiểm tra lại sau 15 phút.";
        } else if (v1 < 90) {
          level = 'warning';
          statusDetail = "Hơi thấp ($valStr)";
          actionRequired = "Huyết áp thấp có thể gây chóng mặt. Hãy uống nước ấm hoặc trà gừng.";
        } else {
          statusDetail = "Ổn định ($valStr)";
        }
        break;

      case 'Đường huyết':
        double gluMax = thresholds['glu_max'] ?? 126.0;
        double gluMin = thresholds['glu_min'] ?? 70.0;
        String valStr = "${v1.toStringAsFixed(1)} mg/dL";

        if (v1 > gluMax + 50) {
          level = 'danger';
          statusDetail = "Rất cao ($valStr)";
          actionRequired = "Đường huyết tăng vọt nguy hiểm. Hạn chế tinh bột ngay và uống nhiều nước lọc.";
        } else if (v1 < gluMin - 10) {
          level = 'danger';
          statusDetail = "Hạ đường huyết ($valStr)";
          actionRequired = "Nguy hiểm! Hãy ăn ngay 1 viên kẹo hoặc uống nước đường để tránh ngất xỉu.";
        } else if (v1 > gluMax || v1 < gluMin) {
          level = 'warning';
          statusDetail = v1 > gluMax ? "Hơi cao ($valStr)" : "Hơi thấp ($valStr)";
          actionRequired = "Chú ý điều chỉnh chế độ ăn uống và vận động nhẹ nhàng.";
        } else {
          statusDetail = "Ổn định ($valStr)";
        }
        break;

      case 'Cân nặng':
        double wMax = thresholds['weight_max'] ?? 80.0;
        double wMin = thresholds['weight_min'] ?? 45.0;
        String valStr = "${v1.toStringAsFixed(1)} kg";

        if (v1 > wMax + 10 || v1 < wMin - 5) {
          level = 'danger';
          statusDetail = v1 > wMax ? "Vượt cân ($valStr)" : "Thiếu cân ($valStr)";
          actionRequired = "Cân nặng thay đổi đột ngột. Bạn cần tham vấn chuyên gia dinh dưỡng.";
        } else if (v1 > wMax || v1 < wMin) {
          level = 'warning';
          statusDetail = "Cần chú ý ($valStr)";
          actionRequired = "Bạn đang ở ngưỡng cần điều chỉnh cân nặng để duy trì BMI tốt.";
        } else {
          statusDetail = "Lý tưởng ($valStr)";
        }
        break;

      case 'SpO2':
        double spo2Min = thresholds['spo2_min'] ?? 95.0;
        String valStr = "${v1.toStringAsFixed(1)} %";

        if (v1 < 90) {
          level = 'danger';
          statusDetail = "Thiếu Oxy nặng ($valStr)";
          actionRequired = "Cấp cứu! Nồng độ oxy quá thấp. Cần hỗ trợ y tế ngay lập tức.";
        } else if (v1 < spo2Min) {
          level = 'warning';
          statusDetail = "Hơi thấp ($valStr)";
          actionRequired = "Hãy thử tập hít thở sâu, đều và kiểm tra lại ở môi trường thoáng khí.";
        } else {
          statusDetail = "Bình thường ($valStr)";
        }
        break;
    }

    // 3. Lấy lời khuyên nền tảng từ DB
    var tips = await txn.query('health_tips',
        where: 'type = ? AND level = ?',
        whereArgs: [type, level],
        limit: 1);

    String generalTip = tips.isNotEmpty ? tips.first['content'] as String : "";

    // Kết hợp: [Hướng xử lý nhanh] + [Lời khuyên chuyên sâu]
    String finalContent = actionRequired.isNotEmpty
        ? "$actionRequired\nLời Khuyên: $generalTip"
        : generalTip;

    // 4. Lưu vào bảng notifications
    await txn.insert('notifications', {
      'record_id': recordId,
      'title': '$type: $statusDetail',
      'content': finalContent,
      'level': level,
      'is_read': 0,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Lấy thông báo mới nhất dựa trên ID của bản ghi sức khỏe
  /// Thường dùng để hiển thị kết quả phân tích ngay sau khi người dùng Lưu/Cập nhật
  Future<Map<String, dynamic>?> getNotificationByRecordId(int recordId) async {
    final db = await instance.database;

    final List<Map<String, dynamic>> results = await db.query(
      'notifications',
      where: 'record_id = ?',
      whereArgs: [recordId],
      orderBy: 'id DESC', // Lấy cái mới nhất nếu chẳng may có nhiều thông báo trùng record_id
      limit: 1,
    );

    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
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

  Future<int> deleteReadNotifications(int accountId) async {
    final db = await instance.database;
    return await db.rawDelete('''
    DELETE FROM notifications 
    WHERE is_read = 1 
    AND record_id IN (
      SELECT id FROM health_records WHERE account_id = ?
    )
  ''', [accountId]);
  }

  // ==========================================================
  // 4. USER PROFILE & INITIAL SETUP
  // ==========================================================

  Future<int> updateInitialProfile(int accountId, Map<String, dynamic> profileData, List<int> diseaseIds) async {
    final db = await instance.database;

    return await db.transaction((txn) async {
      // CHÚ Ý: Tạo một bản sao Map và loại bỏ các trường không mong muốn
      final Map<String, dynamic> cleanData = Map.from(profileData);

      // 1. Tuyệt đối không update 'id' (Primary Key) vì nó gây lỗi mismatch
      cleanData.remove('id');

      // 2. Không cho phép update account_id trong SET clause (vì nó nằm ở WHERE rồi)
      cleanData.remove('account_id');

      // BƯỚC 1: CẬP NHẬT PROFILE
      // Chỉ update nếu Map sau khi lọc vẫn còn dữ liệu
      if (cleanData.isNotEmpty) {
        await txn.update(
            'user_profile',
            cleanData,
            where: 'account_id = ?',
            whereArgs: [accountId]
        );
      }

      // BƯỚC 2: CẬP NHẬT BỆNH NỀN
      await txn.delete('user_diseases', where: 'account_id = ?', whereArgs: [accountId]);
      for (int dId in diseaseIds) {
        await txn.insert('user_diseases', {
          'account_id': accountId,
          'disease_id': dId
        });
      }

      // BƯỚC 3: CÀI ĐẶT NGƯỠNG CẢNH BÁO
      // Truyền cleanData hoặc profileData gốc tùy vào logic của hàm createDefaultAlertSettings
      await _createDefaultAlertSettings(txn, accountId, cleanData, diseaseIds);

      return 1; // báo thành công
    });
  }

  Future<void> _createDefaultAlertSettings(
      Transaction txn,
      int accountId,
      Map<String, dynamic> profile,
      List<int> selectedDiseaseIds
      ) async {
    // 1. Lấy dữ liệu đầu vào (Bỏ biến weight thừa)
    double height = (profile['height'] as num?)?.toDouble() ?? 160.0;

    /// 2. Sử dụng trực tiếp selectedDiseaseIds thay vì query lại DB
    bool hasHypertension = selectedDiseaseIds.contains(1);
    bool hasDiabetes = selectedDiseaseIds.contains(2);
    bool hasHeartDisease = selectedDiseaseIds.contains(3);
    bool hasRespiratory = selectedDiseaseIds.contains(4);

    // --- LOGIC TÍNH TOÁN ---
    // A. Huyết áp (mmHg)
    // Mặc định: 90-130 (Tâm thu), 60-85 (Tâm trương)
    double sysMax = (hasHypertension || hasHeartDisease) ? 125.0 : 130.0;
    double diaMax = (hasHypertension || hasHeartDisease) ? 80.0 : 85.0;

    // B. Đường huyết (mg/dL - Lúc đói)
    // Mặc định: 70-100. Nếu bị tiểu đường: 80-130 (Theo ADA)
    double gluMin = hasDiabetes ? 80.0 : 70.0;
    double gluMax = hasDiabetes ? 130.0 : 100.0;

    // C: BMI chuẩn: weight = BMI * (height/100)^2
    double hMeter = height / 100;
    double weightMin = 18.5 * hMeter * hMeter;
    double weightMax = 23.0 * hMeter * hMeter;

    // D. SpO2 (%)
    // Mặc định: 95-100. Nếu có bệnh hô hấp: 92-100
    double spo2Min = hasRespiratory ? 92.0 : 95.0;

    // --- LƯU VÀO DATABASE ---
    // Bước quan trọng: Xóa ngưỡng cũ của account này trước khi tạo mới để tránh bị nhân bản
    await txn.delete('alert_settings', where: 'account_id = ?', whereArgs: [accountId]);

    List<Map<String, dynamic>> settings = [
      {'account_id': accountId, 'key_name': 'sys_min', 'value': 90.0, 'unit': 'mmHg'},
      {'account_id': accountId, 'key_name': 'sys_max', 'value': sysMax, 'unit': 'mmHg'},
      {'account_id': accountId, 'key_name': 'dia_min', 'value': 60.0, 'unit': 'mmHg'},
      {'account_id': accountId, 'key_name': 'dia_max', 'value': diaMax, 'unit': 'mmHg'},
      {'account_id': accountId, 'key_name': 'glu_min', 'value': gluMin, 'unit': 'mg/dL'},
      {'account_id': accountId, 'key_name': 'glu_max', 'value': gluMax, 'unit': 'mg/dL'},
      {'account_id': accountId, 'key_name': 'weight_min', 'value': double.parse(weightMin.toStringAsFixed(1)), 'unit': 'kg'},
      {'account_id': accountId, 'key_name': 'weight_max', 'value': double.parse(weightMax.toStringAsFixed(1)), 'unit': 'kg'},
      {'account_id': accountId, 'key_name': 'spo2_min', 'value': spo2Min, 'unit': '%'},
      {'account_id': accountId, 'key_name': 'spo2_max', 'value': 100.0, 'unit': '%'},
    ];

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

  // ==========================================================
  // 6. DISEASE LOGIC
  // ==========================================================

  /// Lấy danh sách tên các loại bệnh nền mà người dùng đã chọn
  Future<List<String>> getDiseasesByAccountId(int accountId) async {
    final db = await instance.database;

    // Sử dụng INNER JOIN để lấy cột 'name' từ bảng 'diseases'
    // thông qua bảng trung gian 'user_diseases'
    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT d.name 
      FROM diseases d
      JOIN user_diseases ud ON d.id = ud.disease_id
      WHERE ud.account_id = ?
    ''', [accountId]);

    // Chuyển đổi từ List<Map> sang List<String>
    return results.map((e) => e['name'] as String).toList();
  }
}