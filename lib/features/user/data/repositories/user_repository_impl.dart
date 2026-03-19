import 'package:work_track/features/user/data/datasources/user_local_data_source.dart';
import 'package:work_track/features/user/data/models/user_profile_model.dart';
import 'package:work_track/features/user/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  const UserRepositoryImpl(this._localDataSource);

  final UserLocalDataSource _localDataSource;

  @override
  UserProfileModel? getProfile() {
    return _localDataSource.getProfile();
  }

  @override
  Future<void> saveProfile(UserProfileModel profile) {
    return _localDataSource.saveProfile(profile);
  }

  @override
  Future<void> clearProfile() {
    return _localDataSource.clearProfile();
  }

  @override
  Stream<UserProfileModel?> watchProfile() {
    return _localDataSource.watchProfile();
  }
}
