import 'package:flutter/material.dart';
import 'package:frontend/features/presentation/pages/discover_page.dart';
import 'package:frontend/features/presentation/pages/planer_page.dart';
import 'package:frontend/features/presentation/pages/my_recipes_page.dart';
import 'package:frontend/features/presentation/pages/settings_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final PageController _controller = PageController();

  final List<Widget> pages = [
    const DiscoverPage(),
    const MyRecipesPage(),
    const PlanerPage(),
    const SettingsPage(),
  ];

  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        onPageChanged: (index) => {setState(() => currentPage = index)},
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentPage,
        onDestinationSelected: (value) {
          setState(() => currentPage = value);

          _controller.animateToPage(
            value,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          );
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.search), label: "Entdecken"),
          NavigationDestination(icon: Icon(Icons.book), label: "Meine Rezepte"),
          NavigationDestination(icon: Icon(Icons.menu_book), label: "Planer"),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: "Einstellungen",
          ),
        ],
      ),
    );
  }
}
