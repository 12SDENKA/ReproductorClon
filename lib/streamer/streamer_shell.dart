import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import '../screens/library_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/mini_player.dart';
import 'genre_grid_screen.dart';

/// Copia de tu HomeShell; la única diferencia es que "Buscar" usa
/// GenreGridScreen (streaming). Tu home_shell.dart queda intacto.
class StreamerShell extends StatefulWidget {
  const StreamerShell({super.key});

  @override
  State<StreamerShell> createState() => _StreamerShellState();
}

class _StreamerShellState extends State<StreamerShell> {
  int _index = 0;

  final _screens = const [
    HomeScreen(),
    GenreGridScreen(),
    LibraryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: _index, children: _screens),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(),
          const SizedBox(height: 6),
          Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.divider, width: 0.5),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _index,
              onTap: (i) => setState(() => _index = i),
              backgroundColor: AppColors.darkBg,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Inicio',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search_outlined),
                  activeIcon: Icon(Icons.search),
                  label: 'Buscar',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.library_music_outlined),
                  activeIcon: Icon(Icons.library_music),
                  label: 'Biblioteca',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
