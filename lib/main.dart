import 'package:find_uf/constants/route.dart';
import 'package:find_uf/services/auth/supabase_config.dart';
import 'package:find_uf/views/auth/login_view.dart';
import 'package:find_uf/views/auth/registro_view.dart';
import 'package:find_uf/views/home.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseApiKey );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
       
      ),
      home: const RegistroView(),
      routes: 
      {
        loginRoute:(context) => LoginView(),
        registroRoute:(context)  => RegistroView(),
        homeRoute:(context) => HomePage(),

      }
    );
  }
}

