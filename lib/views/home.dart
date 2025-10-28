import 'package:find_uf/constants/route.dart';
import 'package:find_uf/services/auth/auth_service.dart';
import 'package:find_uf/views/widgets/tap_button.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final VoidCallback? onLogout;

  const HomePage({Key? key, this.onLogout}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Mantém conteúdo longe das áreas não seguras (notch, barras)
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Bom trabalho',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                ),

                const SizedBox(height: 24),

                TapButton(
                  onTap: () async {
                    try {
                      await AuthService.supabase().logout();

                      Navigator.of(context).pushNamedAndRemoveUntil(
                        registroRoute,
                        (route) => false,
                      );
                    } catch (e) {}
                  },
                  text: "Deslogar",
                  color: Color.fromARGB(255, 23, 60, 123),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
