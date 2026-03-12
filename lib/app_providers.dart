import 'package:health_tracking/viewmodels/notification_vm.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:health_tracking/viewmodels/alert_setting_vm.dart';

// Import Database & Interfaces
import 'implementation/repository/notification_repo_impl.dart';
import 'implementation/repository/setting_repo_impl.dart';
import 'implementation/service/notification_service_impl.dart';
import 'implementation/service/setting_service_impl.dart';
import 'interface/repository/inotification_repository.dart';
import 'interface/repository/isetting_repository.dart';
import 'interface/service/inotification_service.dart';
import 'interface/service/isetting_service.dart';

// --- AUTH ---
import 'implementation/repository/auth_repo_impl.dart';
import 'implementation/service/auth_service_impl.dart';
import 'viewmodels/register_vm.dart';
import 'viewmodels/login_vm.dart';

// --- HOME ---
import 'implementation/repository/home_repo_impl.dart';
import 'implementation/service/home_service_impl.dart';
import 'viewmodels/home_vm.dart';

// --- PROFILE ---
import 'implementation/repository/profile_repo_impl.dart';
import 'implementation/service/profile_service_impl.dart';
import 'viewmodels/profile_vm.dart';

// --- HEALTH RECORD ---
import 'implementation/repository/health_record_repo_impl.dart';
import 'implementation/service/health_record_service_impl.dart';
import 'viewmodels/heath_record_vm.dart';

// --- CHART ---
import 'viewmodels/chart_vm.dart';

class AppProviders {
  static List<SingleChildWidget> get providers => [
    // ================= AUTH SECTION =================
    Provider<AuthRepository>(create: (_) => AuthRepository()),
    ProxyProvider<AuthRepository, AuthService>(
      update: (_, authRepo, __) => AuthService(authRepo),
    ),
    ChangeNotifierProvider(
      create: (context) => RegisterViewModel(context.read<AuthService>()),
    ),
    ChangeNotifierProvider(
      create: (context) => LoginViewModel(context.read<AuthService>()),
    ),

    // ================= HOME SECTION =================
    Provider<HomeRepository>(create: (_) => HomeRepository()),
    ProxyProvider<HomeRepository, HomeService>(
      update: (_, homeRepo, __) => HomeService(homeRepo),
    ),
    ChangeNotifierProvider(
      create: (context) => HomeViewModel(context.read<HomeService>()),
    ),

    // ================= PROFILE SECTION =================
    Provider<ProfileRepository>(create: (_) => ProfileRepository()),
    ProxyProvider<ProfileRepository, ProfileService>(
      update: (_, profileRepo, __) => ProfileService(profileRepo),
    ),
    ChangeNotifierProxyProvider<LoginViewModel, ProfileViewModel>(
      create: (context) => ProfileViewModel(context.read<ProfileService>()),
      update: (context, loginVM, profileVM) {
        if (loginVM.currentAccount == null) profileVM?.clearData();
        return profileVM!;
      },
    ),

    // ================= HEALTH RECORD SECTION =================
    Provider<HealthRecordRepository>(create: (_) => HealthRecordRepository()),
    ProxyProvider2<
        HealthRecordRepository,
        ProfileRepository,
        HealthRecordService
    >(
      update: (_, recordRepo, profileRepo, __) =>
          HealthRecordService(recordRepo, profileRepo),
    ),
    ChangeNotifierProxyProvider<LoginViewModel, HealthRecordViewModel>(
      create: (context) =>
          HealthRecordViewModel(context.read<HealthRecordService>()),
      update: (context, loginVM, healthVM) {
        if (loginVM.currentAccount == null) healthVM?.clearState();
        return healthVM!;
      },
    ),

    // ================= ALERT SETTING SECTION =================
    Provider<ISettingRepository>(create: (_) => SettingRepository()),
    ProxyProvider<ISettingRepository, ISettingService>(
      update: (_, repo, __) => SettingService(repo),
    ),
    ChangeNotifierProxyProvider<LoginViewModel, AlertSettingViewModel>(
      create: (context) =>
          AlertSettingViewModel(context.read<ISettingService>()),
      update: (context, loginVM, alertVM) {
        if (loginVM.currentAccount == null) alertVM?.clearData();
        return alertVM!;
      },
    ),

    // ================= NOTIFICATION SECTION =================
    Provider<INotificationRepository>(create: (_) => NotificationRepository()),
    ProxyProvider<INotificationRepository, INotificationService>(
      update: (_, repo, __) => NotificationService(repo),
    ),
    ChangeNotifierProvider(
      create: (context) =>
          NotificationViewModel(context.read<INotificationService>()),
    ),

    // ================= CHART SECTION =================
    // Inject cả HealthRecordService + ISettingService để lấy ngưỡng cảnh báo
    ChangeNotifierProxyProvider<LoginViewModel, ChartViewModel>(
      create: (context) => ChartViewModel(
        context.read<HealthRecordService>(),  // lấy instance đã có
        context.read<ISettingService>(),       // lấy instance đã có
      ),
      update: (context, loginVM, chartVM) {
        if (loginVM.currentAccount == null) chartVM?.clearData();
        return chartVM!;
      },
    ),
  ];
}