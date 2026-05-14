/**
 * Student Numbers: [TO BE FILLED BY GROUP MEMBERS]
 * Student Names  : [TO BE FILLED BY GROUP MEMBERS]
 * Question: Login / Registration Screen
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/application_viewmodel.dart';
import '../../utils/route_manager.dart';
import '../../utils/app_theme.dart';
import '../../utils/shared_widgets.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _studentNumberController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLogin = true; // Toggle between Sign In and Sign Up

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _studentNumberController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    // 1. Validate all the individual text fields first
    if (!_formKey.currentState!.validate()) return;

    // 2. NEW: Cross-check the Student Number against the CUT Email during Registration
    if (!_isLogin) {
      // split('@').first takes "223040545@stud.cut.ac.za" and extracts just "223040545"
      final emailPrefix = _emailController.text.split('@').first;
      
      if (emailPrefix != _studentNumberController.text) {
        // Stop the submission and show a red error popup
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your Student Number must match your CUT email address!'),
            backgroundColor: Colors.red, // Or AppTheme.errorColor if you prefer
          ),
        );
        return; 
      }
    }

    // 3. If everything matches, proceed with the database logic
    final authVM = context.read<AuthViewModel>();
    final appVM = context.read<ApplicationViewModel>();

    bool success;
    
    // Branch logic based on whether we are logging in or registering
    if (_isLogin) {
      success = await authVM.signIn(
        _emailController.text,
        _passwordController.text,
      );
    } else {
      success = await authVM.signUp(
        _emailController.text,
        _passwordController.text,
        _fullNameController.text,
        _studentNumberController.text,
      );
    }

    if (success && mounted) {
      if (authVM.isAdmin) {
        Navigator.pushReplacementNamed(context, RouteManager.adminDashboard);
      } else {
        await appVM.fetchMyApplication(authVM.currentUser!.id);
        if (mounted) {
          Navigator.pushReplacementNamed(context, RouteManager.studentHome);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              _buildAuthCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white30, width: 2),
            ),
            child: const Icon(Icons.school_rounded, size: 42, color: Colors.white),
          ),
          const SizedBox(height: 20),
          const Text(
            'Student Assistant\nApplication System',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isLogin ? 'Sign In' : 'Create Account',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),

              // ─── Registration Only Fields ──────────────────────────────────
              if (!_isLogin) ...[
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) => 
                      value == null || value.isEmpty ? 'Full name is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _studentNumberController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Student Number',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Student number required';
                    if (!RegExp(r'^\d+$').hasMatch(value)) return 'Only numbers allowed';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

              // ─── Shared Fields (Email & Password) ──────────────────────────
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined),
                  hintText: 'e.g., 223999999@stud.cut.ac.za', // Added a helpful hint!
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Email is required';

                  if (!_isLogin) {
                    // REGISTRATION: Strictly enforce CUT Student Email format
                    // Must be exactly 9 numbers followed by @stud.cut.ac.za
                    if (!RegExp(r'^\d{9}@stud\.cut\.ac\.za$').hasMatch(value)) {
                      return 'Use a valid CUT student email';
                    }
                  } else {
                    // LOGIN: Standard email validation so Admins can still log in
                    if (!RegExp(r'^[\w.-]+@[\w.-]+\.\w+$').hasMatch(value)) {
                      return 'Enter a valid email address';
                    }
                  }
                  return null;
                },
              ),

              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Password is required';
                  if (value.length < 6) return 'Password must be at least 6 characters';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // ─── Error Message ─────────────────────────────────────────────
              Selector<AuthViewModel, String?>(
                selector: (_, vm) => vm.errorMessage,
                builder: (_, error, __) {
                  if (error == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ErrorMessage(
                      message: error,
                      onDismiss: () => context.read<AuthViewModel>().clearError(),
                    ),
                  );
                },
              ),

              // ─── Action Button ─────────────────────────────────────────────
              Selector<AuthViewModel, bool>(
                selector: (_, vm) => vm.isLoading,
                builder: (_, isLoading, __) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handleSubmit,
                      child: isLoading
                          ? const SizedBox(
                              height: 20, width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(_isLogin ? 'Sign In' : 'Register'),
                    ),
                  );
                },
              ),

              // ─── Toggle Login/Register Mode ────────────────────────────────
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                      context.read<AuthViewModel>().clearError();
                    });
                  },
                  child: Text(
                    _isLogin 
                        ? "Don't have an account? Sign Up" 
                        : "Already have an account? Sign In",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}