import 'package:find_uf/models/my_auth_user.dart';

abstract class AuthProvider {
  /// Registra um novo usuário
  Future<MyAuthUser> registrarUser({
    required String email,
    required String senha,
  });

  /// Realiza login do usuário
  Future<MyAuthUser> login({
    required String email,
    required String senha,
  });

  /// Faz logout do usuário atual
  Future<void> logout();

  /// Envia email para resetar senha
  Future<void> resetarSenha({
    required String email,
  });

  /// Confirma email do usuário
  Future<void> enviarVerificacaoEmail();

  /// Verifica se o usuário está logado
  Future<bool> estaLogado();

  /// Obtém o usuário atual
  MyAuthUser? get getUsuarioAtual;

  /// Atualiza dados do usuário
  Future<MyAuthUser> atualizarUsuario({
     String? email,
     String? senha,
  });

  /// Deleta conta do usuário
  Future<void> deletarConta();

  
}