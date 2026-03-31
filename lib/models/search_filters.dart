import 'package:findl_uf/models/enums/item_category.dart';

/// Mantém o estado dos filtros avançados da busca.
///
/// Todos os campos são opcionais — [null] significa "sem filtro aplicado". 
/// A imutabilidade aqui é intencional: ao invés de mutar o objeto,
/// criamos um novo via construtor, o que facilita comparar estados no
/// [didUpdateWidget] do [SearchResultsView].
class SearchFilters {
  final ItemCategory? categoria;
  final DateTime? dataInicio;
  final DateTime? dataFim;
  final String? localizacao;

  const SearchFilters({
    this.categoria,
    this.dataInicio,
    this.dataFim,
    this.localizacao,
  });

  /// Retorna [true] se nenhum filtro está ativo.
  bool get isEmpty =>
      categoria == null &&
      dataInicio == null &&
      dataFim == null &&
      (localizacao == null || localizacao!.trim().isEmpty);

  /// Conta quantos "grupos" de filtros estão ativos.
  /// Data de início e fim são contadas como um único grupo ("Período").
  int get activeCount {
    int count = 0;
    if (categoria != null) count++;
    if (dataInicio != null || dataFim != null) count++;
    if (localizacao != null && localizacao!.trim().isNotEmpty) count++;
    return count;
  }

  /// Igualdade baseada em valor para o [didUpdateWidget] funcionar
  /// corretamente ao comparar filtros antigos com novos.
  @override
  bool operator ==(Object other) =>
      other is SearchFilters &&
      other.categoria == categoria &&
      other.dataInicio == dataInicio &&
      other.dataFim == dataFim &&
      other.localizacao == localizacao;

  @override
  int get hashCode => Object.hash(categoria, dataInicio, dataFim, localizacao);
}

/// Rótulos em português para exibição na UI.
extension ItemCategoryLabel on ItemCategory {
  String get label {
    switch (this) {
      case ItemCategory.documents:
        return 'Documentos';
      case ItemCategory.keys:
        return 'Chaves';
      case ItemCategory.electronics:
        return 'Eletrônicos';
      case ItemCategory.bags:
        return 'Bolsas';
      case ItemCategory.wallet:
        return 'Carteira';
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
}