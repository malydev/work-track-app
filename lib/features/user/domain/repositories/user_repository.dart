import 'package:work_track/features/user/data/models/user_profile_model.dart';

abstract interface class UserRepository {
  UserProfileModel? getProfile();
  Future<void> saveProfile(UserProfileModel profile);
  Future<void> clearProfile();
  Stream<UserProfileModel?> watchProfile();
}
