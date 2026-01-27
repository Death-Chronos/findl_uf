
import 'package:find_uf/models/lost_and_find_item.dart';
import 'package:flutter/material.dart';

import 'item_card.dart';

class ItemsGridView extends StatelessWidget {
  final List<LostAndFoundItem> items;
  final bool isLoading;
  final String? emptyMessage;
  final VoidCallback? onRefresh;

  const ItemsGridView({
    super.key,
    required this.items,
    this.isLoading = false,
    this.emptyMessage,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage ?? 'Nenhum item encontrado',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            if (onRefresh != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Atualizar'),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        onRefresh?.call();
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.68,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return ItemCard(
            item: item,
            onTap: () {
              // TODO: Navegar para detalhes do item
              // Navigator.pushNamed(context, itemDetailsRoute, arguments: item);
            },
          );
        },
      ),
    );
  }
}
