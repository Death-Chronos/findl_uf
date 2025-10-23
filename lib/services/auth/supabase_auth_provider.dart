// lib/auth/providers/supabase_auth_provider.dart

import 'package:find_uf/services/auth/auth_exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_provider.dart';
// ignore: unused_import
import '../../models/my_auth_user.dart';

class SupabaseAuthProvider extends AuthProvider {
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  Future<MyAuthUser> registrarUser({
    required String email,
    required String senha,
  }) async {
    try {
      await supabase.auth.signUp(password: senha, email: email);

      final user = getUsuarioAtual;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on AuthException catch (e) {
      // Supabase usa error.code para identificar erros, não error.message
      switch (e.code) {
        case 'weak_password':
          throw WeakPasswordAuthException();
        case 'email_exists':
        case 'user_already_exists':
          throw EmailAlreadyInUseAuthException();
        case 'email_address_invalid':
        case 'validation_failed':
          throw InvalidEmailAuthException();
        case 'invalid_credentials':
          throw InvalidCredentialsAuthException();
        case 'email_not_confirmed':
          throw EmailNotConfirmedAuthException();

        case 'user_not_found':
          throw UserNotFoundAuthException();
        case 'same_password':
          throw SamePasswordAuthException();
        case 'session_not_found':
        case 'session_expired':
          throw SessionExpiredAuthException();
        default:
          throw GenericAuthException();
      }
    } catch (e) {
      throw GenericAuthException();
    }
  }

  @override
  Future<MyAuthUser> login({
    required String email,
    required String senha,
  }) async {
    try {
      await supabase.auth.signInWithPassword(password: senha, email: email);

      final user = getUsuarioAtual;

      if (user != null) {
        return user;
        
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on AuthException catch (e) {
      switch (e.code) {
        case 'invalid_credentials':
          throw InvalidCredentialsAuthException();

        case 'email_not_confirmed':
          throw EmailNotConfirmedAuthException();

        case 'over_request_rate_limit':
        case 'over_email_send_rate_limit':
          throw TooManyRequestsAuthException();

        case 'session_expired':
        case 'refresh_token_not_found':
          throw SessionExpiredAuthException();

        default:
          throw GenericAuthException();
      }
    } catch (e) {
      throw GenericAuthException();
    }
  }

  @override
  Future<MyAuthUser> atualizarUsuario({String? email, String? senha}) {
    // TODO: implement atualizarUsuario
    throw UnimplementedError();
  }

  @override
  Future<void> deletarConta() {
    // TODO: implement deletarConta
    throw UnimplementedError();
  }

  @override
  Future<bool> estaLogado() {
    // TODO: implement estaLogado
    throw UnimplementedError();
  }

  @override
  Future<void> logout() {
    final user = supabase.auth.currentUser;

    if (user != null) {
      return supabase.auth.signOut();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  MyAuthUser? get getUsuarioAtual {
    final user = supabase.auth.currentUser;

    if (user != null) {
      return MyAuthUser.fromSupabase(user);
    } else {
      return null;
    }
  }

  @override
  Future<void> resetarSenha({required String email}) {
    // TODO: implement resetarSenha
    throw UnimplementedError();
  }

  @override
  Future<void> enviarVerificacaoEmail() async {
    final user = getUsuarioAtual;

    if (user != null) {
      await supabase.auth.resend(type: OtpType.signup, email: user.email);
    } else {
      throw UserNotLoggedInAuthException();
    }
  }
}
