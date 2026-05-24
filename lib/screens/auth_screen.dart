import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../viewmodels/auth_viewmodel.dart';

class AuthScreen extends StatefulWidget {
  final AuthViewModel authVM;
  const AuthScreen({super.key, required this.authVM});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLogin = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_isLogin) {
      widget.authVM.login(_emailCtrl.text.trim(), _passCtrl.text.trim());
    } else {
      widget.authVM.register(_emailCtrl.text.trim(), _passCtrl.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                child: ListenableBuilder(
                  listenable: widget.authVM,
                  builder: (context, _) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // App Logo or Icon
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            'FINA',
                            style: TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -3.5,
                              color: Theme.of(context).colorScheme.primary,
                              height: 1.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Welcome Text
                        Text(
                          _isLogin ? 'Welcome back' : 'Create an account',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isLogin 
                              ? 'Enter your details to access your account.' 
                              : 'Join Fina to take control of your finances.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),

                        // Error Message
                        if (widget.authVM.error != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(CupertinoIcons.exclamationmark_triangle_fill, color: Theme.of(context).colorScheme.error, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    widget.authVM.error!,
                                    style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Input Fields
                        TextField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: 'Email',
                            prefixIcon: const Icon(CupertinoIcons.mail),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passCtrl,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _submit(),
                          decoration: InputDecoration(
                            hintText: 'Password',
                            prefixIcon: const Icon(CupertinoIcons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Submit Button
                        FilledButton(
                          onPressed: widget.authVM.isLoading ? null : _submit,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: widget.authVM.isLoading
                              ? const SizedBox(
                                  height: 24, 
                                  width: 24, 
                                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)
                                )
                              : Text(
                                  _isLogin ? 'Sign In' : 'Create Account',
                                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                                ),
                        ),
                        const SizedBox(height: 24),

                        // Divider
                        Row(
                          children: [
                            Expanded(child: Divider(color: Theme.of(context).colorScheme.outlineVariant)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                'OR',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: Theme.of(context).colorScheme.outlineVariant)),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Google Sign In Button
                        OutlinedButton(
                          onPressed: widget.authVM.isLoading ? null : widget.authVM.signInWithGoogle,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                          ),
                          child: const Text(
                            'Continue with Google',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Toggle Mode
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isLogin ? "Don't have an account? " : "Already have an account? ",
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                  widget.authVM.error = null; // Clear error on toggle
                                });
                              },
                              child: Text(
                                _isLogin ? 'Register' : 'Sign In',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
