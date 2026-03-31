class ItemContacts {
  final String id;
  final String itemId;
  final String initiatorId;
  final String receiverId;
  final DateTime createdAt;

  const ItemContacts({
    required this.id,
    required this.itemId,
    required this.initiatorId,
    required this.receiverId,
    required this.createdAt,
  });

  factory ItemContacts.fromJson(Map<String, dynamic> json) {
    return ItemContacts(
      id: json['id'],
      itemId: json['item_id'],
      initiatorId: json['initiator_id'],
      receiverId: json['receiver_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
