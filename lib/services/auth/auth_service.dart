import 'package:find_uf/models/my_auth_user.dart';
import 'package:find_uf/services/auth/auth_provider.dart';
import 'package:find_uf/services/auth/supabase_auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService implements AuthProvider {
  final AuthProvider provider;

  const AuthService(this.provider);

  factory AuthService.supabase() {
    return AuthService(SupabaseAuthProvider());
  }

  @override
  Future<MyAuthUser> updateUser({String? email, String? password}) {
    return provider.updateUser(email: email, password: password);
  }

  @override
  Future<void> sendEmailVerification({required String email}) {
    return provider.sendEmailVerification(email: email);
  }

  @override
  Future<void> deleteAccount() {
    return provider.deleteAccount();
  }

  @override
  MyAuthUser? get getUser => provider.getUser;

  @override
  Future<MyAuthUser> login({required String email, required String password}) {
    return provider.login(email: email, password: password);
  }

  @override
  Future<void> logout() {
    return provider.logout();
  }

  @override
  Future<void> registerUser({
    required String email,
    required String password,
  }) {
    return provider.registerUser(email: email, password: password);
  }

  @override
  Future<AuthResponse> confirmPasswordRecoverToken({
    required String token,
    String? email,
  }) {
    return provider.confirmPasswordRecoverToken(token: token, email: email);
  }

  @override
  Future<void> sendPasswordRecoverToken({required String email}) {
    return provider.sendPasswordRecoverToken(email: email);
  }
  
  @override
  Future<String> updatePasswordWithCurrent({required String currentPassword, required String newPassword}) {
    return provider.updatePasswordWithCurrent(currentPassword: currentPassword, newPassword: newPassword);
  }
}
