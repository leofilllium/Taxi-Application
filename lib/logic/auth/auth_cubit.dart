import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

/// Cubit for managing authentication state.
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(const AuthInitial());

  /// Check if user is already authenticated (e.g., on app startup).
  Future<void> checkAuthStatus() async {
    emit(const AuthLoading());
    try {
      final isAuth = await _authRepository.isAuthenticated();
      if (isAuth) {
        final userType = await _authRepository.getUserType();
        final userId = await _authRepository.getUserId();
        final token = await _authRepository.getToken();
        
        if (userType != null && token != null) {
          emit(Authenticated(
            userId: userId ?? '',
            userType: userType,
            token: token,
          ));
        } else {
          emit(const Unauthenticated());
        }
      } else {
        emit(const Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Login with email and password.
  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());
    try {
      final data = await _authRepository.login(
        email: email,
        password: password,
      );
      emit(Authenticated(
        userId: data['user']['id'] ?? data['userId'] ?? '',
        userType: data['user']['userType'],
        token: data['token'],
      ));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Register a new user.
  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String userType,
    Map<String, dynamic>? vehicleData,
    XFile? profileImage,
  }) async {
    emit(const AuthLoading());
    try {
      final data = await _authRepository.register(
        email: email,
        password: password,
        name: name,
        phone: phone,
        userType: userType,
        vehicleData: vehicleData,
        profileImage: profileImage,
      );
      emit(Authenticated(
        userId: data['user']['id'] ?? data['userId'] ?? '',
        userType: data['user']['userType'],
        token: data['token'],
      ));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Logout the current user.
  Future<void> logout() async {
    await _authRepository.logout();
    emit(const Unauthenticated());
  }

  /// Clear error and return to unauthenticated state.
  void clearError() {
    emit(const Unauthenticated());
  }
}
