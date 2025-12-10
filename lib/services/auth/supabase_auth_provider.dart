// lib/auth/providers/auth_provider.dart

import 'package:find_uf/services/auth/auth_exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_provider.dart';
// ignore: unused_import
import '../../models/my_auth_user.dart';

class SupabaseAuthProvider extends AuthProvider {
  final auth = Supabase.instance.client.auth;

  @override
  Future<void> registerUser({
    required String email,
    required String senha,
  }) async {
    try {
      final response = await auth.signUp(
        password: senha,
        email: email,
        emailRedirectTo: "online.findluf://emailVerificationCallback",
      );
      if (response.user == null) {
        throw UserNotLoggedInAuthException();
      }
      // return MyAuthUser.fromSupabase(response.user!);
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
          throw GenericAuthException(e.message);
      }
    } catch (e) {
      throw GenericAuthException(e.toString());
    }
  }

  @override
  Future<MyAuthUser> login({
    required String email,
    required String senha,
  }) async {
    try {
      await auth.signInWithPassword(password: senha, email: email);
      final user = getUser;

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
          throw GenericAuthException(e.message);
      }
    } catch (e) {
      throw GenericAuthException(e.toString());
    }
  }

  @override
  Future<MyAuthUser> updateUser({String? email, String? senha}) async {
    return await auth
        .updateUser(UserAttributes(email: email, password: senha))
        .then((response) => MyAuthUser.fromSupabase(response.user!));
  }

  @override
  Future<void> deleteAccount() {
    // TODO: implement deleteAccount
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {
    final user = auth.currentUser;

    if (user != null) {
      await auth.signOut();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  MyAuthUser? get getUser {
    final userAtual = auth.currentUser;
    return userAtual != null ? MyAuthUser.fromSupabase(userAtual) : null;
  }

  @override
  Future<void> sendEmailVerification({required email}) async {
    await auth.resend(
      type: OtpType.signup,
      email: email,
      emailRedirectTo: "online.findluf://emailVerificationCallback",
    );
  }

  @override
  Future<AuthResponse> confirmPasswordRecoverToken({
    required String token,
    String? email,
  }) async {
    if (email == null) {
      final user = getUser;
      if (user == null) {
        throw UserNotLoggedInAuthException();
      }
      email = user.email;
    }

    return await auth.verifyOTP(
      type: OtpType.recovery,
      token: token,
      email: email,
    );
  }

  @override
  Future<void> sendPasswordRecoverToken({required String email}) async {
    return await auth.resetPasswordForEmail(email);
  }
}
