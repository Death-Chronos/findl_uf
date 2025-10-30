import 'package:flutter/material.dart';
import 'package:find_uf/views/widgets/tap_button.dart';
import 'package:find_uf/services/auth/auth_service.dart';

class VerificarEmailView extends StatelessWidget {
  final String email;

  const VerificarEmailView({super.key, required this.email});

  Future<void> _reenviarEmail(BuildContext context) async {
    try {
      await AuthService.supabase().enviarVerificacaoEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("E-mail de verificação reenviado com sucesso!"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao reenviar o e-mail: $e"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verificar e-mail"),
        centerTitle: true,
        backgroundColor: const Color(0xFF173C7B),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.email_outlined,
                  size: 80,
                  color: Color(0xFF173C7B),
                ),
                const SizedBox(height: 24),
                Text(
                  "Confirmação de e-mail para:",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  email,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Verifique sua caixa de entrada (ou pasta de spam) e clique no link para ativar sua conta.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.black54),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Caso o link tenha expirado, você pode reenviar o e-mail abaixo:",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.black54),
                ),
                const SizedBox(height: 32),
                TapButton(
                  onTap: () => _reenviarEmail(context),
                  text: "Reenviar e-mail de confirmação",
                  color: const Color(0xFF173C7B),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
