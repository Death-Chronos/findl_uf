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
      final response = await supabase.auth.signUp(
        password: senha,
        email: email,
      );
      if (response.user == null) {
        throw UserNotLoggedInAuthException();
      }
      return MyAuthUser.fromSupabase(response.user!);
    } on AuthException catch (e) {
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
        case 'over_email_send_rate_limit':
          throw OverEmailSendRateLimitException();
        default:
          print("Erro não explorado: " + e.toString());
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
  Future<MyAuthUser> atualizarUsuario({String? email, String? senha}) async {
    return await supabase.auth
        .updateUser(UserAttributes(email: email, password: senha))
        .then((response) => MyAuthUser.fromSupabase(response.user!));
  }

  @override
  Future<void> deletarConta() {
    // TODO: implement deletarConta
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {
    final user = supabase.auth.currentUser;

    if (user != null) {
      await supabase.auth.signOut();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  MyAuthUser? get getUsuarioAtual {
    final userAtual = supabase.auth.currentUser;
    return userAtual != null ? MyAuthUser.fromSupabase(userAtual) : null;
  }

  @override
  Future<void> enviarVerificacaoEmail({required email}) async {
    await supabase.auth.resend(type: OtpType.signup, email: email);
  }

  @override
  Future<AuthResponse> confirmarTokenRecuperacaoSenha({
    required String token,
    String? email,
  }) async {
    if (email == null) {
      final user = getUsuarioAtual;
      if (user == null) {
        throw UserNotLoggedInAuthException();
      }
      email = user.email;
    }

    return await supabase.auth.verifyOTP(
      type: OtpType.recovery,
      token: token,
      email: email,
    );
  }

  @override
  Future<void> enviarTokenRecuperacaoSenha({required String email}) async {
    return await supabase.auth.resetPasswordForEmail(email);
  }
}
