import 'package:find_uf/helpers/category_helper.dart';
import 'package:find_uf/models/enums/item_status.dart';
import 'package:find_uf/models/lost_and_find_item.dart';
import 'package:flutter/material.dart';

class ItemCard extends StatelessWidget {
  final LostAndFoundItem item;
  final VoidCallback? onTap;

  const ItemCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColors = CategoryHelper.getCategoryColors(item.categoria);
    final categoryLabel = CategoryHelper.getCategoryLabel(item.categoria);
    final isFound = item.status == ItemStatus.found;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagem do item
                _buildItemImage(),

                // Informações do item
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.titulo,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.descricao,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Chip(
                        label: Text(
                          categoryLabel,
                          style: TextStyle(
                            color: categoryColors['text'],
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: categoryColors['bg'],
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        visualDensity: VisualDensity.compact,
                        side: BorderSide.none,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Badge de status (Found/Lost)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isFound ? Colors.green.shade600 : Colors.red.shade700,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  isFound ? Icons.inventory_2_outlined : Icons.search,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemImage() {
    if (item.fotosUrls.isEmpty) {
      return Container(
        height: 120,
        color: Colors.grey[300],
        child: Center(
          child: Icon(
            Icons.image_not_supported,
            color: Colors.grey[600],
            size: 40,
          ),
        ),
      );
    }

    return Image.network(
      item.fotosUrls.first,
      height: 120,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: 120,
          color: Colors.grey[200],
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => Container(
        height: 120,
        color: Colors.grey[300],
        child: Center(
          child: Icon(
            Icons.broken_image,
            color: Colors.grey[600],
            size: 40,
          ),
        ),
      ),
    );
  }
}
