import 'package:equatable/equatable.dart';

/// Base class for authentication states.
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the app starts, before auth status is checked.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state during login, registration, or auth check.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Authenticated state when user is logged in.
class Authenticated extends AuthState {
  final String userId;
  final String userType; // 'client' or 'driver'
  final String token;

  const Authenticated({
    required this.userId,
    required this.userType,
    required this.token,
  });

  @override
  List<Object?> get props => [userId, userType, token];
}

/// Unauthenticated state when user is not logged in.
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// Error state when authentication fails.
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
