import 'package:find_uf/models/chat_preview.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ItemContactsService {
  final _contacts = Supabase.instance.client.from('item_contacts');

  Future<void> registerContact({
    required String itemId,
    required String initiatorId,
    required String receiverId,
  }) async {
    await _contacts.upsert(
      {
        'item_id': itemId,
        'initiator_id': initiatorId,
        'receiver_id': receiverId,
      },
      onConflict: 'item_id, initiator_id',
    );
  }

  Future<List<ChatPreview>> getUserChats(String userId) async {
    final response = await _contacts
        .select(
          '''
          item_id,
          initiator_id,
          receiver_id,
          created_at,
          lost_and_found_items!inner(titulo),
          initiator:profile!initiator_id(nome, foto_url),
          receiver:profile!receiver_id(nome, foto_url)
        ''',
        )
        .or('initiator_id.eq.$userId,receiver_id.eq.$userId')
        .order('created_at', ascending: false);

    return response.map<ChatPreview>((json) {
      final isInitiator = json['initiator_id'] == userId;
      final contactProfile = isInitiator ? json['receiver'] : json['initiator'];
      final contactId = isInitiator ? json['receiver_id'] : json['initiator_id'];

      return ChatPreview(
        contactId: contactId,
        itemId: json['item_id'],
        itemTitle: json['lost_and_found_items']['titulo'],
        contactName: contactProfile['nome'],
        contactPhotoUrl: contactProfile['foto_url'] ?? '',
        lastContactAt: DateTime.parse(json['created_at']),
      );
    }).toList();
  }
}
