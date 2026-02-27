import 'package:agribridge/core/services/storage/user_session_service.dart';
import 'package:agribridge/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  void _showChangePasswordSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ChangePasswordSheet(),
    );
  }

  Future<void> _showDeleteAccountFlow() async {
    final shouldContinue = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFB3261E)),
            SizedBox(width: 8),
            Text('Delete Account'),
          ],
        ),
        content: const Text(
          'This action is permanent. To protect your account, we need one more confirmation.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB3261E),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (shouldContinue != true || !mounted) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const _DeleteAccountConfirmDialog(),
    );

    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Delete account is not connected yet. Link this action to your backend.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final titleColor = isDarkMode ? Colors.white : const Color(0xFF13361A);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: IconButton.styleFrom(
                      backgroundColor: isDarkMode
                          ? theme.colorScheme.surface
                          : Colors.white,
                      foregroundColor: isDarkMode
                          ? const Color(0xFF81C784)
                          : const Color(0xFF1B5E20),
                    ),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Privacy & Security',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _SecurityActionCard(
                icon: Icons.lock_reset_rounded,
                title: 'Change Password',
                subtitle:
                    'Create a stronger password to keep your account secure.',
                accent: const Color(0xFF1E8E5A),
                onTap: _showChangePasswordSheet,
              ),
              const SizedBox(height: 14),
              _SecurityActionCard(
                icon: Icons.delete_forever_rounded,
                title: 'Delete Account',
                subtitle:
                    'Permanently remove your account and all associated data.',
                accent: const Color(0xFFB3261E),
                danger: true,
                onTap: _showDeleteAccountFlow,
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? const Color(0xFF242B28)
                      : const Color(0xFFE8F4ED),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDarkMode ? Colors.white12 : Colors.transparent,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: isDarkMode
                          ? const Color(0xFF81C784)
                          : const Color(0xFF2E7D32),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'For sensitive actions, you may be asked to verify your credentials again.',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDarkMode
                              ? Colors.white70
                              : const Color(0xFF245C2F),
                          height: 1.35,
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

class _SecurityActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final bool danger;
  final VoidCallback onTap;

  const _SecurityActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            color: isDarkMode ? theme.colorScheme.surface : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: danger
                ? Border.all(
                    color: isDarkMode
                        ? const Color(0xFF6B3532)
                        : const Color(0xFFF6D3D2),
                    width: 1,
                  )
                : Border.all(
                    color: isDarkMode ? Colors.white10 : Colors.transparent,
                  ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDarkMode ? 0.22 : 0.05),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accent, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: danger
                            ? const Color(0xFFB93A31)
                            : (isDarkMode
                                  ? Colors.white
                                  : const Color(0xFF193B24)),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: isDarkMode
                            ? Colors.white70
                            : const Color(0xFF607166),
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: accent),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChangePasswordSheet extends ConsumerStatefulWidget {
  const _ChangePasswordSheet();

  @override
  ConsumerState<_ChangePasswordSheet> createState() =>
      _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends ConsumerState<_ChangePasswordSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _currentController = TextEditingController();
  final TextEditingController _newController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _hasTriedSubmit = false;
  bool _isSubmitting = false;
  String? _currentPasswordServerError;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _validateCurrentPassword(String? value) {
    final current = value?.trim() ?? '';
    final next = _newController.text.trim();
    final confirm = _confirmController.text.trim();

    if (current.isEmpty) {
      return 'Please enter current password.';
    }

    if (current.length < 6) {
      return 'Password must be at least 6 characters.';
    }

    if (next.isNotEmpty && current == next) {
      return 'Current password cannot match new password.';
    }

    if (confirm.isNotEmpty && current == confirm) {
      return 'Current password cannot match confirm password.';
    }

    if (_currentPasswordServerError != null &&
        _currentPasswordServerError!.trim().isNotEmpty) {
      return _currentPasswordServerError;
    }

    return null;
  }

  String? _validateNewPassword(String? value) {
    final current = _currentController.text.trim();
    final next = value?.trim() ?? '';

    if (next.isEmpty) {
      return 'Please enter new password.';
    }

    if (next.length < 6) {
      return 'Password must be at least 6 characters.';
    }

    if (current.isNotEmpty && current == next) {
      return 'New password cannot match current password.';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    final current = _currentController.text.trim();
    final next = _newController.text.trim();
    final confirm = value?.trim() ?? '';

    if (confirm.isEmpty) {
      return 'Please confirm new password.';
    }

    if (confirm.length < 6) {
      return 'Password must be at least 6 characters.';
    }

    if (current.isNotEmpty && current == confirm) {
      return 'Confirm password cannot match current password.';
    }

    if (next.isNotEmpty && next != confirm) {
      return 'New and confirm password must match.';
    }

    return null;
  }

  void _onPasswordChanged(String _) {
    if (_hasTriedSubmit) {
      _formKey.currentState?.validate();
    }
  }

  void _onCurrentPasswordChanged(String value) {
    if (_currentPasswordServerError != null) {
      setState(() {
        _currentPasswordServerError = null;
      });
    }
    _onPasswordChanged(value);
  }

  Future<void> _submit() async {
    if (!_hasTriedSubmit) {
      setState(() {
        _hasTriedSubmit = true;
      });
    }

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    final userId = ref.read(userSessionServiceProvider).getCurrentUserId();
    if (userId == null || userId.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User session not found. Please login again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final current = _currentController.text.trim();
    final next = _newController.text.trim();

    setState(() {
      _isSubmitting = true;
      _currentPasswordServerError = null;
    });

    try {
      final errorMessage = await ref
          .read(authViewModelProvider.notifier)
          .changePassword(
            userId: userId,
            currentPassword: current,
            newPassword: next,
          );

      if (!mounted) return;

      if (errorMessage != null && errorMessage.trim().isNotEmpty) {
        var message = errorMessage;
        if (message.startsWith('Exception: ')) {
          message = message.substring('Exception: '.length);
        }

        if (message.toLowerCase().contains('current password')) {
          setState(() {
            _currentPasswordServerError = "Current password doesn't match.";
          });
          _formKey.currentState?.validate();
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
        );
        return;
      }

      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF2A2F2B)
              : const Color(0xFFF1F8E9),
          content: Text(
            'Password updated successfully',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFFE8ECE9)
                  : const Color(0xFF2E6E49),
              fontWeight: FontWeight.w600,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final sheetColor = isDarkMode ? theme.colorScheme.surface : Colors.white;
    final titleColor = isDarkMode ? Colors.white : const Color(0xFF193B24);
    final subtitleColor = isDarkMode ? Colors.white70 : const Color(0xFF6A7B70);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: sheetColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: isDarkMode ? Colors.white12 : Colors.transparent,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Form(
            key: _formKey,
            autovalidateMode: _hasTriedSubmit
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 46,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.white24 : const Color(0xFFD9E2D9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Change Password',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Use a strong password with letters, numbers, and symbols.',
                  style: TextStyle(color: subtitleColor, fontSize: 13),
                ),
                const SizedBox(height: 16),
                _PasswordInput(
                  controller: _currentController,
                  label: 'Current Password',
                  obscureText: _obscureCurrent,
                  validator: _validateCurrentPassword,
                  onChanged: _onCurrentPasswordChanged,
                  onToggleVisibility: () {
                    setState(() {
                      _obscureCurrent = !_obscureCurrent;
                    });
                  },
                ),
                const SizedBox(height: 12),
                _PasswordInput(
                  controller: _newController,
                  label: 'New Password',
                  obscureText: _obscureNew,
                  validator: _validateNewPassword,
                  onChanged: _onPasswordChanged,
                  onToggleVisibility: () {
                    setState(() {
                      _obscureNew = !_obscureNew;
                    });
                  },
                ),
                const SizedBox(height: 12),
                _PasswordInput(
                  controller: _confirmController,
                  label: 'Confirm Password',
                  obscureText: _obscureConfirm,
                  validator: _validateConfirmPassword,
                  onChanged: _onPasswordChanged,
                  onToggleVisibility: () {
                    setState(() {
                      _obscureConfirm = !_obscureConfirm;
                    });
                  },
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: isDarkMode
                          ? const Color(0xFF81C784)
                          : const Color(0xFF1E8E5A),
                      foregroundColor: isDarkMode
                          ? const Color(0xFF0F1412)
                          : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isDarkMode
                                    ? const Color(0xFF0F1412)
                                    : Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Update Password',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PasswordInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final VoidCallback onToggleVisibility;

  const _PasswordInput({
    required this.controller,
    required this.label,
    required this.obscureText,
    this.validator,
    this.onChanged,
    required this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      validator: validator,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDarkMode ? Colors.white70 : const Color(0xFF5D7062),
        ),
        filled: true,
        fillColor: isDarkMode ? const Color(0xFF242B28) : const Color(0xFFF3F7F3),
        suffixIcon: IconButton(
          onPressed: onToggleVisibility,
          icon: Icon(
            obscureText
                ? Icons.visibility_off_rounded
                : Icons.visibility_rounded,
            color: isDarkMode ? Colors.white70 : const Color(0xFF4F6255),
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.white24 : Colors.transparent,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.white24 : Colors.transparent,
          ),
        ),
      ),
    );
  }
}

class _DeleteAccountConfirmDialog extends StatefulWidget {
  const _DeleteAccountConfirmDialog();

  @override
  State<_DeleteAccountConfirmDialog> createState() =>
      _DeleteAccountConfirmDialogState();
}

class _DeleteAccountConfirmDialogState
    extends State<_DeleteAccountConfirmDialog> {
  final TextEditingController _confirmController = TextEditingController();

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canDelete = _confirmController.text.trim().toUpperCase() == 'DELETE';
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Text('Final Confirmation'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Type DELETE to confirm account deletion.',
            style: TextStyle(height: 1.4),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _confirmController,
            onChanged: (_) => setState(() {}),
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'DELETE',
              filled: true,
              fillColor: isDarkMode
                  ? const Color(0xFF3A2424)
                  : const Color(0xFFFBEAEA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFB3261E),
          ),
          onPressed: canDelete ? () => Navigator.pop(context, true) : null,
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
