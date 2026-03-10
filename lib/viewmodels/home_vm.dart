import 'package:flutter/material.dart';

import '../interface/service/ihome_service.dart';

class HomeViewModel extends ChangeNotifier {
  final IHomeService _homeService;
  HomeViewModel(this._homeService);

  String _userName = "User";
  String get userName => _userName;

  // Hàm này để nhận tên từ LoginViewModel truyền sang
  void setUserName(String? name) {
    if (name != null && name.isNotEmpty) {
      _userName = name;
      notifyListeners();
    }
  }
}