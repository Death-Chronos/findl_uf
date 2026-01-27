import 'package:find_uf/models/enums/item_category.dart';
import 'package:flutter/material.dart';

class CategoryHelper {
  static String getCategoryLabel(ItemCategory category) {
    switch (category) {
      case ItemCategory.documents:
        return 'Documentos';
      case ItemCategory.keys:
        return 'Chaves';
      case ItemCategory.electronics:
        return 'Eletrônicos';
      case ItemCategory.bags:
        return 'Mochilas';
      case ItemCategory.wallet:
        return 'Carteiras';
      case ItemCategory.clothing:
        return 'Roupas';
      case ItemCategory.books:
        return 'Livros';
      case ItemCategory.accessories:
        return 'Acessórios';
      case ItemCategory.bottles:
        return 'Garrafas';
      case ItemCategory.others:
        return 'Outros';
    }
  }

  static Map<String, Color> getCategoryColors(ItemCategory category) {
    switch (category) {
      case ItemCategory.documents:
        return {'bg': Colors.pink.shade100, 'text': Colors.pink.shade800};
      case ItemCategory.keys:
        return {'bg': Colors.yellow.shade100, 'text': Colors.yellow.shade800};
      case ItemCategory.electronics:
        return {'bg': Colors.green.shade100, 'text': Colors.green.shade800};
      case ItemCategory.bags:
        return {'bg': Colors.red.shade100, 'text': Colors.red.shade800};
      case ItemCategory.wallet:
        return {'bg': Colors.orange.shade100, 'text': Colors.orange.shade800};
      case ItemCategory.clothing:
        return {'bg': Colors.teal.shade100, 'text': Colors.teal.shade800};
      case ItemCategory.books:
        return {'bg': Colors.indigo.shade100, 'text': Colors.indigo.shade800};
      case ItemCategory.accessories:
        return {'bg': Colors.purple.shade100, 'text': Colors.purple.shade800};
      case ItemCategory.bottles:
        return {'bg': Colors.cyan.shade100, 'text': Colors.cyan.shade800};
      case ItemCategory.others:
        return {'bg': Colors.grey.shade200, 'text': Colors.grey.shade800};
    }
  }
}
