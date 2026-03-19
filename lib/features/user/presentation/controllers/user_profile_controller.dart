import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_track/features/user/constants/user_messages.dart';
import 'package:work_track/features/user/domain/entities/user_profile.dart';
import 'package:work_track/shared/providers/app_providers.dart';

final userProfileControllerProvider =
    NotifierProvider<UserProfileController, UserProfileControllerState>(
      UserProfileController.new,
    );

class UserProfileController extends Notifier<UserProfileControllerState> {
  @override
  UserProfileControllerState build() {
    return const UserProfileControllerState();
  }

  Future<void> saveProfile(UserProfile profile) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      await ref.read(saveUserProfileUseCaseProvider).call(profile);
      state = state.copyWith(isSaving: false, lastSavedAt: DateTime.now());
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: UserMessages.saveProfileError,
      );
    }
  }

  Future<void> upsertProfile({
    required String id,
    required String displayName,
    String? email,
    DateTime? birthDate,
    String? photoPath,
  }) async {
    await saveProfile(
      UserProfile(
        id: id,
        displayName: displayName,
        email: email,
        birthDate: birthDate,
        photoPath: photoPath,
      ),
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

class UserProfileControllerState {
  const UserProfileControllerState({
    this.isSaving = false,
    this.errorMessage,
    this.lastSavedAt,
  });

  final bool isSaving;
  final String? errorMessage;
  final DateTime? lastSavedAt;

  UserProfileControllerState copyWith({
    bool? isSaving,
    String? errorMessage,
    DateTime? lastSavedAt,
    bool clearError = false,
    bool clearLastSavedAt = false,
  }) {
    return UserProfileControllerState(
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      lastSavedAt: clearLastSavedAt ? null : lastSavedAt ?? this.lastSavedAt,
    );
  }
}
