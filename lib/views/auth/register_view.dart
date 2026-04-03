import 'package:findl_uf/constants/routes.dart';
import 'package:findl_uf/services/auth/auth_service.dart';
import 'package:findl_uf/tools/dialogs.dart';
import 'package:findl_uf/tools/validacoes.dart';
import 'package:findl_uf/views/components/tap_button.dart';
import 'package:flutter/material.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  bool _esconderSenha = true;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _mostrarErro(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  bool _validarCampos() {
    final erroEmail = Validacoes.validarEmail(_email.text);
    if (erroEmail != null) {
      _mostrarErro(erroEmail);
      return false;
    }
    final erroDominio = Validacoes.validarDominioUfersa(_email.text);
    if (erroDominio != null) {
      showErrorDialog(
        context,
        title: "Erro com domínio do email",
        message:
            "O domínio do email deve pertercer a UFERSA. Exemplo: @ufersa.edu.br",
      );
      return false;
    }

    if (_password.text.length < 6) {
      _mostrarErro("A senha deve ter pelo menos 6 caracteres.");
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Criar Conta"),
        centerTitle: true,
        backgroundColor: const Color(0xFF99C842),
      ),
      backgroundColor: const Color(0xFFF1F8E9),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Center(
              child: Icon(
                Icons.person_add,
                size: 80,
                color: Color(0xFF689F38),
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                "Crie sua conta",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF689F38),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                "Registre-se com seu e-mail institucional",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 30),

            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email Institucional",
                prefixIcon: Icon(Icons.email, color: Color(0xFF689F38)),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _password,
              autocorrect: false,
              obscureText: _esconderSenha,
              decoration: InputDecoration(
                labelText: "Senha (mínimo 6 caracteres)",
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock, color: Color(0xFF689F38)),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: IconButton(
                  onPressed:
                      () => setState(() => _esconderSenha = !_esconderSenha),
                  icon: Icon(
                    _esconderSenha ? Icons.visibility : Icons.visibility_off,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Center(
              child: TapButton(
                onTap: () async {
                  if (!_validarCampos()) return;

                  try {
                    // Registra o usuário
                    await AuthService.supabase().registerUser(
                      email: _email.text,
                      password: _password.text,
                    );

                    Navigator.of(context).pushNamedAndRemoveUntil(
                      verifyEmailRoute,
                      (route) => false,
                      arguments: _email.text.trim(),
                    );
                  } catch (e) {
                    showErrorDialog(
                      title: "Erro ao registrar usuário",
                      context,
                      message: e.toString(),
                    );
                  }
                },
                text: "Continuar",
                color: const Color(0xFF99C842),
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Já possui uma conta? "),
                TextButton(
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil(loginRoute, (route) => false);
                  },
                  child: const Text(
                    "Faça o login.",
                    style: TextStyle(
                      color: Color(0xFF689F38),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
