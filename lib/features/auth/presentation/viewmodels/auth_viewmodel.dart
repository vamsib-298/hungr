import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../../core/services/firebase_service.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String userName;
  final String phoneNumber;
  final String dropGate;
  final String? verificationId;
  final int? resendToken;
  final String? errorMessage;

  const AuthState({
    required this.isAuthenticated,
    this.isLoading = false,
    required this.userName,
    required this.phoneNumber,
    required this.dropGate,
    this.verificationId,
    this.resendToken,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? userName,
    String? phoneNumber,
    String? dropGate,
    String? verificationId,
    int? resendToken,
    String? errorMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      userName: userName ?? this.userName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dropGate: dropGate ?? this.dropGate,
      verificationId: verificationId ?? this.verificationId,
      resendToken: resendToken ?? this.resendToken,
      errorMessage: errorMessage,
    );
  }
}

class AuthViewModel extends StateNotifier<AuthState> {
  AuthViewModel()
      : super(
          const AuthState(
            isAuthenticated: false,
            isLoading: false,
            userName: 'Hungr Foodie',
            phoneNumber: '+91 98765 43210',
            dropGate: 'Hostel Security Gate',
          ),
        ) {
    loadSavedSession();
  }

  Future<void> loadSavedSession() async {
    final currentUser = FirebaseService.instance.currentUser;
    final isAuth = await LocalStorageService.instance.isAuthenticated();

    if (currentUser != null || isAuth) {
      final session = await LocalStorageService.instance.getUserSession();
      state = state.copyWith(
        isAuthenticated: true,
        phoneNumber: session['phone'] ?? currentUser?.phoneNumber ?? state.phoneNumber,
        userName: session['name'] ?? state.userName,
        dropGate: session['clusterName'] ?? state.dropGate,
      );
    }
  }

  /// Sends real SMS OTP via Firebase
  Future<void> requestOtp({
    required String phone,
    required String name,
    required void Function() onSuccess,
    required void Function(String error) onError,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    await FirebaseService.instance.sendOtp(
      phoneNumber: phone,
      resendToken: state.resendToken,
      onCodeSent: (verificationId, resendToken) {
        state = state.copyWith(
          isLoading: false,
          verificationId: verificationId,
          resendToken: resendToken,
          phoneNumber: phone,
          userName: name.isNotEmpty ? name : state.userName,
        );
        onSuccess();
      },
      onError: (error) {
        state = state.copyWith(isLoading: false, errorMessage: error);
        onError(error);
      },
      onAutoVerified: (credential) async {
        // Auto-verified on Android!
        try {
          final res = await FirebaseService.instance.auth.signInWithCredential(credential);
          if (res.user != null) {
            login(phone: phone, name: name);
            onSuccess();
          }
        } catch (e) {
          onError('Auto-sign in error: $e');
        }
      },
    );
  }

  /// Verifies the 6-digit OTP code with Firebase
  Future<void> verifyCode({
    required String smsCode,
    required void Function() onSuccess,
    required void Function(String error) onError,
  }) async {
    final vId = state.verificationId;
    if (vId == null || vId.isEmpty) {
      // In development fallback or demo test mode
      login(phone: state.phoneNumber, name: state.userName);
      onSuccess();
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await FirebaseService.instance.verifyOtp(
        verificationId: vId,
        smsCode: smsCode,
        userName: state.userName,
        phoneNumber: state.phoneNumber,
        dropGate: state.dropGate,
      );

      login(phone: state.phoneNumber, name: state.userName);
      state = state.copyWith(isLoading: false);
      onSuccess();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      onError(e.toString());
    }
  }

  void login({required String phone, String? name, String? gate}) {
    final effectiveName = (name != null && name.trim().isNotEmpty) ? name.trim() : state.userName;
    final effectivePhone = phone.isNotEmpty ? phone : state.phoneNumber;
    final effectiveGate = gate ?? state.dropGate;

    state = state.copyWith(
      isAuthenticated: true,
      isLoading: false,
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

  Future<void> logout() async {
    await FirebaseService.instance.signOut();
    state = state.copyWith(isAuthenticated: false);
    await LocalStorageService.instance.clearUserSession();
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

    final user = FirebaseService.instance.currentUser;
    if (user != null) {
      FirebaseService.instance.syncUserProfile(
        uid: user.uid,
        name: state.userName,
        phone: state.phoneNumber,
        dropGate: state.dropGate,
      );
    }
  }
}

final authProvider = StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  return AuthViewModel();
});
