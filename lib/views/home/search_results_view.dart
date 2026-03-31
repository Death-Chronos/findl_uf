import 'package:findl_uf/models/enums/item_status.dart';
import 'package:findl_uf/models/lost_and_find_item.dart';
import 'package:findl_uf/models/search_filters.dart';
import 'package:findl_uf/services/items/lost_and_found_item_service.dart';
import 'package:findl_uf/views/items/components/items_grid.dart';
import 'package:flutter/material.dart';

class SearchResultsView extends StatefulWidget {
  final String searchQuery;
  final SearchFilters? filters;

  const SearchResultsView({
    super.key,
    required this.searchQuery,
    this.filters,
  });

  @override
  State<SearchResultsView> createState() => _SearchResultsViewState();
}

class _SearchResultsViewState extends State<SearchResultsView> {
  final _itemService = LostAndFoundItemService();

  List<LostAndFoundItem> _items = [];
  bool _isLoading = true;

  /// Status selecionado na barra de filtro rápido.
  /// null = todos, found = achados, lost = perdidos.
  ItemStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _searchItems();
  }

  @override
  void didUpdateWidget(SearchResultsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery ||
        oldWidget.filters != widget.filters) {
      _searchItems();
    }
  }

  Future<void> _searchItems() async {
    setState(() => _isLoading = true);

    try {
      final items = await _itemService.searchItems(
        query: widget.searchQuery,
        filters: widget.filters,
        status: _selectedStatus,
      );

      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _items = [];
        _isLoading = false;
      });
    }
  }

  void _onStatusChanged(ItemStatus? status) {
    setState(() => _selectedStatus = status);
    _searchItems();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildStatusFilterBar(),

        if (widget.filters != null && !widget.filters!.isEmpty)
          _buildActiveFiltersInfo(),

        Expanded(
          child: ItemsGridView(
            items: _items,
            isLoading: _isLoading,
            emptyMessage: 'Nenhum item encontrado para "${widget.searchQuery}"',
            onRefresh: _searchItems,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusFilterBar() {
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
          Expanded(child: _buildStatusButton(label: 'Todos', value: null)),
          const SizedBox(width: 8),
          Expanded(child: _buildStatusButton(label: 'Achados', value: ItemStatus.found)),
          const SizedBox(width: 8),
          Expanded(child: _buildStatusButton(label: 'Perdidos', value: ItemStatus.lost)),
        ],
      ),
    );
  }

  Widget _buildStatusButton({required String label, required ItemStatus? value}) {
    final isSelected = _selectedStatus == value;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: ElevatedButton(
        onPressed: () => _onStatusChanged(value),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? const Color(0xFF173C7B) : Colors.white,
          foregroundColor: isSelected ? Colors.white : Colors.black87,
          elevation: isSelected ? 2 : 0,
          side: BorderSide(
            color: isSelected ? const Color(0xFF173C7B) : Colors.grey[300]!,
            width: 1,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildActiveFiltersInfo() {
    final filters = widget.filters!;
    final chips = <Widget>[];

    if (filters.categoria != null) {
      chips.add(_buildInfoChip('Cat: ${filters.categoria!.label}'));
    }

    if (filters.dataInicio != null || filters.dataFim != null) {
      final inicio = filters.dataInicio != null ? _formatDate(filters.dataInicio!) : '...';
      final fim = filters.dataFim != null ? _formatDate(filters.dataFim!) : '...';
      chips.add(_buildInfoChip('$inicio → $fim'));
    }

    if (filters.localizacao != null && filters.localizacao!.isNotEmpty) {
      chips.add(_buildInfoChip('Local: ${filters.localizacao}'));
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF173C7B).withValues(alpha: 0.06),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Icon(Icons.filter_list, size: 14, color: Color(0xFF173C7B)),
          ...chips,
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF173C7B).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF173C7B),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}