import 'dart:async';

import 'package:agribridge/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _ForgotPasswordStep { email, otp, resetPassword }

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  static const int _otpTimeoutSeconds = 120;

  final _emailFormKey = GlobalKey<FormState>();
  final _otpFormKey = GlobalKey<FormState>();
  final _resetPasswordFormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  _ForgotPasswordStep _currentStep = _ForgotPasswordStep.email;
  String _verifiedOtp = '';
  int _otpRemainingSeconds = 0;
  Timer? _otpTimer;

  bool _isSendingOtp = false;
  bool _isVerifyingOtp = false;
  bool _isResettingPassword = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  String _formatCountdown(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    final mm = minutes.toString().padLeft(2, '0');
    final ss = remainingSeconds.toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  void _startOtpCountdown() {
    _otpTimer?.cancel();

    if (!mounted) {
      return;
    }

    setState(() {
      _otpRemainingSeconds = _otpTimeoutSeconds;
    });

    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_otpRemainingSeconds <= 1) {
        timer.cancel();
        setState(() {
          _otpRemainingSeconds = 0;
        });
        return;
      }

      setState(() {
        _otpRemainingSeconds -= 1;
      });
    });
  }

  void _stopOtpCountdown() {
    _otpTimer?.cancel();
    _otpTimer = null;
  }

  @override
  void dispose() {
    _stopOtpCountdown();
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Please enter your email';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  String? _validateOtp(String? value) {
    final otp = value?.trim() ?? '';
    if (otp.isEmpty) {
      return 'Please enter OTP';
    }

    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
      return 'OTP must be 6 digits';
    }

    return null;
  }

  String? _validateNewPassword(String? value) {
    final password = value?.trim() ?? '';
    if (password.isEmpty) {
      return 'Please enter new password';
    }

    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    final confirmPassword = value?.trim() ?? '';
    if (confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }

    if (confirmPassword != _newPasswordController.text.trim()) {
      return 'Passwords do not match';
    }

    return null;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  Future<void> _sendOtp() async {
    final email = _emailController.text.trim();
    if (_emailFormKey.currentState != null) {
      if (!(_emailFormKey.currentState?.validate() ?? false)) {
        return;
      }
    } else {
      final emailError = _validateEmail(email);
      if (emailError != null) {
        _showError(emailError);
        return;
      }
    }

    setState(() {
      _isSendingOtp = true;
    });

    final error = await ref
        .read(authViewModelProvider.notifier)
        .sendForgotPasswordOtp(email: email);

    if (!mounted) {
      return;
    }

    setState(() {
      _isSendingOtp = false;
    });

    if (error != null && error.isNotEmpty) {
      _showError(error);
      return;
    }

    setState(() {
      _currentStep = _ForgotPasswordStep.otp;
      _otpController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      _verifiedOtp = '';
    });
    _startOtpCountdown();

    _showSuccess('OTP sent to your email');
  }

  Future<void> _verifyOtp() async {
    if (_otpRemainingSeconds == 0) {
      _showError('OTP expired. Please resend OTP.');
      return;
    }

    if (!(_otpFormKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isVerifyingOtp = true;
    });

    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();
    final error = await ref
        .read(authViewModelProvider.notifier)
        .verifyForgotPasswordOtp(email: email, otp: otp);

    if (!mounted) {
      return;
    }

    setState(() {
      _isVerifyingOtp = false;
    });

    if (error != null && error.isNotEmpty) {
      _showError(error);
      return;
    }

    setState(() {
      _currentStep = _ForgotPasswordStep.resetPassword;
      _verifiedOtp = otp;
    });
    _stopOtpCountdown();

    _showSuccess('OTP verified successfully');
  }

  Future<void> _resetPassword() async {
    if (!(_resetPasswordFormKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isResettingPassword = true;
    });

    final error = await ref
        .read(authViewModelProvider.notifier)
        .resetForgotPassword(
          email: _emailController.text.trim(),
          otp: _verifiedOtp,
          newPassword: _newPasswordController.text.trim(),
          confirmPassword: _confirmPasswordController.text.trim(),
        );

    if (!mounted) {
      return;
    }

    setState(() {
      _isResettingPassword = false;
    });

    if (error != null && error.isNotEmpty) {
      _showError(error);
      return;
    }

    _showSuccess('Password reset successfully. Please log in.');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StepIndicator(currentStep: _currentStep),
              const SizedBox(height: 18),
              if (_currentStep == _ForgotPasswordStep.email) _buildEmailStep(),
              if (_currentStep == _ForgotPasswordStep.otp) _buildOtpStep(),
              if (_currentStep == _ForgotPasswordStep.resetPassword)
                _buildResetPasswordStep(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailStep() {
    return Form(
      key: _emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enter your email address. We will send an OTP for verification.',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your email',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
            validator: _validateEmail,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSendingOtp ? null : _sendOtp,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _isSendingOtp
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Send OTP'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpStep() {
    final email = _emailController.text.trim();
    final isResending = _isSendingOtp;
    final isOtpExpired = _otpRemainingSeconds == 0;
    final countdownLabel = _formatCountdown(_otpRemainingSeconds);

    return Form(
      key: _otpFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'We sent a 6-digit OTP to $email',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          Text(
            isOtpExpired
                ? 'OTP expired. Please resend OTP.'
                : 'OTP expires in $countdownLabel',
            style: TextStyle(
              color: isOtpExpired ? Colors.red : Colors.orange.shade800,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            maxLength: 6,
            decoration: const InputDecoration(
              labelText: 'OTP',
              hintText: 'Enter 6-digit OTP',
              prefixIcon: Icon(Icons.verified_user_outlined),
              border: OutlineInputBorder(),
            ),
            validator: _validateOtp,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_isVerifyingOtp || isOtpExpired) ? null : _verifyOtp,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _isVerifyingOtp
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Verify OTP'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: (isResending || _isVerifyingOtp || !isOtpExpired)
                  ? null
                  : _sendOtp,
              child: isResending
                  ? const Text('Sending...')
                  : isOtpExpired
                  ? const Text('Resend OTP')
                  : Text('Resend OTP in $countdownLabel'),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: _isVerifyingOtp
                  ? null
                  : () {
                      _stopOtpCountdown();
                      setState(() {
                        _currentStep = _ForgotPasswordStep.email;
                      });
                    },
              child: const Text('Change Email'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetPasswordStep() {
    return Form(
      key: _resetPasswordFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Set a new password for your account.',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _newPasswordController,
            obscureText: _obscureNewPassword,
            decoration: InputDecoration(
              labelText: 'New Password',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscureNewPassword = !_obscureNewPassword;
                  });
                },
                icon: Icon(
                  _obscureNewPassword ? Icons.visibility : Icons.visibility_off,
                ),
              ),
            ),
            validator: _validateNewPassword,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock_reset),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
              ),
            ),
            validator: _validateConfirmPassword,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isResettingPassword ? null : _resetPassword,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _isResettingPassword
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Reset Password'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final _ForgotPasswordStep currentStep;

  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StepChip(
            label: '1. Email',
            isActive: currentStep == _ForgotPasswordStep.email,
            isCompleted: currentStep != _ForgotPasswordStep.email,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StepChip(
            label: '2. OTP',
            isActive: currentStep == _ForgotPasswordStep.otp,
            isCompleted: currentStep == _ForgotPasswordStep.resetPassword,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StepChip(
            label: '3. Password',
            isActive: currentStep == _ForgotPasswordStep.resetPassword,
            isCompleted: false,
          ),
        ),
      ],
    );
  }
}

class _StepChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isCompleted;

  const _StepChip({
    required this.label,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = isActive
        ? theme.colorScheme.primary.withValues(alpha: 0.15)
        : (isCompleted
              ? Colors.green.withValues(alpha: 0.15)
              : Colors.grey[200]);
    final textColor = isActive
        ? theme.colorScheme.primary
        : (isCompleted ? Colors.green[700] : Colors.grey[700]);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
