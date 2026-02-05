import 'package:find_uf/constants/routes.dart';
import 'package:find_uf/models/lost_and_find_item.dart';
import 'package:find_uf/services/auth/auth_service.dart';
import 'package:find_uf/services/items/lost_and_found_item_service.dart';
import 'package:find_uf/tools/dialogs.dart';
import 'package:find_uf/views/components/tap_button.dart';
import 'package:find_uf/views/items/components/photo_gallery.dart';
import 'package:flutter/material.dart';
import 'package:find_uf/models/profile.dart';
import 'package:find_uf/models/enums/item_status.dart';
import 'package:find_uf/services/profile_service.dart';
import 'package:find_uf/helpers/category_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class ItemDetailsView extends StatefulWidget {
  final LostAndFoundItem item;

  const ItemDetailsView({super.key, required this.item});

  @override
  State<ItemDetailsView> createState() => _ItemDetailsViewState();
}

class _ItemDetailsViewState extends State<ItemDetailsView> {
  final ProfileService _profileService = ProfileService();
  Profile? _userProfile;
  bool _isLoading = true;
  String? _error;
  late bool _isOwner;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final currentUser = await AuthService.supabase().getUser; // Adicione aqui
      _isOwner = currentUser != null && currentUser.id == widget.item.userId;

      final profile = await _profileService.getProfile(widget.item.userId);
      setState(() {
        _userProfile = profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar perfil do usuário';
        _isLoading = false;
      });
    }
  }

  Future<void> _openWhatsApp() async {
    if (_userProfile == null) return;

    final String phone = _userProfile!.telefone.replaceAll(
      RegExp(r'[^\d]'),
      '',
    );
    final String statusText =
        widget.item.status == ItemStatus.lost ? 'perdeu' : 'achou';
    final String message = Uri.encodeComponent(
      'Olá! Vi que você $statusText: isso: ${widget.item.titulo}. Gostaria de mais informações.',
    );

    final Uri whatsappUrl = Uri.parse('https://wa.me/55$phone?text=$message');

    try {
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
        ).showSnackBar(SnackBar(content: Text('Erro ao abrir WhatsApp: $e')));
      }
    }
  }

  String _getStatusText() {
    return widget.item.status == ItemStatus.lost ? 'Perdeu' : 'Achou';
  }

  String _getItemStatusText() {
    return widget.item.status == ItemStatus.lost ? 'Perdido' : 'Achado';
  }

  Color _getStatusColor() {
    return widget.item.status == ItemStatus.lost
        ? Colors.red.shade700
        : Colors.green.shade700;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do Item'), centerTitle: true),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(_error!),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadUserProfile,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              )
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Galeria de fotos
                    PhotoGalleryViewer(photos: widget.item.fotosUrls),

                    // Informações do usuário
                    if (_userProfile != null)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundImage:
                                  _userProfile!.fotoUrl.isNotEmpty
                                      ? NetworkImage(_userProfile!.fotoUrl)
                                      : null,
                              child:
                                  _userProfile!.fotoUrl.isEmpty
                                      ? const Icon(Icons.person, size: 28)
                                      : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _userProfile!.nome,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${_getStatusText()} este item',
                                    style: TextStyle(
                                      fontSize: 13,
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

                    // Informações do item
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Título e Status
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.item.titulo,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor().withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _getStatusColor(),
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  _getItemStatusText(),
                                  style: TextStyle(
                                    color: _getStatusColor(),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Categoria
                          Text(
                            'Categoria: ${CategoryHelper.getCategoryLabel(widget.item.categoria)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Descrição
                          const Text(
                            'Descrição',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.item.descricao,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[800],
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Localização
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 20,
                                color: Colors.grey[700],
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  widget.item.localizacao,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Data
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: Colors.grey[700],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${_getStatusText()} em: ${_formatDate(widget.item.lostOrFoundAt)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
      bottomNavigationBar:
          _userProfile != null
              ? _isOwner
                  ? SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TapButton(
                              onTap: () async {
                                final result = await Navigator.of(
                                  context,
                                ).pushNamed(
                                  createUpdateLostAndFoundItemRoute,
                                  arguments: widget.item,
                                );

                                if (result == true && mounted) {
                                  Navigator.of(context).pop(
                                    true,
                                  ); // Passa true indicando que houve mudança
                                }
                              },
                              text: 'Editar',
                              color: Color(0xFF173C7B),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TapButton(
                              onTap: () async {
                                final confirmed = await showConfirmationDialog(
                                  context: context,
                                  title: 'Confirmar exclusão',
                                  message:
                                      'Tem certeza que deseja deletar este item? Esta ação não pode ser desfeita.',
                                  confirmText: 'Deletar',
                                  cancelText: 'Cancelar',
                                  confirmColor:
                                      Colors
                                          .red, // Cor vermelha para ação destrutiva
                                );

                                if (confirmed) {
                                  try {
                                    // Mostrar loading
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder:
                                          (context) => const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                    );

                                    await LostAndFoundItemService().deleteItem(
                                      widget.item.id,
                                    );

                                    if (mounted) {
                                      Navigator.pop(context); // Fecha o loading
                                      Navigator.pop(
                                        context,
                                        true,
                                      ); // Volta para tela anterior

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Item deletado com sucesso',
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      Navigator.pop(context); // Fecha o loading
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text('Erro ao deletar: $e'),
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                              text: 'Deletar',
                              color: Color(0xFFe13b39),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  : SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton.icon(
                        onPressed: _openWhatsApp,
                        icon: const Icon(Icons.chat, size: 20),
                        label: const Text(
                          'Entrar em contato via WhatsApp',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  )
              : null,
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'jan',
      'fev',
      'mar',
      'abr',
      'mai',
      'jun',
      'jul',
      'ago',
      'set',
      'out',
      'nov',
      'dez',
    ];
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }
}
