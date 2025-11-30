import 'package:flutter/material.dart';
import 'package:frontend/pages/discover_page.dart';
import 'package:frontend/pages/history_page.dart';
import 'package:frontend/pages/planer_page.dart';
import 'package:frontend/pages/recipe_page.dart';
import 'package:frontend/pages/settings_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final PageController _controller = PageController();

  final List<Widget> pages = [
    const DiscoverPage(),
    const RecipePage(),
    const PlanerPage(),
    const HistoryPage(),
    const SettingsPage(),
  ];

  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        onPageChanged: (index) => {
          setState(() {
            currentPage = index;
          }),
        },
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentPage,
        onDestinationSelected: (value) {
          setState(() {
            currentPage = value;
          });

          _controller.animateToPage(
            value,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.search),
            label: "Entdecken",
          ),
          NavigationDestination(
            icon: Icon(Icons.book),
            label: "Meine Rezepte",
          ),
          NavigationDestination(
            icon: Icon(Icons.help),
            label: "Planer",
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: "Verlauf",
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: "Einstellungen",
          ),
        ],
      ),
    );
  }
}