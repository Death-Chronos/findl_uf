import 'dart:io';

import 'package:find_uf/constants/route.dart';
import 'package:find_uf/services/auth/auth_service.dart';
import 'package:find_uf/services/profile_service.dart';
import 'package:find_uf/tools/dialogs.dart';
import 'package:find_uf/views/widgets/app_image_picker.dart';
import 'package:find_uf/views/widgets/tap_button.dart';
import 'package:flutter/material.dart';

class CompleteProfileView extends StatefulWidget {
  const CompleteProfileView({super.key});

  @override
  _CompleteProfileViewState createState() => _CompleteProfileViewState();
}

class _CompleteProfileViewState extends State<CompleteProfileView> {
  late final TextEditingController _nome;
  late final TextEditingController _telefone;
  File? imagemSelecionada;

  @override
  void initState() {
    _nome = TextEditingController();
    _telefone = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _nome.dispose();
    _telefone.dispose();
    super.dispose();
  }

  void _mostrarErro(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  bool _validarCampos() {
    if (_nome.text.isEmpty) {
      _mostrarErro("Por favor, informe seu nome.");
      return false;
    }

    if (_telefone.text.isEmpty || _telefone.text.length < 11) {
      _mostrarErro("Informe um telefone válido.");
      return false;
    }

    if (imagemSelecionada == null) {
      _mostrarErro("Selecione uma foto de perfil.");
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Complete seu perfil",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF173C7B),
        automaticallyImplyLeading: false, // Remove botão voltar
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Precisamos de mais algumas informações para concluir seu cadastro.",
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),

            // Foto de perfil
            Center(
              child: AppImagePicker(
                onImageSelected: (file) {
                  setState(() {
                    imagemSelecionada = file;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _nome,
              decoration: const InputDecoration(
                labelText: "Nome completo",
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _telefone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Número de telefone",
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            Center(
              child: TapButton(
                onTap: () async {
                  if (!_validarCampos()) return;

                  try {
                    final user = AuthService.supabase().getUser;
                    if (user == null) {
                      _mostrarErro("Usuário não autenticado");
                      return;
                    }
                    String textoStatus = "...";

                    // Cria perfil com foto
                    setState(() {
                      textoStatus = "Fazendo upload da foto de perfil...";
                    });
                    showLoadingDialog(context: context, message: textoStatus);
                    final fotoUrl = await ProfileService().uploadProfilePhoto(
                      userId: user.id,
                      imageFile: imagemSelecionada!,
                    );

                    // criando perfil
                    setState(() {
                      textoStatus = "Criando perfil...";
                    });
                    await ProfileService().createProfileWithPhotoURL(
                      userId: user.id,
                      nome: _nome.text,
                      telefone: _telefone.text,
                      fotoUrl: fotoUrl,
                    );

                    // Navega para Home
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil(homeRoute, (route) => false);
                  } catch (e) {
                    _mostrarErro("Erro ao completar perfil: $e");
                    print("Erro ao completar perfil: $e");
                  }
                },
                text: "Finalizar cadastro",
                color: const Color(0xFF99C842),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
