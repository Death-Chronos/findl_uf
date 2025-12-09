import 'package:find_uf/constants/route.dart';
import 'package:find_uf/services/auth/auth_service.dart';
import 'package:find_uf/tools/dialogs.dart';
import 'package:find_uf/tools/validacoes.dart';
import 'package:find_uf/views/widgets/tap_button.dart';
import 'package:flutter/material.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _senha;
  bool _esconderSenha = true;

  @override
  void initState() {
    _email = TextEditingController();
    _senha = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
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

    if (_senha.text.length < 6) {
      _mostrarErro("A senha deve ter pelo menos 6 caracteres.");
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Criar conta", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF173C7B),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Crie sua conta para acessar o aplicativo.",
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email",
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _senha,
              autocorrect: false,
              obscureText: _esconderSenha,
              decoration: InputDecoration(
                labelText: "Senha",
                border: const OutlineInputBorder(),
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
                      senha: _senha.text,
                    );

                    Navigator.of(context).pushNamedAndRemoveUntil(
                      verificarEmailRoute,
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
                  child: const Text("Faça o login."),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
