import 'package:work_track/features/user/data/datasources/user_local_data_source.dart';
import 'package:work_track/features/user/data/mappers/user_profile_mapper.dart';
import 'package:work_track/features/user/domain/entities/user_profile.dart';
import 'package:work_track/features/user/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  const UserRepositoryImpl(this._localDataSource);

  final UserLocalDataSource _localDataSource;

  @override
  UserProfile? getProfile() {
    return _localDataSource.getProfile()?.toEntity();
  }

  @override
  Future<void> saveProfile(UserProfile profile) {
    return _localDataSource.saveProfile(profile.toModel());
  }

  @override
  Future<void> clearProfile() {
    return _localDataSource.clearProfile();
  }

  @override
  Stream<UserProfile?> watchProfile() {
    return _localDataSource.watchProfile().map(
      (profile) => profile?.toEntity(),
    );
  }
}
