import 'package:work_track/features/user/data/models/user_profile_model.dart'
    as model;
import 'package:work_track/features/user/domain/entities/user_profile.dart'
    as entity;

extension UserProfileModelMapper on model.UserProfileModel {
  entity.UserProfile toEntity() {
    return entity.UserProfile(
      id: id,
      displayName: displayName,
      email: email,
      birthDate: birthDate,
      photoPath: photoPath,
    );
  }
}

extension UserProfileEntityMapper on entity.UserProfile {
  model.UserProfileModel toModel() {
    return model.UserProfileModel(
      id: id,
      displayName: displayName,
      email: email,
      birthDate: birthDate,
      photoPath: photoPath,
    );
  }
}
