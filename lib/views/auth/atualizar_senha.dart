import 'package:find_uf/constants/route.dart';
import 'package:find_uf/services/auth/auth_service.dart';
import 'package:find_uf/views/widgets/tap_button.dart';
import 'package:flutter/material.dart';

class AtualizarSenha extends StatefulWidget {
  final String? email;

  const AtualizarSenha({super.key, this.email});

  @override
  State<AtualizarSenha> createState() => _AtualizarSenhaState();
}

class _AtualizarSenhaState extends State<AtualizarSenha> {
  final TextEditingController _token = TextEditingController();
  final TextEditingController _novaSenha = TextEditingController();
  final TextEditingController _confirmarSenha = TextEditingController();

  bool _esconderSenha = true;
  bool _esconderConfirmacao = true;

  Future<void> _atualizarSenha(BuildContext context) async {
    await AuthService.supabase().confirmarTokenRecuperacaoSenha(
      token: _token.text,
      email: widget.email,
    );

    await AuthService.supabase().atualizarUsuario(senha: _novaSenha.text);

    final usuario = AuthService.supabase().getUsuarioAtual;
    if (usuario != null) {
      // Usuário logado -> Home
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(homeRoute, (route) => false);
    } else {
      // Usuário deslogado -> Login
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(loginRoute, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Atualizar Senha"), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho
              const Text(
                "Redefina sua senha",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Digite o token de 6 dígitos enviado ao seu e-mail, "
                "crie uma nova senha e confirme abaixo.",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 36),

              // Campo de token
              TextField(
                controller: _token,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  counterText: "", // oculta o contador de caracteres
                  labelText: "Token (6 dígitos)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.verified_user_outlined),
                ),
              ),
              const SizedBox(height: 24),

              // Nova senha
              TextField(
                controller: _novaSenha,
                obscureText: _esconderSenha,
                decoration: InputDecoration(
                  labelText: "Nova senha",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _esconderSenha ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() => _esconderSenha = !_esconderSenha);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Confirmar senha
              TextField(
                controller: _confirmarSenha,
                obscureText: _esconderConfirmacao,
                decoration: InputDecoration(
                  labelText: "Confirmar nova senha",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock_reset),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _esconderConfirmacao
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(
                        () => _esconderConfirmacao = !_esconderConfirmacao,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: TapButton(
                  text: "Atualizar Senha",
                  onTap: () async {
                    _atualizarSenha(context);
                  },
                  color: const Color(0xFF99C842),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
