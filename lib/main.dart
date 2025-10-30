import 'package:find_uf/constants/route.dart';
import 'package:find_uf/services/auth/supabase_config.dart';
import 'package:find_uf/views/auth/login_view.dart';
import 'package:find_uf/views/auth/registro_view.dart';
import 'package:find_uf/views/auth/verificar_email_view.dart';
import 'package:find_uf/views/home.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseApiKey);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(),
      initialRoute: registroRoute,
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
            
          default:
            return MaterialPageRoute(builder: (_) => RegistroView());
        }
      },
    );
  }
}