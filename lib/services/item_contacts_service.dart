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
}
