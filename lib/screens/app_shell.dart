import 'dart:ui';

import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'favorites_screen.dart';
import 'compare_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int selected = 0;

  final pages = const [
    HomeScreen(),
    FavoritesScreen(),
    CompareScreen(),
  ];

  static const teal = Color(0xFF397D83);

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 850;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      extendBody: true,
      body: Stack(
        children: [
          // Background behind the navigation sidebar
          Positioned.fill(
            child: Image.asset(
              'assets/images/seasons/spring.jpg',
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: Container(
              color: const Color(0x55F4F7F5),
            ),
          ),

          Row(
            children: [
              if (wide)
                ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 18,
                      sigmaY: 18,
                    ),
                    child: Container(
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.48),
                        border: Border(
                          right: BorderSide(
                            color: Colors.white.withValues(alpha: 0.55),
                            width: 1,
                          ),
                        ),
                      ),
                      child: NavigationRail(
                        backgroundColor: Colors.transparent,
                        selectedIndex: selected,
                        onDestinationSelected: (i) {
                          setState(() => selected = i);
                        },
                        labelType: NavigationRailLabelType.all,
                        minWidth: 85,
                        groupAlignment: -0.35,
                        useIndicator: true,
                        indicatorColor: const Color(0xFFCCE7E5),
                        leading: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 28,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(13),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.55),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.wb_twilight,
                              size: 29,
                              color: teal,
                            ),
                          ),
                        ),
                        selectedIconTheme: const IconThemeData(
                          color: teal,
                          size: 25,
                        ),
                        unselectedIconTheme: IconThemeData(
                          color: Colors.blueGrey.shade700,
                          size: 24,
                        ),
                        selectedLabelTextStyle: const TextStyle(
                          color: teal,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                        unselectedLabelTextStyle: TextStyle(
                          color: Colors.blueGrey.shade800,
                          fontSize: 12,
                        ),
                        destinations: const [
                          NavigationRailDestination(
                            icon: Icon(Icons.home_outlined),
                            selectedIcon: Icon(Icons.home_rounded),
                            label: Text('Discover'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.bookmark_border),
                            selectedIcon: Icon(Icons.bookmark_rounded),
                            label: Text('My places'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.compare_arrows),
                            selectedIcon: Icon(Icons.compare_arrows_rounded),
                            label: Text('Compare'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: IndexedStack(
                  index: selected,
                  children: pages,
                ),
              ),
            ],
          ),
        ],
      ),

      // Mobile navigation
      bottomNavigationBar: wide
          ? null
          : ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 18,
                  sigmaY: 18,
                ),
                child: NavigationBar(
                  backgroundColor: Colors.white.withValues(alpha: 0.72),
                  elevation: 0,
                  indicatorColor: const Color(0xFFCCE7E5),
                  selectedIndex: selected,
                  onDestinationSelected: (i) {
                    setState(() => selected = i);
                  },
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home_rounded),
                      label: 'Discover',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.bookmark_border),
                      selectedIcon: Icon(Icons.bookmark_rounded),
                      label: 'My places',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.compare_arrows),
                      selectedIcon: Icon(Icons.compare_arrows_rounded),
                      label: 'Compare',
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
