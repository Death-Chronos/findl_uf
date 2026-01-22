import 'package:find_uf/services/auth/auth_service.dart';
import 'package:find_uf/tools/dialogs.dart';
import 'package:find_uf/views/widgets/tap_button.dart';
import 'package:flutter/material.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final TextEditingController _senhaAtual = TextEditingController();
  final TextEditingController _novaSenha = TextEditingController();
  final TextEditingController _confirmarSenha = TextEditingController();

  bool _esconderSenhaAtual = true;
  bool _esconderNovaSenha = true;
  bool _esconderConfirmacao = true;

  /// Função para atualização de senha do usuário logado.
  ///
  /// Valida os campos, chama a função RPC do Supabase para verificar
  /// a senha atual e atualizar para a nova senha.
  Future<void> _trocarSenha(BuildContext context) async {
    try {
      // Validações básicas
      if (_senhaAtual.text.isEmpty) {
        showErrorDialog(
          context,
          title: "Senha atual obrigatória",
          message: "Por favor, informe sua senha atual",
        );
        return;
      }

      if (_novaSenha.text.isEmpty || _novaSenha.text.length < 6) {
        showErrorDialog(
          context,
          title: "Senha inválida",
          message: "A nova senha deve ter no mínimo 6 caracteres",
        );
        return;
      }

      if (_novaSenha.text != _confirmarSenha.text) {
        showErrorDialog(
          context,
          title: "Erro ao trocar senha",
          message: "As senhas não conferem",
        );
        return;
      }

      if (_senhaAtual.text == _novaSenha.text) {
        showErrorDialog(
          context,
          title: "Senha inválida",
          message: "A nova senha deve ser diferente da senha atual",
        );
        return;
      }

      // Chama a função RPC para atualizar a senha
      final response = await AuthService.supabase().updatePasswordWithCurrent(
        currentPassword: _senhaAtual.text,
        newPassword: _novaSenha.text,
      );

      // Verifica o resultado da função
      if (response == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Senha atualizada com sucesso!')),
        );
        Navigator.of(context).pop();
      } else if (response == 'incorrect') {
        showErrorDialog(
          context,
          title: "Senha incorreta",
          message: "A senha atual informada está incorreta",
        );
      } else if (response == 'unauthorized') {
        showErrorDialog(
          context,
          title: "Não autorizado",
          message: "Você precisa estar logado para trocar a senha",
        );
      } else {
        showErrorDialog(
          context,
          title: "Erro desconhecido",
          message: "Ocorreu um erro ao trocar a senha. Tente novamente.",
        );
      }
    } catch (e) {
      showErrorDialog(
        context,
        title: "Erro ao trocar senha",
        message: e.toString(),
      );
    }
  }

  @override
  void dispose() {
    _senhaAtual.dispose();
    _novaSenha.dispose();
    _confirmarSenha.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Trocar Senha",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: const Color(0xFF173C7B),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho
              const Text(
                "Altere sua senha",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Para sua segurança, informe sua senha atual e "
                "depois crie uma nova senha.",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 36),

              // Senha atual
              TextField(
                controller: _senhaAtual,
                obscureText: _esconderSenhaAtual,
                decoration: InputDecoration(
                  labelText: "Senha atual",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _esconderSenhaAtual
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() => _esconderSenhaAtual = !_esconderSenhaAtual);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Nova senha
              TextField(
                controller: _novaSenha,
                obscureText: _esconderNovaSenha,
                decoration: InputDecoration(
                  labelText: "Nova senha",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _esconderNovaSenha
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() => _esconderNovaSenha = !_esconderNovaSenha);
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
                  text: "Confirmar Alteração",
                  onTap: () async {
                    await _trocarSenha(context);
                  },
                  color: const Color(0xFF173C7B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}