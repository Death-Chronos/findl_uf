import 'package:find_uf/models/enums/item_category.dart';
import 'package:find_uf/models/enums/item_status.dart';

class LostAndFoundItem {
  final String id;
  final String titulo;
  final String descricao;
  final String localizacao;
  final ItemStatus status;
  final ItemCategory categoria;
  final DateTime createdAt;
  final DateTime lostOrFoundAt;
  final List<String> fotosUrls;

  final String userId;

  LostAndFoundItem(
    this.createdAt, {
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.status,
    required this.localizacao,
    required this.categoria,
    required this.lostOrFoundAt,
    required this.fotosUrls,
    required this.userId,
  });

  factory LostAndFoundItem.fromJson(Map<String, dynamic> json) {
    return LostAndFoundItem(
      DateTime.parse(json['created_at']),
      id: json['id'],
      titulo : json['titulo'],
      descricao : json['descricao'],
      localizacao : json['localizacao'],
      status : ItemStatus.values.byName(json['status']),
      categoria : ItemCategory.values.byName(json['categoria']),
      lostOrFoundAt : DateTime.parse(json['lost_or_found_at']),
      fotosUrls : List<String>.from(json['fotos_urls']),
      userId : json['user_id'], 
    );
  }
}
