import 'package:find_uf/constants/route.dart';
import 'package:find_uf/services/auth/supabase_config.dart';
import 'package:find_uf/views/auth/atualizar_senha.dart';
import 'package:find_uf/views/auth/login_view.dart';
import 'package:find_uf/views/auth/registro_view.dart';
import 'package:find_uf/views/auth/resetar_senha_view.dart';
import 'package:find_uf/views/auth/verificar_email_view.dart';
import 'package:find_uf/views/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseApiKey);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FindlUF',
      theme: ThemeData(),
      home: const AuthGate(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case loginRoute:
            return MaterialPageRoute(builder: (_) => LoginView());
          case registroRoute:
            return MaterialPageRoute(builder: (_) => RegistroView());
          case homeRoute:
            return MaterialPageRoute(builder: (_) => HomePage());
          case verificarEmailRoute:
            final email = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => VerificarEmailView(email: email),
            );
          case resetarSenhaRoute:
            return MaterialPageRoute(builder: (_) => ResetarSenhaView());
          case atualizarSenhaRoute:
            final email = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => AtualizarSenha(email: email),
            );
          default:
            return MaterialPageRoute(builder: (_) => RegistroView());
        }
      },
    );
  }
}

// Widget que verifica o estado de autenticação e decide a rota inicial
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Session?>(
      // Verifica se existe uma sessão ativa do Supabase
      future: _checkSession(),
      builder: (context, snapshot) {
        // Enquanto verifica, mostra um loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Quando terminar de verificar, decide a tela baseado na sessão
        final session = snapshot.data;

        if (session != null) {
          return HomePage();
        } else {
          // Sem sessão -> vai para login
          return LoginView();
        }
      },
    );
  }

  // Método auxiliar que busca a sessão atual
  Future<Session?> _checkSession() async {
    final supabase = Supabase.instance.client;
    return supabase.auth.currentSession;
  }
}
