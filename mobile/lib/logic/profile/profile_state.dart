import 'package:equatable/equatable.dart';

/// Base class for profile-related states.
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

/// Initial state before profile is loaded.
class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

/// Loading state while fetching profile.
class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

/// Profile successfully loaded.
class ProfileLoaded extends ProfileState {
  final Map<String, dynamic> profileData;

  const ProfileLoaded(this.profileData);

  @override
  List<Object?> get props => [profileData];
}

/// Profile is being updated.
class ProfileUpdating extends ProfileState {
  const ProfileUpdating();
}

/// Profile successfully updated.
class ProfileUpdated extends ProfileState {
  final Map<String, dynamic> profileData;

  const ProfileUpdated(this.profileData);

  @override
  List<Object?> get props => [profileData];
}

/// Error occurred while loading or updating profile.
class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Account deletion in progress.
class ProfileDeleting extends ProfileState {
  const ProfileDeleting();
}

/// Account successfully deleted.
class ProfileDeleted extends ProfileState {
  const ProfileDeleted();
}
