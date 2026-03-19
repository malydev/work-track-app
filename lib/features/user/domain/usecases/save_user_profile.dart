import 'package:work_track/features/user/domain/entities/user_profile.dart';
import 'package:work_track/features/user/domain/repositories/user_repository.dart';

class SaveUserProfile {
  const SaveUserProfile(this._repository);

  final UserRepository _repository;

  Future<void> call(UserProfile profile) {
    return _repository.saveProfile(profile);
  }
}
