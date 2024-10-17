import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:photoarc/utils/routes.dart';

import '../widgets/appbar_gradient.dart';
import '../widgets/buttons/loading_button.dart';
import '../widgets/buttons/splash_button.dart';
import '../widgets/inputs/email_input.dart';
import '../widgets/inputs/password_inout.dart';
import '../widgets/snackbar/error_snackbar.dart';
import '../widgets/snackbar/primary_snackbar.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        // Show success snackbar
        primarySnackbar(context, 'Account created successfully!');
        Navigator.pushReplacementNamed(context, Routes.home);
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
        // Show error snackbar
        ErrorSnackbar(context, 'Failed to create an account. ${_errorMessage}');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarGradient(),
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
                  'Create Account',
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
                  'Sign up to get started',
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
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
                    : SplashButton(
                  width: MediaQuery.of(context).size.width * 0.4,
                  title: 'Sign Up',
                  onPressed: _signUp,
                ),
              ),
              const SizedBox(height: 16.0),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, Routes.signin);
                      },
                      child: Text(
                        'Sign In',
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
