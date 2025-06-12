import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:event_reminder_app/models/app_user.dart';
import 'package:provider/provider.dart';
import 'package:event_reminder_app/providers/user_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  void initState() {
    super.initState();
    _checkIfLoggedIn();
  }

  void _checkIfLoggedIn() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      AppUser appUser = AppUser(
        uid: user.uid,
        name: user.displayName,
        email: user.email,
        photoUrl: user.photoURL,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Provider.of<UserProvider>(context, listen: false).setUser(appUser);
          Navigator.pushReplacementNamed(context, '/home');
        }
      });
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final user = userCredential.user;

      if (user != null) {
        AppUser appUser = AppUser(
          uid: user.uid,
          name: user.displayName,
          email: user.email,
          photoUrl: user.photoURL,
        );

        if (mounted) {
          Provider.of<UserProvider>(context, listen: false).setUser(appUser);
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Google Sign-in failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final logo = Hero(
      tag: 'hero-logo',
      child: Image.asset('lib/assets/notify.png', height: 100),
    );

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              logo,
              const SizedBox(height: 20),
              const Text(
                'Sign in with Google',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _signInWithGoogle,
                icon: const Icon(Icons.login),
                label: const Text('Continue with Google'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
