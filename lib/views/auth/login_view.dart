import 'package:findl_uf/constants/routes.dart';
import 'package:findl_uf/models/my_auth_user.dart';
import 'package:findl_uf/services/auth/auth_exceptions.dart';
import 'package:findl_uf/services/auth/auth_service.dart';
import 'package:findl_uf/services/profile_service.dart';
import 'package:findl_uf/tools/dialogs.dart';
import 'package:findl_uf/tools/validacoes.dart';
import 'package:findl_uf/views/components/tap_button.dart';
import 'package:flutter/material.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Entrar"),
        centerTitle: true,
        backgroundColor: const Color(0xFF173C7B),
      ),
      backgroundColor: const Color(0xFFE3F2FD),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Center(
              child: Icon(
                Icons.login,
                size: 80,
                color: Color(0xFF173C7B),
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                "Bem-vindo de volta!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173C7B),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                "Entre com sua conta institucional",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _email,
              decoration: const InputDecoration(
                labelText: "Email Institucional",
                prefixIcon: Icon(Icons.email, color: Color(0xFF173C7B)),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _senha,
              autocorrect: false,
              obscureText: _esconderSenha,
              enableSuggestions: false,
              decoration: InputDecoration(
                labelText: "Senha",
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock, color: Color(0xFF173C7B)),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _esconderSenha = !_esconderSenha;
                    });
                  },
                  icon: Icon(
                    _esconderSenha ? Icons.visibility : Icons.visibility_off,
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Esqueceu a sua senha?"),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(forgotPasswordRoute);
                  },
                  child: const Text(
                    "Clique aqui",
                    style: TextStyle(color: Color(0xFF173C7B)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: TapButton(
                  onTap: () async {
                    final email = _email.text;
                    final password = _senha.text;

                    final erro = Validacoes.validarEmail(_email.text);

                    if (erro != null) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(erro)));
                      return;
                    }

                    try {
                      final MyAuthUser user = await AuthService.supabase()
                          .login(email: email, password: password);

                      debugPrint('user logged in: ${user.id}');

                      final userExist = await ProfileService().profileExists(
                        user.id,
                      );
                      debugPrint('user profile exists: $userExist');
                      if (userExist == false) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          completeProfileRoute,
                          (route) => false,
                        );
                      } else {
                        Navigator.of(
                          context,
                        ).pushNamedAndRemoveUntil(homeRoute, (route) => false);
                      }
                    } on EmailNotConfirmedAuthException {
                      Navigator.of(
                        context,
                      ).pushNamed(verifyEmailRoute, arguments: email);
                    } catch (e) {
                      showErrorDialog(
                        context,
                        title: "Erro ao realizar login",
                        message: e.toString(),
                      );
                    }
                  },
                  text: "Entrar",
                  color: const Color(0xFF173C7B),
                ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Não possui uma conta? "),
                TextButton(
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil(registerRoute, (route) => false);
                  },
                  child: const Text(
                    "Faça o registro.",
                    style: TextStyle(
                      color: Color(0xFF173C7B),
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
