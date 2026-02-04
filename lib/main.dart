import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:find_uf/constants/routes.dart';
import 'package:find_uf/models/lost_and_find_item.dart';
import 'package:find_uf/services/profile_service.dart';
import 'package:find_uf/supabase.dart';
import 'package:find_uf/views/auth/complete_profile_view.dart';
import 'package:find_uf/views/auth/forgot_password_view.dart';
import 'package:find_uf/views/auth/login_view.dart';
import 'package:find_uf/views/auth/register_view.dart';
import 'package:find_uf/views/auth/reset_password_view.dart';
import 'package:find_uf/views/auth/verify_email_view.dart';
import 'package:find_uf/views/home_view.dart';
import 'package:find_uf/views/items/create_lost_and_found_item_view.dart';
import 'package:find_uf/views/items/item_detail_view.dart';
import 'package:find_uf/views/profile/change_password_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Bloqueia a orientação para retrato
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  /// Inicializa o Supabase e permite login com tokens e etc
  await Supabase.initialize(
    url: SUPABASE_URL,
    anonKey: SUPABASE_ANON_KEY,
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
    final appLinks = AppLinks();

    // Links quando app já está aberto (hot)
    _linkSubscription = appLinks.uriLinkStream.listen((uri) {
      debugPrint('Link recebido (app aberto): $uri');
      openAppLink(uri);
    });

    try {
      //Links quando o app está fechado (cold)
      final initialUri = await appLinks.getInitialLink();
      if (initialUri != null) {
        debugPrint('Link inicial (abriu o app): $initialUri');
        // Aguarda navigator estar pronto
        WidgetsBinding.instance.addPostFrameCallback((_) {
          openAppLink(initialUri);
        });
      }
    } catch (e) {
      debugPrint('Erro ao obter link inicial: $e');
    }
  }

  void openAppLink(Uri uri) {
    if (uri.path.contains('verify-email')) {
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle(
            systemNavigationBarColor: Colors.black,
            systemNavigationBarIconBrightness: Brightness.light,
          ),
          backgroundColor: Color(0xFF173C7B),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      navigatorKey: _navigatorKey,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'), // Português Brasil
      ],
      locale: const Locale('pt', 'BR'),
      home: const AuthGate(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case loginRoute:
            return MaterialPageRoute(builder: (_) => LoginView());
          case registerRoute:
            return MaterialPageRoute(builder: (_) => RegisterView());
          case homeRoute:
            return MaterialPageRoute(builder: (_) => HomeView());
          case verifyEmailRoute:
            final email = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => VerifyEmailView(email: email),
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

          case changePasswordRoute:
            return MaterialPageRoute(
              builder: (_) => const ChangePasswordView(),
            );

          case createLostAndFoundItemRoute:
            return MaterialPageRoute(
              builder: (_) => const CreateLostAndFoundItemView(),
            );
          case itemDetailsRoute:
            final item = settings.arguments as LostAndFoundItem;
            return MaterialPageRoute(
              builder: (_) => ItemDetailsView(item: item),
            );  
          default:
            return MaterialPageRoute(builder: (_) => RegisterView());
        }
      },
    );
  }
}

// Widget que verifica o estado de autenticação e decide a rota inicial (mudei para StatefulWidget,
// depois verificar se deu certo o problema de voltar para tela de completar perfil)
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _checkSessionAndProfile();
  }

  Future<Map<String, dynamic>> _checkSessionAndProfile() async {
    final supabase = Supabase.instance.client;
    final session = supabase.auth.currentSession;

    if (session == null) {
      return {'hasSession': false, 'hasProfile': false};
    }

    final profileExists = await ProfileService().profileExists(session.user.id);

    return {'hasSession': true, 'hasProfile': profileExists};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data =
            snapshot.data ?? {'hasSession': false, 'hasProfile': false};

        if (!data['hasSession']) return LoginView();
        if (!data['hasProfile']) return const CompleteProfileView();
        return HomeView();
      },
    );
  }
}
