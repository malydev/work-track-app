import 'dart:async';

import 'package:hive/hive.dart';
import 'package:work_track/core/storage/hive_boxes.dart';
import 'package:work_track/features/user/data/models/user_profile_model.dart';

abstract interface class UserLocalDataSource {
  UserProfileModel? getProfile();
  Future<void> saveProfile(UserProfileModel profile);
  Future<void> clearProfile();
  Stream<UserProfileModel?> watchProfile();
}

class HiveUserLocalDataSource implements UserLocalDataSource {
  HiveUserLocalDataSource(this._box);

  factory HiveUserLocalDataSource.fromHive() {
    return HiveUserLocalDataSource(
      Hive.box<UserProfileModel>(HiveBoxes.userProfile),
    );
  }

  static const _profileKey = 'current';

  final Box<UserProfileModel> _box;

  @override
  UserProfileModel? getProfile() {
    return _box.get(_profileKey);
  }

  @override
  Future<void> saveProfile(UserProfileModel profile) {
    return _box.put(_profileKey, profile);
  }

  @override
  Future<void> clearProfile() {
    return _box.delete(_profileKey);
  }

  @override
  Stream<UserProfileModel?> watchProfile() async* {
    yield getProfile();
    yield* _box.watch(key: _profileKey).map((_) => getProfile());
  }
}
