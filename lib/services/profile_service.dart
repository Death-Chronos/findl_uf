import 'dart:io';
import 'package:find_uf/models/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final _profiles = Supabase.instance.client.from('perfil');
  final _photoStorage = Supabase.instance.client.storage.from('foto_perfil');

  /// 1. Criar perfil inicial (sem foto)
  Future<void> createProfile({
    required String userId,
    required String nome,
    required String telefone,
  }) async {
    try {
      await _profiles.insert({
        'id': userId,
        'nome': nome,
        'telefone': telefone,
      });
    } catch (e) {
      throw Exception('Erro ao criar perfil: $e');
    }
  }

  /// 2. Upload de foto para Storage
  Future<String> uploadProfilePhoto({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final String nomeArquivo = '$userId.jpg';

      await _photoStorage.upload(
        nomeArquivo,
        imageFile,
        fileOptions: const FileOptions(upsert: true),
      );

      final String publicUrl = _photoStorage.getPublicUrl(nomeArquivo);

      return publicUrl;
    } catch (e) {
      throw Exception('Erro ao fazer upload da foto: $e');
    }
  }

  /// 3. Atualizar foto_url no perfil
  Future<void> updatePhotoUrl({
    required String userId,
    required String fotoUrl,
  }) async {
    try {
      await _profiles.update({'foto_url': fotoUrl}).eq('id', userId);
    } catch (e) {
      throw Exception('Erro ao atualizar URL da foto: $e');
    }
  }

  /// 4. Atualizar dados do perfil (nome, telefone)
  Future<void> updateProfile({
    required String userId,
    String? nome,
    String? telefone,
  }) async {
    try {
      final Map<String, dynamic> updates = {};
      if (nome != null) updates['nome'] = nome;
      if (telefone != null) updates['telefone'] = telefone;

      if (updates.isEmpty) return;

      await _profiles.update(updates).eq('id', userId);
    } catch (e) {
      throw Exception('Erro ao atualizar perfil: $e');
    }
  }

  /// Atualizar perfil de forma dinâmica (nome, telefone e/ou foto)
  Future<void> updateProfileWithPhoto({
    required String userId,
    String? nome,
    String? telefone,
    File? novaFoto,
  }) async {
    try {
      final Map<String, dynamic> updates = {};

      if (nome != null) updates['nome'] = nome;
      if (telefone != null) updates['telefone'] = telefone;

      // Se houver nova foto, fazer upload e adicionar URL
      if (novaFoto != null) {
        final String fotoUrl = await uploadProfilePhoto(
          userId: userId,
          imageFile: novaFoto,
        );
        updates['foto_url'] = fotoUrl;
      }

      // Se não há nada para atualizar, lança exceção
      if (updates.isEmpty) {
        throw Exception('Nenhum dado fornecido para atualização');
      }

      // Atualizar no banco
      await _profiles.update(updates).eq('id', userId);
    } catch (e) {
      throw Exception('Erro ao atualizar perfil: $e');
    }
  }

  /// 6. Buscar perfil completo
  Future<Profile> getProfile(String userId) async {
    try {
      final response = await _profiles.select().eq('id', userId).single();

      return Profile.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao buscar perfil: $e');
    }
  }

  /// 7. Deletar foto do Storage
  Future<void> deleteProfilePhoto(String userId) async {
    try {
      await _photoStorage.remove(['$userId.jpg']);
    } catch (e) {
      throw Exception('Erro ao deletar foto: $e');
    }
  }

  /// 8. Criar perfil completo (com foto) - Combo para registro
  Future<void> createProfileWithPhoto({
    required String userId,
    required String nome,
    required String telefone,
    required File imageFile,
  }) async {
    try {
      // 1. Upload da foto
      final String fotoUrl = await uploadProfilePhoto(
        userId: userId,
        imageFile: imageFile,
      );

      // 2. Criar perfil com a URL da foto
      await createProfileWithPhotoURL(
        userId: userId,
        nome: nome,
        telefone: telefone,
        fotoUrl: fotoUrl,
      );
    } catch (e) {
      throw Exception('Erro ao criar perfil com foto: $e');
    }
  }

  /// 9. Criar perfil completo (com foto) - Usando URL da foto
  Future<void> createProfileWithPhotoURL({
    required String userId,
    required String nome,
    required String telefone,
    required String fotoUrl,
  }) async {
    try {
      await _profiles.insert({
        'id': userId,
        'nome': nome,
        'telefone': telefone,
        'foto_url': fotoUrl,
      });
    } catch (e) {
      throw Exception('Erro ao criar perfil com foto: $e');
    }
  }

  /// 10. Atualizar foto do perfil (deleta antiga e faz upload da nova)
  Future<void> updateProfilePhoto({
    required String userId,
    required File newImageFile,
  }) async {
    try {
      // 1. Upload da nova foto (upsert já sobrescreve a antiga)
      final String novaFotoUrl = await uploadProfilePhoto(
        userId: userId,
        imageFile: newImageFile,
      );

      // 2. Atualizar URL no banco
      await updatePhotoUrl(userId: userId, fotoUrl: novaFotoUrl);
    } catch (e) {
      throw Exception('Erro ao atualizar foto do perfil: $e');
    }
  }

  /// 11. Verificar se perfil existe
  Future<bool> profileExists(String userId) async {
    try {
      final response =
          await _profiles.select('id').eq('id', userId).maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }
}
