class ChatPreview {
  final String contactId;
  final String itemId;
  final String itemTitle;
  final String contactName;
  final String contactPhotoUrl;
  final DateTime lastContactAt;

  const ChatPreview({
    required this.contactId,
    required this.itemId,
    required this.itemTitle,
    required this.contactName,
    required this.contactPhotoUrl,
    required this.lastContactAt,
  });
}
