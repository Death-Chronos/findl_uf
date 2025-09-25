import 'package:find_uf/views/widgets/tap_button.dart';
import 'package:flutter/material.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _senha;

  @override
  void initState() {
    _email = TextEditingController();
    _senha = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Crie sua conta para acessar o aplicativo, ou entre como visitante.",
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
              obscureText: true,
              enableSuggestions: false,
              decoration: InputDecoration(
                labelText: "Senha",
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.visibility),
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TapButton(
                  onTap: () {},
                  text: "Login",
                  color: Color.fromARGB(255, 23, 60, 123),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Não possui uma conta? "),
                TextButton(onPressed: () {}, child: Text("Faça o registro.")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
