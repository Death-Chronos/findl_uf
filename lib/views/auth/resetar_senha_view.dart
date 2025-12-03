import 'package:find_uf/constants/route.dart';
import 'package:find_uf/services/auth/auth_service.dart';
import 'package:find_uf/tools/dialogs.dart';
import 'package:find_uf/tools/validar_email.dart';
import 'package:find_uf/views/widgets/tap_button.dart';
import 'package:flutter/material.dart';

class ResetarSenhaView extends StatefulWidget {
  const ResetarSenhaView({super.key});

  @override
  _ResetarSenhaViewState createState() => _ResetarSenhaViewState();
}

class _ResetarSenhaViewState extends State<ResetarSenhaView> {
  late final TextEditingController _email;

  Future<void> _resetarSenha(BuildContext context) async {
    final erro = ValidarEmail.validar(_email.text);

    if (erro != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erro)));
      return;
    }

    try {
      await AuthService.supabase().sendPasswordRecoverToken(email: _email.text);
      Navigator.of(context).pushNamedAndRemoveUntil(
        atualizarSenhaRoute,
        (route) => false,
        arguments: _email.text.toString(),
      );
    } catch (e) {
      showErrorDialog(
        context,
        title: "Erro ao resetar senha",
        message: e.toString(),
      );
    }
  }

  @override
  void initState() {
    _email = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Resetar Senha"),
        centerTitle: true,
        backgroundColor: const Color(0xFF173C7B),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.password, size: 60, color: Color(0xFF464242)),
                Text(
                  "Insira seu email abaixo para receber o código",
                  style: TextStyle(fontSize: 16),
                ),
                TextField(
                  controller: _email,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TapButton(
                  onTap: () {
                    _resetarSenha(context);
                  },
                  text: "Enviar Email",
                  color: const Color(0xFF99C842),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
