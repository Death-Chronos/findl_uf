import 'package:findl_uf/constants/routes.dart';
import 'package:findl_uf/models/enums/item_category.dart';
import 'package:findl_uf/models/search_filters.dart';
import 'package:findl_uf/views/home/home_feed_view.dart';
import 'package:findl_uf/views/home/chats_view.dart';
import 'package:findl_uf/views/home/my_items_view.dart';
import 'package:findl_uf/views/home/search_results_view.dart';
import 'package:findl_uf/views/profile/profile_view.dart';
import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;
  bool _isSearchExpanded = false;
  bool _isSearching = false;
  String _searchQuery = '';

  /// Estado dos filtros avançados. Dono aqui no HomeView porque é quem
  /// tem acesso tanto ao botão de filtro (AppBar) quanto à SearchResultsView.
  SearchFilters _activeFilters = const SearchFilters();

  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index == 2) {
      Navigator.of(context).pushNamed(createUpdateLostAndFoundItemRoute);
      return;
    }

    setState(() {
      if (index > 2) {
        _currentIndex = index + 1;
      } else {
        _currentIndex = index;
      }
      _isSearchExpanded = false;
      _isSearching = false;
    });
  }

  void _startSearch() {
    if (_searchController.text.trim().isEmpty) return;

    setState(() {
      _searchQuery = _searchController.text.trim();
      _isSearching = true;
      _isSearchExpanded = false;
      // Limpa os filtros ao iniciar uma nova busca para evitar
      // resultados confusos com filtros de uma busca anterior.
      _activeFilters = const SearchFilters();
    });
  }

  void _exitSearch() {
    setState(() {
      _isSearching = false;
      _searchQuery = '';
      _activeFilters = const SearchFilters();
      _searchController.clear();
    });
  }

  /// Abre o bottom sheet de filtros avançados e aguarda o resultado.
  /// Se o usuário confirmar, atualiza [_activeFilters] e o
  /// [SearchResultsView] rebuscará automaticamente via [didUpdateWidget].
  Future<void> _showFilterDialog() async {
    final result = await showModalBottomSheet<SearchFilters>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterBottomSheet(initialFilters: _activeFilters),
    );

    // [result] é null se o usuário dispensou sem confirmar.
    if (result != null && mounted) {
      setState(() => _activeFilters = result);
    }
  }

  Widget _getCurrentBody() {
    if (_isSearching) {
      return SearchResultsView(
        // A key combina query + filtros para forçar reconstrução do widget
        // quando qualquer um dos dois mudar.
        key: ValueKey('$_searchQuery-${_activeFilters.hashCode}'),
        searchQuery: _searchQuery,
        filters: _activeFilters,
      );
    }

    switch (_currentIndex) {
      case 0:
        return const HomeFeedView();
      case 1:
        return const ChatsView();
      case 4:
        return const MyItemsView();
      case 5:
        return const ProfileView();
      default:
        return const HomeFeedView();
    }
  }

  /// Constrói o ícone de filtro com badge indicando quantos filtros estão ativos.
  Widget _buildFilterIcon() {
    final count = _activeFilters.activeCount;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(
            // Ícone preenchido quando há filtros ativos para dar feedback visual
            count > 0 ? Icons.filter_list : Icons.filter_list,
            color: count > 0 ? Colors.amber : Colors.white,
          ),
          onPressed: _showFilterDialog,
        ),
        if (count > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _isSearching
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: _exitSearch,
              )
            : null,
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isSearching
              ? Text(
                  'Resultados: $_searchQuery',
                  key: const ValueKey('search-results'),
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                )
              : _isSearchExpanded
                  ? TextField(
                      key: const ValueKey('search'),
                      controller: _searchController,
                      autofocus: true,
                      onSubmitted: (_) => _startSearch(),
                      decoration: const InputDecoration(
                        hintText: 'Buscar itens...',
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    )
                  : const Text(
                      'Findluf',
                      key: ValueKey('title'),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
        ),
        actions: [
          if (_isSearching)
            // Ícone de filtro com badge — só aparece no modo de busca
            _buildFilterIcon()
          else
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {
                if (_isSearchExpanded) {
                  _startSearch();
                } else {
                  setState(() => _isSearchExpanded = true);
                }
              },
            ),
          if (_isSearchExpanded)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                setState(() {
                  _isSearchExpanded = false;
                  _searchController.clear();
                });
              },
            ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _getCurrentBody(),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context)
            .copyWith(iconTheme: const IconThemeData(color: Colors.white)),
        child: NavigationBar(
          selectedIndex: _currentIndex > 2 ? _currentIndex - 1 : _currentIndex,
          onDestinationSelected: _onTabTapped,
          backgroundColor: Colors.black,
          indicatorColor: const Color(0xFF173C7B),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          labelTextStyle: const WidgetStatePropertyAll(
            TextStyle(color: Colors.white, fontSize: 12),
          ),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: Colors.white70),
              selectedIcon: Icon(Icons.home, color: Colors.white70),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline, color: Colors.white70),
              selectedIcon: Icon(Icons.chat_bubble, color: Colors.white70),
              label: 'Chats',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_circle_outline, size: 32, color: Colors.white70),
              selectedIcon: Icon(Icons.add_circle, size: 32, color: Colors.white70),
              label: 'Criar Item',
            ),
            NavigationDestination(
              icon: Icon(Icons.assignment_outlined, color: Colors.white70),
              selectedIcon: Icon(Icons.assignment, color: Colors.white70),
              label: 'Meus itens',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline, color: Colors.white70),
              selectedIcon: Icon(Icons.person, color: Colors.white70),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom Sheet de Filtros Avançados
// ---------------------------------------------------------------------------

/// Widget separado e stateful para o bottom sheet de filtros.
/// Gerencia seu próprio estado temporário e só sobe o resultado
/// ao pai quando o usuário confirma via [Navigator.pop].
class _FilterBottomSheet extends StatefulWidget {
  final SearchFilters initialFilters;

  const _FilterBottomSheet({required this.initialFilters});

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late ItemCategory? _categoria;
  late DateTime? _dataInicio;
  late DateTime? _dataFim;
  late TextEditingController _localizacaoController;

  @override
  void initState() {
    super.initState();
    // Inicializa com os filtros atuais para que o usuário veja
    // o que já estava selecionado ao reabrir o bottom sheet.
    _categoria = widget.initialFilters.categoria;
    _dataInicio = widget.initialFilters.dataInicio;
    _dataFim = widget.initialFilters.dataFim;
    _localizacaoController = TextEditingController(
      text: widget.initialFilters.localizacao ?? '',
    );
  }

  @override
  void dispose() {
    _localizacaoController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_dataInicio ?? now)
          : (_dataFim ?? _dataInicio ?? now),
      // Data mínima: 1 ano atrás — razoável para itens perdidos/achados
      firstDate: DateTime(now.year - 1),
      lastDate: now,
      helpText: isStart ? 'Data de início' : 'Data de fim',
    );

    if (picked == null) return;

    setState(() {
      if (isStart) {
        _dataInicio = picked;
        // Garante que dataFim não seja anterior à dataInicio
        if (_dataFim != null && _dataFim!.isBefore(picked)) {
          _dataFim = picked;
        }
      } else {
        _dataFim = picked;
      }
    });
  }

  void _clearFilters() {
    setState(() {
      _categoria = null;
      _dataInicio = null;
      _dataFim = null;
      _localizacaoController.clear();
    });
  }

  void _applyFilters() {
    final localizacao = _localizacaoController.text.trim();

    Navigator.pop(
      context,
      SearchFilters(
        categoria: _categoria,
        dataInicio: _dataInicio,
        dataFim: _dataFim,
        localizacao: localizacao.isEmpty ? null : localizacao,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    // [viewInsets.bottom] empurra o sheet para cima quando o teclado abre
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle visual do bottom sheet
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Cabeçalho
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filtros Avançados',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: _clearFilters,
                  child: const Text(
                    'Limpar tudo',
                    style: TextStyle(color: Color(0xFF173C7B)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Seção: Categoria ──────────────────────────────────────────
            _buildSectionLabel('Categoria'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ItemCategory.values.map((cat) {
                final isSelected = _categoria == cat;
                return FilterChip(
                  label: Text(cat.label),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      // Tapping no chip já selecionado o desmarca (toggle)
                      _categoria = isSelected ? null : cat;
                    });
                  },
                  selectedColor: const Color(0xFF173C7B),
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  backgroundColor: Colors.grey[100],
                  side: BorderSide(
                    color: isSelected
                        ? const Color(0xFF173C7B)
                        : Colors.grey[300]!,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // ── Seção: Período ────────────────────────────────────────────
            _buildSectionLabel('Período'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildDateButton(
                    label: 'De',
                    date: _dataInicio,
                    onTap: () => _pickDate(isStart: true),
                    onClear: _dataInicio != null
                        ? () => setState(() => _dataInicio = null)
                        : null,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
                ),
                Expanded(
                  child: _buildDateButton(
                    label: 'Até',
                    date: _dataFim,
                    onTap: () => _pickDate(isStart: false),
                    onClear: _dataFim != null
                        ? () => setState(() => _dataFim = null)
                        : null,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Seção: Localização ────────────────────────────────────────
            _buildSectionLabel('Localização'),
            const SizedBox(height: 4),
            const Text(
              'Filtra por parte do texto (ex: "Bloco A", "Biblioteca")',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _localizacaoController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Digite um local...',
                prefixIcon: const Icon(Icons.location_on_outlined),
                suffixIcon: _localizacaoController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          setState(() => _localizacaoController.clear());
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF173C7B)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
              // Rebuild para exibir/esconder o botão de limpar
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 32),

            // ── Botão de Aplicar ──────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF173C7B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Aplicar Filtros',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildDateButton({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    VoidCallback? onClear,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: date != null ? const Color(0xFF173C7B) : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(12),
          color: date != null
              ? const Color(0xFF173C7B).withValues(alpha: 0.05)
              : Colors.grey[50],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date != null ? _formatDate(date) : 'Qualquer data',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: date != null ? const Color(0xFF173C7B) : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: const Icon(Icons.clear, size: 16, color: Colors.grey),
              )
            else
              const Icon(Icons.calendar_today_outlined,
                  size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}