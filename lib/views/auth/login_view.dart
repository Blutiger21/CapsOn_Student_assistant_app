import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/route_manager.dart';
import '../../viewmodels/auth_viewmodel.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _fullNameController = TextEditingController();
  final _studentNumberController = TextEditingController();

  final _formKeyLogin = GlobalKey<FormState>();
  final _formKeySignup = GlobalKey<FormState>();

  bool _isLogin = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _studentNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Login' : 'Sign up'),
      ),
      body: SafeArea(
        child: Consumer<AuthViewModel>(
          builder: (context, auth, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (auth.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              auth.errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                          IconButton(
                            onPressed: auth.clearError,
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  ToggleButtons(
                    isSelected: [_isLogin, !_isLogin],
                    onPressed: (index) {
                      auth.clearError();
                      setState(() {
                        _isLogin = index == 0;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Login'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Sign up'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  if (_isLogin)
                    Form(
                      key: _formKeyLogin,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Email is required'
                                    : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) =>
                                (v == null || v.isEmpty)
                                    ? 'Password is required'
                                    : null,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: auth.isLoading
                                  ? null
                                  : () async {
                                      auth.clearError();
                                      if (!(_formKeyLogin.currentState?.validate() ??
                                          false)) return;

                                      final ok = await auth.signIn(
                                        _emailController.text,
                                        _passwordController.text,
                                      );

                                      if (!mounted) return;
                                      if (ok) {
                                        final nextRoute =
                                            auth.isAdmin
                                                ? RouteManager.adminDashboard
                                                : RouteManager.studentHome;
                                        if (!mounted) return;
                                        Navigator.of(context).pushNamed(nextRoute);
                                      }
                                    },
                              child: auth.isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Login'),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Form(
                      key: _formKeySignup,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _fullNameController,
                            decoration: const InputDecoration(
                              labelText: 'Full name',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Full name is required'
                                    : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _studentNumberController,
                            decoration: const InputDecoration(
                              labelText: 'Student number',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Student number is required'
                                    : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Email is required'
                                    : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) =>
                                (v == null || v.isEmpty)
                                    ? 'Password is required'
                                    : null,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: auth.isLoading
                                  ? null
                                  : () async {
                                      auth.clearError();
                                      if (!(_formKeySignup.currentState?.validate() ??
                                          false)) return;

                                      final ok = await auth.signUp(
                                        _emailController.text,
                                        _passwordController.text,
                                        _fullNameController.text,
                                        _studentNumberController.text,
                                      );

                                      if (!mounted) return;
                                      if (ok) {
                                        Navigator.of(context).pushNamed(
                                          auth.isAdmin
                                              ? RouteManager.adminDashboard
                                              : RouteManager.studentHome,
                                        );
                                      }
                                    },
                              child: auth.isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Create account'),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

