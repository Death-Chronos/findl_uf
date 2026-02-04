import 'package:find_uf/models/lost_and_find_item.dart';
import 'package:find_uf/services/auth/auth_service.dart';
import 'package:find_uf/services/items/lost_and_found_item_service.dart';
import 'package:find_uf/views/items/components/items_grid.dart';
import 'package:flutter/material.dart';

class MyItemsView extends StatefulWidget {
  const MyItemsView({super.key});

  @override
  State<MyItemsView> createState() => _MyItemsViewState();
}

class _MyItemsViewState extends State<MyItemsView> {
  List<LostAndFoundItem> _items = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      
      final user = await AuthService.supabase().getUser;
      final items = await LostAndFoundItemService().getUserItems(user!.id);

      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar itens: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadItems,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    return ItemsGridView(
      items: _items,
      isLoading: _isLoading,
      emptyMessage: 'Nenhum item cadastrado ainda.\n Caso ache/algo, cadastre aqui!',
      onRefresh: _loadItems,
    );
  }
}