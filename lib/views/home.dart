import 'package:find_uf/constants/route.dart';
import 'package:find_uf/models/profile.dart';
import 'package:find_uf/services/auth/auth_service.dart';
import 'package:find_uf/services/profile_service.dart';
import 'package:find_uf/tools/dialogs.dart';
import 'package:find_uf/views/widgets/tap_button.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  late Future<Profile> _profileFuture;

  @override
  void initState() {
    super.initState();
    final userId = AuthService.supabase().getUser!.id;
    debugPrint('Fetching profile for userId: $userId');
    _profileFuture = ProfileService().getProfile(userId);
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.supabase().getUser!;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF173C7B),
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<Profile>(
        future: _profileFuture,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Erro ao carregar perfil: ${snapshot.error}",
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      TapButton(
                        onTap: () {
                          try {
                            AuthService.supabase().logout();

                            Navigator.of(context).pushNamedAndRemoveUntil(
                              loginRoute,
                              (route) => false,
                            );
                          } catch (e) {
                            showErrorDialog(
                              context,
                              title: "Erro ao fazer logout",
                              message: e.toString(),
                            );
                          }
                        },
                        text: "Deslogar",
                        color: Color.fromARGB(255, 23, 60, 123),
                      ),
                    ],
                  ),
                );
              }
              final profile = snapshot.data as Profile;
              return SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 80,
                          backgroundImage: NetworkImage(profile.fotoUrl),
                        ),
                        SizedBox(height: 16),
                        Text(
                          profile.nome,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          user.email,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        SizedBox(height: 16),
                        TapButton(
                          onTap: () {
                            try {
                              AuthService.supabase().logout();

                              Navigator.of(context).pushNamedAndRemoveUntil(
                                loginRoute,
                                (route) => false,
                              );
                            } catch (e) {
                              showErrorDialog(
                                context,
                                title: "Erro ao fazer logout",
                                message: e.toString(),
                              );
                            }
                          },
                          text: "Deslogar",
                          color: Color.fromARGB(255, 23, 60, 123),
                        ),
                      ],
                    ),
                  ),
                ),
              );

            default:
              return const CircularProgressIndicator(color: Colors.redAccent);
          }
        },
      ),
    );
  }
}
