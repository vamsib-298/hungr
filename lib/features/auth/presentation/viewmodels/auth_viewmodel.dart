import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/local_storage_service.dart';

class AuthState {
  final bool isAuthenticated;
  final String userName;
  final String phoneNumber;
  final String dropGate;

  const AuthState({
    required this.isAuthenticated,
    required this.userName,
    required this.phoneNumber,
    required this.dropGate,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? userName,
    String? phoneNumber,
    String? dropGate,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userName: userName ?? this.userName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dropGate: dropGate ?? this.dropGate,
    );
  }
}

class AuthViewModel extends StateNotifier<AuthState> {
  AuthViewModel()
      : super(
          const AuthState(
            isAuthenticated: false,
            userName: 'Vamsi Krishna',
            phoneNumber: '+91 98765 43210',
            dropGate: 'Sri Sai Boys Hostel Gate',
          ),
        ) {
    loadSavedSession();
  }

  Future<void> loadSavedSession() async {
    final isAuth = await LocalStorageService.instance.isAuthenticated();
    if (isAuth) {
      final session = await LocalStorageService.instance.getUserSession();
      state = state.copyWith(
        isAuthenticated: true,
        phoneNumber: session['phone'],
        userName: session['name'],
        dropGate: session['clusterName'],
      );
    }
  }

  void login({required String phone, String? name, String? gate}) {
    final effectiveName = (name != null && name.trim().isNotEmpty) ? name.trim() : state.userName;
    final effectivePhone = phone.isNotEmpty ? phone : state.phoneNumber;
    final effectiveGate = gate ?? state.dropGate;

    state = state.copyWith(
      isAuthenticated: true,
      phoneNumber: effectivePhone,
      userName: effectiveName,
      dropGate: effectiveGate,
    );

    LocalStorageService.instance.saveUserSession(
      phone: effectivePhone,
      name: effectiveName,
      clusterName: effectiveGate,
    );
  }

  void logout() {
    state = state.copyWith(isAuthenticated: false);
    LocalStorageService.instance.clearUserSession();
  }

  void updateProfile({String? name, String? gate}) {
    state = state.copyWith(
      userName: name ?? state.userName,
      dropGate: gate ?? state.dropGate,
    );

    LocalStorageService.instance.saveUserSession(
      phone: state.phoneNumber,
      name: state.userName,
      clusterName: state.dropGate,
    );
  }
}

final authProvider = StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  return AuthViewModel();
});
