import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/firebase_auth_service.dart';
import '../../services/user_firestore_service.dart';

/// --------------------
/// Providers
/// --------------------

final authServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

final userFirestoreServiceProvider =
Provider<UserFirestoreService>((ref) {
  return UserFirestoreService();
});

final authViewModelProvider =
StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  final authService = ref.read(authServiceProvider);
  return AuthViewModel(ref, authService);
});

/// --------------------
/// ViewModel
/// --------------------

class AuthViewModel extends StateNotifier<AuthState> {
  final Ref _ref;
  final FirebaseAuthService _authService;

  AuthViewModel(this._ref, this._authService)
      : super(AuthState.initial());

  /// LOGIN
  Future<void> login(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// REGISTER + CREATE FIRESTORE USER
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role, // seeker | employer
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final user = await _authService.registerWithEmail(
        email: email,
        password: password,
      );

      if (user == null) {
        throw Exception('User registration failed');
      }

      final firestoreService =
      _ref.read(userFirestoreServiceProvider);

      await firestoreService.createUser(
        firebaseUser: user,
        name: name,
        role: role,
      );

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
  }
}

/// --------------------
/// State
/// --------------------

class AuthState {
  final bool isLoading;
  final String? error;

  AuthState({
    required this.isLoading,
    this.error,
  });

  factory AuthState.initial() {
    return AuthState(isLoading: false);
  }

  AuthState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
