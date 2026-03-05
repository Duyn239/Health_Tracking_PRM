import 'package:flutter/material.dart';
import 'package:health_tracking/views/chart/chart_page.dart';
import 'package:health_tracking/views/health_record/basic_info_modal.dart';
import 'package:health_tracking/views/health_record/health_record_page.dart';
import 'package:health_tracking/views/home/home_page.dart';
import 'package:health_tracking/views/login/login_page.dart';
import 'package:health_tracking/views/profile/profile_page.dart';
import 'package:health_tracking/views/register/register_page.dart';
import 'package:health_tracking/views/setting/alert_setting_page.dart';
import 'package:health_tracking/views/setting/settings_page.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LoginPage(),
  ));

}

