import 'package:find_uf/constants/route.dart';
import 'package:find_uf/models/my_auth_user.dart';
import 'package:find_uf/services/auth/auth_exceptions.dart';
import 'package:find_uf/services/auth/auth_service.dart';
import 'package:find_uf/services/profile_service.dart';
import 'package:find_uf/tools/dialogs.dart';
import 'package:find_uf/tools/validar_email.dart';
import 'package:find_uf/views/widgets/tap_button.dart';
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
        title: const Text("Login"),
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
              "Realize o login para acessar o aplicativo, ou entre como visitante.",
              style: TextStyle(fontSize: 14),
            ),
            TextField(
              controller: _email,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _senha,
              autocorrect: false,
              obscureText: _esconderSenha,
              enableSuggestions: false,
              decoration: InputDecoration(
                labelText: "Senha",
                border: OutlineInputBorder(),
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
                Text("Esqueceu a sua senha?"),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      resetarSenhaRoute,
                      (route) => false,
                    );
                  },
                  child: Text("Clique aqui"),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TapButton(
                  onTap: () async {
                    final email = _email.text;
                    final senha = _senha.text;

                    final erro = ValidarEmail.validar(_email.text);

                    if (erro != null) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(erro)));
                      return;
                    }

                    try {
                      final MyAuthUser user = await AuthService.supabase()
                          .login(email: email, senha: senha);

                      print('user logged in: ${user.id}');

                      final userExist = await ProfileService().profileExists(
                        user.id,
                      );
                      print('user profile exists: $userExist');
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
                      ).pushNamed(verificarEmailRoute, arguments: email);
                    } catch (e) {
                      showErrorDialog(
                        context,
                        title: "Erro ao realizar login",
                        message: e.toString(),
                      );
                    }
                  },
                  text: "Login",
                  color: Color(0xFF99C842),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Não possui uma conta? "),
                TextButton(
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil(registroRoute, (route) => false);
                  },
                  child: Text("Faça o registro."),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
