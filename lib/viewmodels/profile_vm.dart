// lib/viewmodels/profile_vm.dart
import 'package:flutter/material.dart';
import '../data/models/user_profile.dart';
import '../interface/service/iprofile_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final IProfileService _profileService;
  ProfileViewModel(this._profileService);

  // Đối tượng chứa thông tin cá nhân (Cao, nặng, ngày sinh...)
  UserProfile? _userProfile;
  UserProfile? get userProfile => _userProfile;

  // Danh sách tên các bệnh nền
  List<String> _diseases = [];
  List<String> get diseases => _diseases;

  bool _isLoading = false;
  bool get isLoading => _isLoading;



  // Hàm helper xử lý hiển thị "Chưa có" cho Object hoặc chuỗi trống
  String getDisplayValue(dynamic value, {String unit = ""}) {
    if (value == null ||
        value.toString().trim().isEmpty ||
        value == 0 ||
        value == 0.0 ||
        value == "null") {
      return "Chưa có";
    }
    return "$value$unit";
  }

  // Hàm gộp danh sách bệnh thành một chuỗi duy nhất để hiển thị trên UI
  String getDiseasesDisplay() {
    if (_diseases.isEmpty) return "Chưa có";
    return _diseases.join(", "); // Trả về dạng: "Tiểu đường, Tăng huyết áp"
  }

  Future<void> fetchProfile(int accountId) async {
    _isLoading = true;
    _diseases = []; // Reset danh sách bệnh cũ để tránh nhầm lẫn dữ liệu
    notifyListeners();

    try {
      // 1. Lấy thông tin Profile (chuyển từ Map sang Object UserProfile)
      final mapData = await _profileService.getProfile(accountId);
      if (mapData != null) {
        _userProfile = UserProfile.fromMap(mapData);
      }

      // 2. Lấy danh sách tên bệnh từ tầng Service
      _diseases = await _profileService.getDiseasesByAccountId(accountId);

    } catch (e) {
      debugPrint("Lỗi nạp dữ liệu Profile: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}