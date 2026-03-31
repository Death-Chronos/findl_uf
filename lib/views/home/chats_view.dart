import 'package:findl_uf/constants/routes.dart';
import 'package:findl_uf/models/chat_preview.dart';
import 'package:findl_uf/services/auth/auth_exceptions.dart';
import 'package:findl_uf/services/auth/auth_service.dart';
import 'package:findl_uf/services/item_contacts_service.dart';
import 'package:findl_uf/services/items/lost_and_found_item_service.dart';
import 'package:findl_uf/services/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatsView extends StatefulWidget {
  const ChatsView({super.key});

  @override
  State<ChatsView> createState() => _ChatsViewState();
}

class _ChatsViewState extends State<ChatsView> {
  final ItemContactsService _contactsService = ItemContactsService();
  final ProfileService _profileService = ProfileService();
  List<ChatPreview> _chats = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    try {
      final user = await AuthService.supabase().getUser;
      if (user == null) throw UserNotFoundAuthException();

      final chats = await _contactsService.getUserChats(user.id);
      setState(() {
        _chats = chats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar conversas';
        _isLoading = false;
      });
    }
  }

  Future<void> _openWhatsApp(String contactId, String itemTitle) async {
    try {
      final profile = await _profileService.getProfile(contactId);
      final phone = profile.telefone.replaceAll(RegExp(r'[^\d]'), '');

      final whatsappUrl = Uri.parse('whatsapp://send?phone=55$phone');

      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Não foi possível abrir o WhatsApp')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    }
  }

  void _showChatOptions(ChatPreview chat) {
    final rootContext = context;

    showModalBottomSheet(
      context: context,
      builder:
          (bottomSheetContext) => SafeArea(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('Ver detalhes do item'),
                    onTap: () async {
                      Navigator.pop(bottomSheetContext);
                      final item = await LostAndFoundItemService().getItemById(
                        chat.itemId,
                      );
                      if (mounted) {
                        Navigator.of(
                          rootContext,
                        ).pushNamed(itemDetailsRoute, arguments: item);
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.chat, color: Color(0xFF25D366)),
                    title: const Text('Abrir WhatsApp'),
                    onTap: () {
                      Navigator.pop(context);
                      _openWhatsApp(chat.contactId, chat.itemTitle);
                    },
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _loadChats();
              },
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_chats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Nenhuma conversa ainda',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Entre em contato com alguém sobre um item',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadChats,
      child: ListView.builder(
        itemCount: _chats.length,
        itemBuilder: (context, index) {
          final chat = _chats[index];
          return ListTile(
            leading: CircleAvatar(
              radius: 28,
              backgroundImage:
                  chat.contactPhotoUrl.isNotEmpty
                      ? NetworkImage(chat.contactPhotoUrl)
                      : null,
              child:
                  chat.contactPhotoUrl.isEmpty
                      ? const Icon(Icons.person, size: 28)
                      : null,
            ),
            title: Text(
              chat.contactName,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            subtitle: Text(
              chat.itemTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            trailing: Text(
              _formatDate(chat.lastContactAt),
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            onTap: () => _showChatOptions(chat),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Ontem';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
