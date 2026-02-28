import 'package:agribridge/features/dashboard/presentation/pages/button_navigation.dart';
import 'package:agribridge/features/dashboard/presentation/state/cart_provider.dart';
import 'package:agribridge/core/services/security/biometric_auth_service.dart';
import 'package:agribridge/core/services/storage/user_session_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agribridge/app/routes/app_routes.dart';
import 'package:agribridge/features/auth/presentation/pages/forgot_password_screen.dart';
import 'package:agribridge/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:agribridge/features/auth/presentation/pages/register_screen.dart';
import 'package:agribridge/features/auth/presentation/state/auth_state.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // form key and controllers
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _canUseFingerprintLogin = false;
  bool _isCheckingFingerprint = true;
  bool _isFingerprintLoginInProgress = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricLoginAvailability();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      await ref
          .read(authViewModelProvider.notifier)
          .login(_emailController.text.trim(), _passwordController.text);
    }
  }

  Future<void> _loadBiometricLoginAvailability() async {
    final userSessionService = ref.read(userSessionServiceProvider);
    final biometricAuthService = ref.read(biometricAuthServiceProvider);

    final isEnabled = userSessionService.isBiometricLoginEnabled();
    bool canUseFingerprintLogin = false;

    if (isEnabled) {
      final isSupported = await biometricAuthService.canUseBiometricLogin();
      final hasCredentials = await userSessionService.hasBiometricCredentials();

      if (!hasCredentials) {
        await userSessionService.setBiometricLoginEnabled(false);
      }

      canUseFingerprintLogin = isSupported && hasCredentials;
    }

    if (!mounted) return;
    setState(() {
      _canUseFingerprintLogin = canUseFingerprintLogin;
      _isCheckingFingerprint = false;
    });
  }

  Future<void> _handleFingerprintLogin() async {
    if (_isFingerprintLoginInProgress || _isCheckingFingerprint) {
      return;
    }

    if (ref.read(authViewModelProvider).status == AuthStatus.loading) {
      return;
    }

    setState(() {
      _isFingerprintLoginInProgress = true;
    });

    final userSessionService = ref.read(userSessionServiceProvider);
    final biometricAuthService = ref.read(biometricAuthServiceProvider);

    try {
      final isAuthenticated = await biometricAuthService.authenticate(
        reason: 'Scan your fingerprint to login',
      );

      if (!isAuthenticated) {
        return;
      }

      final credentials = await userSessionService.getBiometricCredentials();
      if (credentials == null) {
        await userSessionService.clearBiometricLoginSetup();
        if (!mounted) return;
        setState(() {
          _canUseFingerprintLogin = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Saved fingerprint login is unavailable. Please login manually and enable it again.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      _emailController.text = credentials.email;

      await ref
          .read(authViewModelProvider.notifier)
          .login(credentials.email, credentials.password);

      final latestAuthState = ref.read(authViewModelProvider);
      if (latestAuthState.status == AuthStatus.error) {
        final message = (latestAuthState.errorMessage ?? '').toLowerCase();
        if (message.contains('invalid email or password') ||
            message.contains('user not found')) {
          await userSessionService.clearBiometricLoginSetup();
          if (!mounted) return;
          setState(() {
            _canUseFingerprintLogin = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Saved fingerprint login expired. Please login manually and enable it again.',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFingerprintLoginInProgress = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    // Listen to auth state changes
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        ref.read(cartProvider.notifier).loadCartForCurrentUser();
        AppRoutes.pushAndRemoveUntil(context, const ButtonNavigation());
      } else if (next.status == AuthStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? 'Login failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color.fromARGB(255, 131, 223, 134),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 120),
              Image.asset('assets/images/agri_logo.png', height: 160),
              const SizedBox(height: 10),
              Text(
                "AgriBridge",
                style: GoogleFonts.poppins(fontSize: 32, color: Colors.black),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      AppRoutes.pushReplacement(
                        context,
                        const RegisterScreen(),
                      );
                    },
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  const SizedBox(width: 25),
                  Column(
                    children: [
                      const Text(
                        "Log In",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Container(
                        height: 2,
                        width: 60,
                        margin: const EdgeInsets.only(top: 4),
                        color: Colors.blueAccent,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          hintText: "Enter your email",
                          prefixIcon: Icon(Icons.email),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(14)),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email';
                          }
                          // Proper email regex validation
                          final emailRegex = RegExp(
                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                          );
                          if (!emailRegex.hasMatch(value.trim())) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: "Password",
                          hintText: "Enter your password",
                          prefixIcon: const Icon(Icons.lock),
                          filled: true,
                          fillColor: Colors.white,
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(14)),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 2),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            AppRoutes.push(
                              context,
                              const ForgotPasswordScreen(),
                            );
                          },
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: authState.status == AuthStatus.loading
                              ? null
                              : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: const Color(0xFF2E8B3C),
                            disabledBackgroundColor: const Color(0xFF2E8B3C),
                            foregroundColor: Colors.white,
                            disabledForegroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            surfaceTintColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: authState.status == AuthStatus.loading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Log In",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      if (_canUseFingerprintLogin) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            onPressed:
                                (authState.status == AuthStatus.loading ||
                                    _isFingerprintLoginInProgress)
                                ? null
                                : _handleFingerprintLogin,
                            icon: _isFingerprintLoginInProgress
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.fingerprint_rounded),
                            label: const Text(
                              'Tap to Login with Fingerprint',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF0D5C2D),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: TextStyle(fontSize: 14),
                          ),
                          GestureDetector(
                            onTap: () {
                              AppRoutes.push(context, const RegisterScreen());
                            },
                            child: const Text(
                              "Sign up",
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
