import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:find_uf/constants/route.dart';
import 'package:find_uf/services/profile_service.dart';
import 'package:find_uf/services/supabase_config.dart';
import 'package:find_uf/views/auth/forgot_password_view.dart';
import 'package:find_uf/views/auth/login_view.dart';
import 'package:find_uf/views/auth/register_view.dart';
import 'package:find_uf/views/auth/reset_password_view.dart';
import 'package:find_uf/views/auth/verificar_email_view.dart';
import 'package:find_uf/views/home.dart';
import 'package:find_uf/views/profile/complete_profile_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Bloqueia a orientação para retrato
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  /// Inicializa o Supabase e permite login com tokens e etc
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseApiKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<Uri>? _linkSubscription;
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();

    initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();

    super.dispose();
  }

  Future<void> initDeepLinks() async {
    // Handle links
    _linkSubscription = AppLinks().uriLinkStream.listen((uri) {
      debugPrint('onAppLink: $uri');
    });
  }

  void openAppLink(Uri uri) {
    debugPrint('uri.path ${uri.path}');
    if (uri.path.contains('emailverification')) {
      debugPrint('Navigating to email verification callback route');
      _navigatorKey.currentState?.pushNamedAndRemoveUntil(
        emailVerificationCallbackRoute,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FindlUF',
      theme: ThemeData(),
      navigatorKey: _navigatorKey,
      home: const AuthGate(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case loginRoute:
            return MaterialPageRoute(builder: (_) => LoginView());
          case registerRoute:
            return MaterialPageRoute(builder: (_) => RegisterView());
          case homeRoute:
            return MaterialPageRoute(builder: (_) => HomePage());
          case verifyEmailRoute:
            final email = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => VerificarEmailView(email: email),
            );
          case forgotPasswordRoute:
            return MaterialPageRoute(builder: (_) => ForgotPasswordView());
          case resetPasswordRoute:
            final email = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => ResetPasswordView(email: email),
            );
          case completeProfileRoute:
            return MaterialPageRoute(
              builder: (_) => const CompleteProfileView(),
            );
          case emailVerificationCallbackRoute:
            return MaterialPageRoute(builder: (_) => CompleteProfileView());
          default:
            return MaterialPageRoute(builder: (_) => RegisterView());
        }
      },
    );
  }
}

// Widget que verifica o estado de autenticação e decide a rota inicial
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  /// Método auxiliar que verifica sessão atual e perfil do usuário
  Future<Map<String, dynamic>> _checkSessionAndProfile() async {
    final supabase = Supabase.instance.client;
    final session = supabase.auth.currentSession;

    if (session == null) {
      return {'hasSession': false, 'hasProfile': false};
    }

    final userId = session.user.id;
    final profileExists = await ProfileService().profileExists(userId);

    return {'hasSession': true, 'hasProfile': profileExists};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _checkSessionAndProfile(),
      builder: (context, snapshot) {
        // Enquanto verifica, mostra um loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data =
            snapshot.data ?? {'hasSession': false, 'hasProfile': false};
        final hasSession = data['hasSession'] as bool;
        final hasProfile = data['hasProfile'] as bool;

        if (!hasSession) {
          // Sem sessão -> login
          return LoginView();
        }

        if (!hasProfile) {
          // Tem sessão mas sem perfil -> completar perfil
          return const CompleteProfileView();
        }

        // Tem sessão e perfil -> home
        return HomePage();
      },
    );
  }
}
