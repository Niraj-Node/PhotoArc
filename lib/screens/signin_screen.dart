import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:photoarc/utils/auth_service.dart';
import 'package:photoarc/utils/routes.dart';
import 'package:photoarc/widgets/appbar_gradient.dart';
import 'package:photoarc/widgets/inputs/email_input.dart';
import 'package:photoarc/widgets/inputs/password_input.dart';
import 'package:photoarc/widgets/buttons/loading_button.dart';
import 'package:photoarc/widgets/buttons/splash_button.dart';
import 'package:photoarc/widgets/snackbar/error_snackbar.dart';
import 'package:photoarc/widgets/snackbar/primary_snackbar.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  void _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      String email = _emailController.text;
      String password = _passwordController.text;

      User? user = await AuthService().signInWithEmailAndPassword(
          email, password);

      setState(() {
        _isLoading = false;
      });

      if (user != null) {
        if (mounted) {
          primarySnackbar(context, 'Signed in successfully!');
          Navigator.pushReplacementNamed(context, Routes.home);
        }
      } else {
        if (mounted) {
          ErrorSnackbar(
              context, 'Failed to sign in. Please check your credentials.');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarGradient(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32.0),
              Center(
                child: Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black.withOpacity(0.8),
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              Center(
                child: Text(
                  'Sign in to continue',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.withOpacity(0.9),
                  ),
                ),
              ),
              const SizedBox(height: 32.0),
              EmailInput(inputController: _emailController),
              const SizedBox(height: 10.0),
              PasswordInput(inputController: _passwordController),
              const SizedBox(height: 32.0),
              Center(
                child: _isLoading
                    ? LoadingButton(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: const Text(
                    'Loading...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
                    : SplashButton(
                  width: MediaQuery.of(context).size.width * 0.4,
                  title: 'Sign In',
                  onPressed: _signIn,
                ),
              ),
              const SizedBox(height: 16.0),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, Routes.signup);
                      },
                      child: Text(
                        'Create Account',
                        style: TextStyle(
                          color: Colors.blueAccent.withOpacity(0.8),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
