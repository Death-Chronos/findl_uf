import 'package:find_uf/models/my_auth_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthProvider {
  /// Registra um novo usuário
  Future<MyAuthUser> registrarUser({
    required String email,
    required String senha,
  });

  /// Realiza login do usuário
  Future<MyAuthUser> login({required String email, required String senha});

  /// Faz logout do usuário atual
  Future<void> logout();

  /// Envia email com token para resetar senha
  Future<void> enviarTokenRecuperacaoSenha({required String email});

  /// Confirma o token
  Future<AuthResponse> confirmarTokenRecuperacaoSenha({
    required String token,
    String? email,
  });

  /// Confirma email do usuário
  Future<void> enviarVerificacaoEmail({required String email});

  /// Obtém o usuário atual
  MyAuthUser? get getUsuarioAtual;

  /// Atualiza dados do usuário
  Future<MyAuthUser> atualizarUsuario({String? email, String? senha});

  /// Deleta conta do usuário
  Future<void> deletarConta();
}
