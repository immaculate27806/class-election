import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'vote_screen.dart';
import 'results_screen.dart';
import 'candidates_screen.dart';

class ElectionHome extends StatefulWidget {
  const ElectionHome({super.key});

  @override
  State<ElectionHome> createState() => _ElectionHomeState();
}

class _ElectionHomeState extends State<ElectionHome> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = const [
      VoteScreen(),
      ResultsScreen(),
      CandidatesScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.how_to_vote), label: 'Vote'),
          NavigationDestination(
              icon: Icon(Icons.bar_chart), label: 'Results'),
          NavigationDestination(
              icon: Icon(Icons.people), label: 'Candidates'),
        ],
      ),
    );
  }
}

/// Shared AppBar logout button — used in each tab screen.
Widget logoutAction(BuildContext context) {
  return IconButton(
    icon: const Icon(Icons.logout),
    tooltip: 'Log out',
    onPressed: () => FirebaseAuth.instance.signOut(),
  );
}
