import 'dart:io';

import 'package:find_uf/constants/route.dart';
import 'package:find_uf/services/auth/auth_service.dart';
import 'package:find_uf/tools/validar_email.dart';
import 'package:find_uf/views/widgets/tap_button.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class RegistroView extends StatefulWidget {
  const RegistroView({super.key});

  @override
  _RegistroViewState createState() => _RegistroViewState();
}

class _RegistroViewState extends State<RegistroView> {
  late final TextEditingController _nome;
  late final TextEditingController _telefone;
  late final TextEditingController _email;
  late final TextEditingController _senha;

  bool _esconderSenha = true;

  File? imagemSelecionada;
  final ImagePicker tiraFoto = ImagePicker();

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
      appBar: AppBar(
        title: const Text("Registro"),
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
            TextFormField(
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
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TapButton(
                  onTap: () async {
                    final email = _email.text;
                    final senha = _senha.text;
                    try {
                      final erro = ValidarEmail.validar(_email.text);

                    if (erro != null) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(erro)));
                      return;
                    }

                    // Email válido, enviar
                      await AuthService.supabase().registrarUser(
                        email: email,
                        senha: senha,
                      );
                      Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil(loginRoute, (route) => false);
                    } catch (e) {
                      print("Erro ao fazer registro: " + e.toString());
                    }
                  },
                  text: "Registrar",
                  color:  Color(0xFF99C842),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Já possui uma conta? "),
                TextButton(
                  onPressed: () {
                    try {
                      Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil(loginRoute, (route) => false);
                    } catch (e) {}
                  },
                  child: Text("Faça o login."),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
