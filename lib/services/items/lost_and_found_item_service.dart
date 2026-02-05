import 'dart:io';
import 'package:find_uf/models/enums/item_category.dart';
import 'package:find_uf/models/enums/item_status.dart';
import 'package:find_uf/models/lost_and_find_item.dart';
import 'package:find_uf/services/items/items_exceptions.dart';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;

class LostAndFoundItemService {
  final _supabase = Supabase.instance.client;

  late final _items = _supabase.from('lost_and_found_items');
  late final _itemsImageStorage = _supabase.storage.from(
    'lost_and_found_items',
  );

  /// Faz upload das fotos para o Storage e retorna as URLs públicas
  Future<List<String>> _uploadItemPhotos({
    required String userId,
    required String itemId,
    required List<File> imageFiles,
  }) async {
    final List<String> publicURLs = [];
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    for (int index = 0; index < imageFiles.length; index++) {
      final file = imageFiles[index];
      final extension = path.extension(file.path).toLowerCase();

      // Nome do arquivo: userId/itemId/timestamp_index.ext
      final fileName = '$userId/$itemId/${timestamp}_$index$extension';

      try {
        await _itemsImageStorage.upload(
          fileName,
          file,
          fileOptions: const FileOptions(upsert: false),
        );

        final publicURL = _itemsImageStorage.getPublicUrl(fileName);
        publicURLs.add(publicURL);
      } catch (e) {
        debugPrint('Erro ao fazer upload da imagem: $e');
        throw UploadItemImageException();
      }
    }

    return publicURLs;
  }

  /// Remove fotos do Storage
  Future<void> _deletePhotosFromStorage(List<String> urls) async {
    for (final url in urls) {
      try {
        // Extrai o path do arquivo da URL pública
        final uri = Uri.parse(url);
        final filePath = uri.pathSegments.skip(5).join('/');
        await _itemsImageStorage.remove([filePath]);
      } catch (e) {
        debugPrint('Erro ao deletar foto: $e');
        throw DeleteLostAndFoundItemException();
      }
    }
  }

  /// Cria um novo item de perdidos e achados
  Future<void> createLostAndFoundItem({
    required String userId,
    required String titulo,
    required String descricao,
    required String localizacao,
    required ItemCategory categoria,
    required ItemStatus status,
    required DateTime lostOrFoundAt,
    required List<File> imageFiles,
  }) async {
    try {
      // 1. Cria o item com placeholder
      final response =
          await _items
              .insert({
                'titulo': titulo,
                'descricao': descricao,
                'localizacao': localizacao,
                'categoria': categoria.name,
                'status': status.name,
                'lost_or_found_at': lostOrFoundAt.toUtc().toIso8601String(),
                'user_id': userId,
                'fotos_urls': ['placeholder'],
              })
              .select()
              .single();

      final itemId = response['id'] as String;

      // 2. Faz upload das fotos
      final fotosUrls = await _uploadItemPhotos(
        userId: userId,
        itemId: itemId,
        imageFiles: imageFiles,
      );

      // 3. Atualiza com as URLs reais
      await _items
          .update({'fotos_urls': fotosUrls})
          .eq('id', itemId)
          .select()
          .single();
    } catch (e) {
      debugPrint('Erro ao criar item de perdidos e achados: $e');
      throw CreateLostAndFoundItemException();
    }
  }

  /// Busca um item por ID
  Future<LostAndFoundItem> getItemById(String itemId) async {
    try {
      final response = await _items.select().eq('id', itemId).single();
      return LostAndFoundItem.fromJson(response);
    } catch (e) {
      debugPrint('Erro ao buscar item: $e');
      throw GetLostAndFoundItemException();
    }
  }

  /// Lista todos os itens ativos (não resolvidos)
  Future<List<LostAndFoundItem>> getActiveItems() async {
    try {
      final response = await _items
          .select()
          .neq('status', ItemStatus.resolved.name)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => LostAndFoundItem.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Erro ao listar itens ativos: $e');
      throw GetLostAndFoundItemException();
    }
  }

  /// Lista itens do usuário
  Future<List<LostAndFoundItem>> getUserItems(String userId) async {
    try {
      final response = await _items
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => LostAndFoundItem.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Erro ao listar itens do usuário: $e');
      throw GetLostAndFoundItemException();
    }
  }

  /// Atualiza um item de perdidos e achados
  Future<void> updateItem({
    required String itemId,
    required String userId,
    String? titulo,
    String? descricao,
    String? localizacao,
    ItemCategory? categoria,
    ItemStatus? status,
    DateTime? lostOrFoundAt,
    List<File>? imageFiles, // Novas fotos a serem adicionadas
    List<String>? existingPhotosUrls, // URLs que devem permanecer
    List<String>? photosToDelete, // URLs que devem ser deletadas
  }) async {
    try {
      // Monta o mapa com apenas os campos que foram passados
      final Map<String, dynamic> updates = {};

      if (titulo != null) updates['titulo'] = titulo;
      if (descricao != null) updates['descricao'] = descricao;
      if (localizacao != null) updates['localizacao'] = localizacao;
      if (categoria != null) updates['categoria'] = categoria.name;
      if (status != null) updates['status'] = status.name;
      if (lostOrFoundAt != null) {
        updates['lost_or_found_at'] = lostOrFoundAt.toUtc().toIso8601String();
      }

      // Gerenciamento de fotos
      List<String> finalPhotosUrls = [];

      // 1. Mantém as fotos existentes que não foram marcadas para deletar
      if (existingPhotosUrls != null) {
        finalPhotosUrls.addAll(existingPhotosUrls);
      }

      // 2. Faz upload das novas fotos (se houver)
      if (imageFiles != null && imageFiles.isNotEmpty) {
        final newUrls = await _uploadItemPhotos(
          userId: userId,
          itemId: itemId,
          imageFiles: imageFiles,
        );
        finalPhotosUrls.addAll(newUrls);
      }

      // 3. Atualiza o campo fotos_urls se houve mudanças
      if (imageFiles != null ||
          existingPhotosUrls != null ||
          (photosToDelete != null && photosToDelete.isNotEmpty)) {
        updates['fotos_urls'] = finalPhotosUrls;
      }

      // Atualiza o item no banco
      if (updates.isNotEmpty) {
        await _items.update(updates).eq('id', itemId).select().single();
      }

      // 4. Deleta as fotos marcadas do Storage (após atualizar o banco)
      if (photosToDelete != null && photosToDelete.isNotEmpty) {
        await _deletePhotosFromStorage(photosToDelete);
      }
    } catch (e) {
      debugPrint('Erro ao atualizar item: $e');
      throw UpdateLostAndFoundItemException();
    }
  }

  /// Marca um item como resolvido
  Future<LostAndFoundItem> resolveItem(String itemId) async {
    try {
      final response =
          await _items
              .update({'status': ItemStatus.resolved.name})
              .eq('id', itemId)
              .select()
              .single();

      return LostAndFoundItem.fromJson(response);
    } catch (e) {
      debugPrint('Erro ao resolver item: $e');
      throw UpdateLostAndFoundItemException();
    }
  }

  /// Deleta um item e suas fotos
  Future<void> deleteItem(String itemId) async {
    try {
      // 1. Busca o item
      final item = await getItemById(itemId);

      // 2. Deleta o item
      await _items.delete().eq('id', itemId);

      // 3. Remove fotos do Storage
      await _deletePhotosFromStorage(item.fotosUrls);
    } catch (e) {
      debugPrint('Erro ao deletar item: $e');
      throw DeleteLostAndFoundItemException();
    }
  }
}
