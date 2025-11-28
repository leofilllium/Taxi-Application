import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/repositories/user_repository.dart';
import 'profile_state.dart';

/// Cubit for managing user profile operations.
class ProfileCubit extends Cubit<ProfileState> {
  final UserRepository _userRepository;

  ProfileCubit(this._userRepository) : super(const ProfileInitial());

  /// Load the user's profile data.
  Future<void> loadProfile() async {
    emit(const ProfileLoading());
    try {
      final profileData = await _userRepository.getProfile();
      emit(ProfileLoaded(profileData));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  /// Update the user's profile.
  Future<void> updateProfile(
    Map<String, String> fields,
    XFile? image,
  ) async {
    emit(const ProfileUpdating());
    try {
      final updatedData = await _userRepository.updateProfile(fields, image);
      emit(ProfileUpdated(updatedData));
      // Transition back to loaded state after a brief moment
      await Future.delayed(const Duration(milliseconds: 500));
      emit(ProfileLoaded(updatedData));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  /// Delete the user's account.
  Future<void> deleteAccount() async {
    emit(const ProfileDeleting());
    try {
      await _userRepository.deleteAccount();
      emit(const ProfileDeleted());
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  /// Clear error and reload profile.
  Future<void> retry() async {
    await loadProfile();
  }
}
