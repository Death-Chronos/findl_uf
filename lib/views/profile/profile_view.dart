import 'package:find_uf/constants/routes.dart';
import 'package:find_uf/models/profile.dart';
import 'package:find_uf/services/auth/auth_service.dart';
import 'package:find_uf/services/profile_service.dart';
import 'package:find_uf/tools/dialogs.dart';
import 'package:find_uf/tools/formatacoes.dart';
import 'package:flutter/material.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late Future<Profile> _profileFuture;

  @override
  void initState() {
    super.initState();
    final userId = AuthService.supabase().getUser!.id;
    debugPrint('Fetching profile for userId: $userId');
    _profileFuture = ProfileService().getProfile(userId);
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.supabase().getUser!;

    return FutureBuilder<Profile>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  "Erro ao carregar perfil",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final profile = snapshot.data as Profile;

        return Column(
          children: [
            // Seção fixa do topo com foto e informações
            Container(
              padding: const EdgeInsets.all(24),
              color: Colors.white,
              child: Row(
                children: [
                  // Foto circular
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(profile.fotoUrl),
                  ),
                  const SizedBox(width: 16),
                  // Informações do usuário
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.nome.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formatarTelefone(profile.telefone),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Lista de operações
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildMenuItem(
                    icon: Icons.person_outline,
                    title: 'Atualizar perfil',
                    onTap: () {
                      // TODO: Navegar para tela de atualizar perfil
                      debugPrint('Atualizar perfil');
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.lock_outline,
                    title: 'Mudar senha',
                    onTap: () {
                      Navigator.of(context).pushNamed(changePasswordRoute);
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.logout,
                    title: 'Sair',
                    onTap: () {
                      try {
                        AuthService.supabase().logout();
                        Navigator.of(
                          context,
                        ).pushNamedAndRemoveUntil(loginRoute, (route) => false);
                      } catch (e) {
                        showErrorDialog(
                          context,
                          title: "Erro ao fazer logout",
                          message: e.toString(),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 24, color: const Color(0xFF173C7B)),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

}
