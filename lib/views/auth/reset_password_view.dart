import 'package:find_uf/constants/routes.dart';
import 'package:find_uf/services/auth/auth_service.dart';
import 'package:find_uf/tools/dialogs.dart';
import 'package:find_uf/views/components/tap_button.dart';
import 'package:flutter/material.dart';

class ResetPasswordView extends StatefulWidget {
  final String? email;

  const ResetPasswordView({super.key, this.email});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final TextEditingController _token = TextEditingController();
  final TextEditingController _novaSenha = TextEditingController();
  final TextEditingController _confirmarSenha = TextEditingController();

  bool _esconderSenha = true;
  bool _esconderConfirmacao = true;

  /// Função para atuaização de senha esquecida.
  ///
  /// Verifica os campos de texto das senhas e do token.
  /// Verifica se já está logado, para os casos em que o usuário usou o Token e está autenticado,
  /// mas devido a alguma Exception, não teve a senha alterada.
  ///
  /// Redireciona o usuário para a tela principal.
  Future<void> _atualizarSenha(BuildContext context) async {
    try {
      if (_token.text.isEmpty || _token.text.length != 6) {
        showErrorDialog(
          context,
          title: "Token inválido",
          message: "O token deve ter 6 dígitos",
        );
        return;
      }

      if (_novaSenha.text.isEmpty || _novaSenha.text.length < 6) {
        showErrorDialog(
          context,
          title: "Senha inválida",
          message: "A senha deve ter no mínimo 6 caracteres",
        );
        return;
      }

      if (_novaSenha.text != _confirmarSenha.text) {
        showErrorDialog(
          context,
          title: "Erro ao mudar senha",
          message: "As senhas não conferem",
        );
        return;
      }

      // Verificar se já está logado ou precisa validar token
      if (AuthService.supabase().getUser == null) {
        await AuthService.supabase().confirmPasswordRecoverToken(
          token: _token.text,
          email: widget.email,
        );
      }

      await AuthService.supabase().updateUser(password: _novaSenha.text);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Senha atualizada com sucesso!')));

      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(homeRoute, (route) => false);
    } catch (e) {
      showErrorDialog(
        context,
        title: "Erro ao mudar senha",
        message: e.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Atualizar Senha",
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
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
                "Digite o código de 6 dígitos enviado ao seu e-mail, "
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
                  labelText: "Código (6 dígitos)",
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
