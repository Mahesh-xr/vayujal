import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vayujal/screens/signup_screen.dart';
import 'package:vayujal/screens/verification_screen.dart';
import 'package:vayujal/widgets/navigations/NormalAppBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Added for Firestore
import 'package:vayujal/screens/dashboard_screen.dart'; // Added for DashboardScreen
import 'package:vayujal/screens/profile_setup_screen.dart'; // Added for ProfileSetupScreen

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {Color? backgroundColor}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor ?? Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _setLoading(bool loading) {
    if (!mounted) return;
    setState(() => _isLoading = loading);
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {                                                                                                                                                                                                                                                                                                                                                                                                                                                     g
      _setLoading(true);

      try {
        print('=== LOGIN ATTEMPT ===');
        print('Email: ${_emailController.text.trim()}');
        
        final UserCredential result = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        print('Login successful for user: ${result.user?.uid}');
        print('User email verified: ${result.user?.emailVerified}');

        // After login, check isProfileComplete in Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('admins')
            .doc(result.user!.uid)
            .get();
        final data = userDoc.data() as Map<String, dynamic>?;
        final bool isProfileComplete = data != null && data['isProfileComplete'] == true;
        print(isProfileComplete ? 'Profile is complete' : 'Profile is not complete');
        if (!mounted) return;
        if (isProfileComplete) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
          );
        }
        
      } on FirebaseAuthException catch (e) {
        print('Firebase Auth Error: ${e.code} - ${e.message}');
        
        String errorMessage = 'Login failed';
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No user found for that email.';
            break;
          case 'wrong-password':
            errorMessage = 'Incorrect password.';
            break;
          case 'invalid-email':
            errorMessage = 'Invalid email format.';
            break;
          case 'user-disabled':
            errorMessage = 'This account has been disabled.';
            break;
          case 'too-many-requests':
            errorMessage = 'Too many attempts. Please try again later.';
            break;
          case 'network-request-failed':
            errorMessage = 'Network error. Please check your connection.';
            break;
          case 'invalid-credential':
            errorMessage = 'Invalid email or password.';
            break;
          default:
            errorMessage = e.message ?? 'Login failed. Please try again.';
        }
        
        _showSnackBar(errorMessage);
      } catch (e) {
        print('General login error: $e');
        _showSnackBar('Something went wrong. Please try again.');
      } finally {
        _setLoading(false);
      }
    }
  }

  void _recoverAccount() {
    if (_emailController.text.trim().isEmpty) {
      _showSnackBar('Please enter your email first.', backgroundColor: Colors.orange);
      return;
    }

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VerificationScreen(email: _emailController.text.trim()),
      ),
    );
  }

  void _navigateToSignUp() {
    if (!mounted) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SignUpScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: Normalappbar(title: 'Login'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              const SizedBox(height: 40),

              // Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  hintText: 'Email',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email';
                  }
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                  if (!emailRegex.hasMatch(value.trim())) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey[600],
                    ),
                    onPressed: _isLoading ? null : () {
                      if (mounted) {
                        setState(() => _obscurePassword = !_obscurePassword);
                      }
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : const Text(
                          'Login',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Forgot Password Label
              const Text(
                'Forget Password?',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),

              // Recover Account Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _recoverAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    'Recover Account',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Sign Up Link
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? ",
                        style: TextStyle(color: Colors.black)),
                    GestureDetector(
                      onTap: _isLoading ? null : _navigateToSignUp,
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                            color: _isLoading ? Colors.grey : Colors.blue, 
                            fontWeight: FontWeight.w600),
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