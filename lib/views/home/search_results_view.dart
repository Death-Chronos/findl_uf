import 'package:find_uf/models/enums/item_status.dart';
import 'package:find_uf/models/lost_and_find_item.dart';
import 'package:find_uf/views/items/components/items_grid.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchResultsView extends StatefulWidget {
  final String searchQuery;

  const SearchResultsView({
    super.key,
    required this.searchQuery,
  });

  @override
  State<SearchResultsView> createState() => _SearchResultsViewState();
}

class _SearchResultsViewState extends State<SearchResultsView> {
  final _supabase = Supabase.instance.client;
  List<LostAndFoundItem> _allItems = [];
  List<LostAndFoundItem> _filteredItems = [];
  bool _isLoading = true;
  String _selectedFilter = 'todos'; // 'todos', 'achados', 'perdidos'

  @override
  void initState() {
    super.initState();
    _searchItems();
  }

  @override
  void didUpdateWidget(SearchResultsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _searchItems();
    }
  }

  Future<void> _searchItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Busca por título ou descrição que contenha o termo de busca
      final response = await _supabase
          .from('lost_and_found_items')
          .select()
          .or('titulo.ilike.%${widget.searchQuery}%,descricao.ilike.%${widget.searchQuery}%')
          .order('created_at', ascending: false);

      final items = (response as List)
          .map((json) => LostAndFoundItem.fromJson(json))
          .toList();

      setState(() {
        _allItems = items;
        _applyFilter();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _allItems = [];
        _filteredItems = [];
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    if (_selectedFilter == 'todos') {
      _filteredItems = _allItems;
    } else if (_selectedFilter == 'achados') {
      _filteredItems = _allItems
          .where((item) => item.status == ItemStatus.found)
          .toList();
    } else if (_selectedFilter == 'perdidos') {
      _filteredItems = _allItems
          .where((item) => item.status == ItemStatus.lost)
          .toList();
    }
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
      _applyFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Botões de filtro
        _buildFilterButtons(),

        // Grid de resultados
        Expanded(
          child: ItemsGridView(
            items: _filteredItems,
            isLoading: _isLoading,
            emptyMessage: 'Nenhum item encontrado para "${widget.searchQuery}"',
            onRefresh: _searchItems,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildFilterButton(label: 'Todos', value: 'todos'),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildFilterButton(label: 'Achados', value: 'achados'),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildFilterButton(label: 'Perdidos', value: 'perdidos'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton({required String label, required String value}) {
    final isSelected = _selectedFilter == value;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: ElevatedButton(
        onPressed: () => _onFilterChanged(value),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? const Color(0xFF173C7B) : Colors.white,
          foregroundColor: isSelected ? Colors.white : Colors.black87,
          elevation: isSelected ? 2 : 0,
          side: BorderSide(
            color: isSelected ? const Color(0xFF173C7B) : Colors.grey[300]!,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}