import 'package:find_uf/models/my_auth_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthProvider {
  /// Registra um novo usuário
  Future<void> registerUser({
    required String email,
    required String password,
  });

  /// Realiza login do usuário
  Future<MyAuthUser> login({required String email, required String password});

  /// Faz logout do usuário atual
  Future<void> logout();

  Future<String> updatePasswordWithCurrent({
    required String currentPassword,
    required String newPassword,
  });

  /// Envia email com token para resetar password
  Future<void> sendPasswordRecoverToken({required String email});

  /// Confirma o token
  Future<AuthResponse> confirmPasswordRecoverToken({
    required String token,
    String? email,
  });

  /// Confirma email do usuário
  Future<void> sendEmailVerification({required String email});

  /// Obtém o usuário atual
  MyAuthUser? get getUser;

  /// Atualiza dados do usuário
  Future<MyAuthUser> updateUser({String? email, String? password});

  /// Deleta conta do usuário
  Future<void> deleteAccount();
}
