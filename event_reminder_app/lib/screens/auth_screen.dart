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
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLogin = true;

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

      // Defer state changes and navigation with mounted check
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // Check if widget is still mounted
          Provider.of<UserProvider>(context, listen: false).setUser(appUser);
          Navigator.pushReplacementNamed(context, '/home');
        }
      });
    }
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
      if (mounted) {
        // Check if widget is still mounted
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        // Check if widget is still mounted
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
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
          // Check if widget is still mounted
          Provider.of<UserProvider>(context, listen: false).setUser(appUser);
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      if (mounted) {
        // Check if widget is still mounted
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
              Text(
                isLogin ? 'Sign In' : 'Sign Up',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      validator:
                          (value) =>
                              value!.contains('@') ? null : 'Invalid email',
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      validator:
                          (value) =>
                              value != null && value.length >= 6
                                  ? null
                                  : 'Password too short',
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submit,
                      child: Text(isLogin ? 'Login' : 'Register'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _signInWithGoogle,
                icon: const Icon(Icons.login),
                label: const Text('Continue with Google'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  setState(() {
                    isLogin = !isLogin;
                  });
                },
                child: Text(
                  isLogin
                      ? "Don't have an account? Register"
                      : "Already have an account? Login",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
