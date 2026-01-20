import 'package:find_uf/views/profile/profile_view.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isSearchExpanded = false;
  bool _isSearching = false;
  String _searchQuery = '';
  String _selectedFilter = 'todos'; // 'todos', 'achados', 'perdidos'

  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  ///Função para trocar de aba no NavigationBar
  void _onTabTapped(int index) {
    if (index == 2) {
      // Botão de criar reporte (+)
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CreateReportScreen()),
      );
      return;
    }

    setState(() {
      // Mapeia o índice do NavigationBar para o índice real
      if (index > 2) {
        _currentIndex = index + 1;
      } else {
        _currentIndex = index;
      }
      _isSearchExpanded = false;
      _isSearching = false; //  Para sair do modo de busca ao trocar de aba
    });
  }

  ///Função para iniciar busca e modificar a tela
  void _startSearch() {
    if (_searchController.text.trim().isEmpty) return;

    setState(() {
      _searchQuery = _searchController.text;
      _isSearching = true;
      _isSearchExpanded = false;
    });
  }

  ///Função para sair do modo de busca
  void _exitSearch() {
    setState(() {
      _isSearching = false;
      _searchQuery = '';
      _searchController.clear();
      _selectedFilter = 'todos';
    });
  }

  void _showFilterDialog() {
    // Placeholder para filtros avançados
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Filtros'),
            content: const Text('Opções de filtro virão aqui'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fechar'),
              ),
            ],
          ),
    );
  }

  ///Retorna o corpo da tela com base no estado/index atual
  Widget _getCurrentBody() {
    if (_isSearching) {
      return _buildSearchResults();
    }

    switch (_currentIndex) {
      case 0:
        return const Center(child: Text('Home - Feed de itens'));
      case 1:
        return const Center(child: Text('Chats'));
      case 4:
        return const Center(child: Text('Meus Reportes'));
      case 5:
        return const ProfileView();
      default:
        return const Center(child: Text('Home'));
    }
  }

  Widget _buildSearchResults() {
    return Column(
      children: [
        // Botões de filtro: Achados / Perdidos
        Container(
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
        ),

        // Resultados da busca
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: ListView.builder(
              key: ValueKey(_selectedFilter),
              padding: const EdgeInsets.all(16),
              itemCount: 10, // Placeholder
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
                    title: Text('Item ${index + 1} - $_selectedFilter'),
                    subtitle: Text('Busca: $_searchQuery'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterButton({required String label, required String value}) {
    final isSelected = _selectedFilter == value;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedFilter = value;
          });
        },
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
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading:
            _isSearching
                ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: _exitSearch,
                )
                : null,
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child:
              _isSearching
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
            IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.white),
              onPressed: _showFilterDialog,
            )
          else
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {
                if (_isSearchExpanded) {
                  _startSearch();
                } else {
                  setState(() {
                    _isSearchExpanded = true;
                  });
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
        data: Theme.of(
          context,
        ).copyWith(iconTheme: const IconThemeData(color: Colors.white)),
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
              icon: Icon(
                Icons.add_circle_outline,
                size: 32,
                color: Colors.white70,
              ),
              selectedIcon: Icon(
                Icons.add_circle,
                size: 32,
                color: Colors.white70,
              ),
              label: 'Criar',
            ),
            NavigationDestination(
              icon: Icon(Icons.assignment_outlined, color: Colors.white70),
              selectedIcon: Icon(Icons.assignment, color: Colors.white70),
              label: 'Reportes',
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

// Placeholder para a tela de criar reporte
class CreateReportScreen extends StatelessWidget {
  const CreateReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Reporte')),
      body: const Center(child: Text('Formulário de criação de reporte')),
    );
  }
}
