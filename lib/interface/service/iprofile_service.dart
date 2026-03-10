import 'package:health_tracking/data/models/user_profile.dart';

abstract class IProfileService {
  Future<Map<String, dynamic>?> getProfile(int accountId);
  Future<bool> saveInitialProfile({
    required int accountId,
    required UserProfile data,
    required List<int> selectedDiseaseIds,
  });
  Future<List<String>> getDiseasesByAccountId(int accountId);
}
