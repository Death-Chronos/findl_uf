import 'package:find_uf/models/my_auth_user.dart';
import 'package:find_uf/services/auth/auth_provider.dart';
import 'package:find_uf/services/auth/supabase_auth_provider.dart';

class AuthService implements AuthProvider {
  final AuthProvider provider;

  const AuthService(this.provider);

  factory AuthService.supabase() {
    return AuthService(SupabaseAuthProvider());
  }

  @override
  Future<MyAuthUser> atualizarUsuario({String? email, String? senha}) {
    return provider.atualizarUsuario(email: email, senha: senha);
  }

  @override
  Future<void> enviarVerificacaoEmail({required String email}) {
    return provider.enviarVerificacaoEmail(email: email);
  }

  @override
  Future<void> deletarConta() {
    return provider.deletarConta();
  }

  @override
  MyAuthUser? get getUsuarioAtual => provider.getUsuarioAtual;

  @override
  Future<MyAuthUser> login({required String email, required String senha}) {
    return provider.login(email: email, senha: senha);
  }

  @override
  Future<void> logout() {
    return provider.logout();
  }

  @override
  Future<MyAuthUser> registrarUser({
    required String email,
    required String senha,
  }) {
    return provider.registrarUser(email: email, senha: senha);
  }

  @override
  Future<void> resetarSenha({required String email}) {
    return provider.resetarSenha(email: email);
  }
}
