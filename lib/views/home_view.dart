import 'package:find_uf/constants/routes.dart';
import 'package:find_uf/views/home/home_feed_view.dart';
import 'package:find_uf/views/home/search_results_view.dart';
import 'package:find_uf/views/profile/profile_view.dart';
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
      Navigator.of(context).pushNamed(createLostAndFoundItemRoute);
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
      _searchQuery = _searchController.text.trim();
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
    });
  }

  void _showFilterDialog() {
    // Placeholder para filtros avançados
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtros Avançados'),
        content: const Text(
          'Em breve você poderá filtrar por:\n\n'
          '• Categoria\n'
          '• Data\n'
          '• Localização',
        ),
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
      return SearchResultsView(
        key: ValueKey(_searchQuery),
        searchQuery: _searchQuery,
      );
    }

    switch (_currentIndex) {
      case 0:
        return const HomeFeedView();
      case 1:
        return const Center(child: Text('Chats'));
      case 4:
        return const Center(child: Text('Meus Reportes'));
      case 5:
        return const ProfileView();
      default:
        return const HomeFeedView();
    }
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