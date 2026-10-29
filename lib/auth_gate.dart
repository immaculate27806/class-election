import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'election_home.dart';
import 'login_screen.dart';

/// Watches FirebaseAuth and shows the login screen or the app.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.data == null) {
          return const LoginScreen();
        }
        return const ElectionHome();
      },
    );
  }
}
