import 'package:work_track/features/user/domain/entities/user_profile.dart';

abstract interface class UserRepository {
  UserProfile? getProfile();
  Future<void> saveProfile(UserProfile profile);
  Future<void> clearProfile();
  Stream<UserProfile?> watchProfile();
}
