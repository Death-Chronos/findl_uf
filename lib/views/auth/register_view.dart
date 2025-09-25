import 'package:find_uf/views/widgets/tap_button.dart';
import 'package:flutter/material.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _nome;
  late final TextEditingController _telefone;
  late final TextEditingController _email;
  late final TextEditingController _senha;

  @override
  void initState() {
    _nome = TextEditingController();
    _telefone = TextEditingController();
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
              controller: _nome,
              decoration: InputDecoration(
                labelText: "Nome",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _telefone,
              keyboardType: TextInputType.phone,
              
              decoration: InputDecoration(
                labelText: "Número de telefone",
                hintText: "(99) 99999-9999",
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _email,
              decoration: InputDecoration(
                labelText: "Email",
                prefixIcon: Icon(Icons.email),
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
                  text: "Registrar",
                  color: Color.fromARGB(255, 23, 60, 123),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Já possui uma conta? "),
                TextButton(onPressed: () {}, child: Text("Faça o login.")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
