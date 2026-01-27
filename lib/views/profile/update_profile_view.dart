import 'dart:io';
import 'package:find_uf/services/auth/auth_service.dart';
import 'package:find_uf/services/profile_service.dart';
import 'package:find_uf/tools/dialogs.dart';
import 'package:find_uf/views/widgets/app_image_picker.dart';
import 'package:find_uf/views/widgets/tap_button.dart';
import 'package:flutter/material.dart';

class UpdateProfileView extends StatefulWidget {
  const UpdateProfileView({super.key});

  @override
  State<UpdateProfileView> createState() => _UpdateProfileViewState();
}

class _UpdateProfileViewState extends State<UpdateProfileView> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  File? _selectedImage;
  String? _currentPhotoUrl;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

  Future<void> _loadCurrentData() async {
    try {
      final userId = AuthService.supabase().getUser!.id;
      final profile = await ProfileService().getProfile(userId);

      setState(() {
        _nameController.text = profile.nome;
        _phoneController.text = profile.telefone;
        _currentPhotoUrl = profile.fotoUrl;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        showErrorDialog(
          context,
          title: "Erro ao carregar perfil",
          message: e.toString(),
        );
      }
    }
  }

  Future<void> _updateProfile() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty) {
      showErrorDialog(
        context,
        title: "Nome obrigatório",
        message: "Por favor, informe seu nome",
      );
      return;
    }

    if (phone.isEmpty) {
      showErrorDialog(
        context,
        title: "Telefone obrigatório",
        message: "Por favor, informe seu telefone",
      );
      return;
    }

    final currentProfile = await ProfileService().getProfile(
      AuthService.supabase().getUser!.id,
    );

    final bool nameChanged = name != currentProfile.nome;
    final bool phoneChanged = phone != currentProfile.telefone;
    final bool photoChanged = _selectedImage != null;

    if (!nameChanged && !phoneChanged && !photoChanged) {
      showErrorDialog(
        context,
        title: "Nenhuma alteração",
        message: "Você não alterou nenhum dado",
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final userId = AuthService.supabase().getUser!.id;

      await ProfileService().updateProfileWithPhoto(
        userId: userId,
        nome: nameChanged ? name : null,
        telefone: phoneChanged ? phone : null,
        novaFoto: _selectedImage,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso!')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        showErrorDialog(
          context,
          title: "Erro ao atualizar perfil",
          message: e.toString(),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Atualizar Perfil",
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: const Color(0xFF173C7B),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AppImagePicker(
                      initialImageUrl: _currentPhotoUrl,
                      onImageSelected: (image) {
                        setState(() {
                          _selectedImage = image;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Toque na foto para alterar",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 32),

                    TextField(
                      controller: _nameController,
                      enabled: !_isSaving,
                      decoration: InputDecoration(
                        labelText: "Nome completo",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 20),

                    TextField(
                      controller: _phoneController,
                      enabled: !_isSaving,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: "Telefone",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.phone_outlined),
                      ),
                    ),
                    const SizedBox(height: 40),

                    _isSaving
                        ? const CircularProgressIndicator()
                        : TapButton(
                            text: "Salvar Alterações",
                            onTap: _updateProfile,
                            color: const Color(0xFF173C7B),
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}
