import 'package:agribridge/core/api/api_client.dart';
import 'package:agribridge/core/api/api_endpoint.dart';
import 'package:agribridge/core/services/storage/user_session_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final RegExp _phoneRegex = RegExp(r'^\d{10}$');

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isSaving = false;
  String _username = '';

  @override
  void initState() {
    super.initState();
    final userSessionService = ref.read(userSessionServiceProvider);
    _nameController.text = userSessionService.getCurrentUserFullName() ?? '';
    _emailController.text = userSessionService.getCurrentUserEmail() ?? '';
    _phoneController.text =
        userSessionService.getCurrentUserPhoneNumber() ?? '';
    _addressController.text = userSessionService.getCurrentUserAddress() ?? '';
    _username = userSessionService.getCurrentUserUsername() ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  String _safeString(dynamic value) {
    if (value is String) {
      return value.trim();
    }
    return '';
  }

  void _showMessage(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade700,
        content: Text(message),
      ),
    );
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _isSaving = true;
    });

    final userSessionService = ref.read(userSessionServiceProvider);
    final customerId = userSessionService.getCurrentUserId();
    if (customerId == null || customerId.trim().isEmpty) {
      setState(() {
        _isSaving = false;
      });
      _showMessage('Unable to find current user session.', isError: true);
      return;
    }

    final trimmedName = _nameController.text.trim();
    final trimmedEmail = _emailController.text.trim();
    final trimmedPhone = _phoneController.text.trim();
    final trimmedAddress = _addressController.text.trim();

    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.put(
        ApiEndpoints.profileById(customerId),
        data: {
          'name': trimmedName,
          'email': trimmedEmail,
          'phone': trimmedPhone,
          'address': trimmedAddress,
        },
      );

      if (response.statusCode != 200 ||
          response.data is! Map<String, dynamic>) {
        _showMessage(
          'Failed to update profile. Please try again.',
          isError: true,
        );
        return;
      }

      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'];
      if (data is! Map<String, dynamic>) {
        _showMessage('Failed to read profile update response.', isError: true);
        return;
      }

      final nameFromApi = _safeString(data['name']);
      final emailFromApi = _safeString(data['email']);
      final phoneFromApi = _safeString(data['phone']);
      final addressFromApi = _safeString(data['address']);
      final imageFromApi = _safeString(data['image']);

      final updatedName = nameFromApi.isNotEmpty ? nameFromApi : trimmedName;
      final updatedEmail = emailFromApi.isNotEmpty
          ? emailFromApi
          : trimmedEmail;
      final updatedPhone = phoneFromApi.isNotEmpty
          ? phoneFromApi
          : trimmedPhone;
      final updatedAddress = addressFromApi.isNotEmpty
          ? addressFromApi
          : trimmedAddress;

      await userSessionService.setCurrentUserFullName(updatedName);
      await userSessionService.setCurrentUserEmail(updatedEmail);
      await userSessionService.setCurrentUserPhoneNumber(updatedPhone);
      await userSessionService.setCurrentUserAddress(updatedAddress);

      if (imageFromApi.isNotEmpty) {
        await userSessionService.setCurrentUserProfilePicture(imageFromApi);
      }

      _showMessage('Profile updated successfully.', isError: false);
      if (!mounted) return;
      Navigator.pop(context, true);
    } on DioException catch (e) {
      final responseMessage = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message'] as String?)
          : null;

      if (e.response?.statusCode == 409) {
        _showMessage(responseMessage ?? 'Email already exists.', isError: true);
        return;
      }
      if (e.response?.statusCode == 400) {
        _showMessage(responseMessage ?? 'Invalid profile data.', isError: true);
        return;
      }
      if (e.response?.statusCode == 401) {
        _showMessage('Session expired. Please login again.', isError: true);
        return;
      }
      _showMessage(responseMessage ?? 'Profile update failed.', isError: true);
    } catch (_) {
      _showMessage('Profile update failed.', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  InputDecoration _fieldDecoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF2E7D32)),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.green.shade100),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F8F2),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E2A22),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 14,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        initialValue: _username,
                        readOnly: true,
                        decoration: _fieldDecoration(
                          label: 'Username',
                          icon: Icons.alternate_email_rounded,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _nameController,
                        textInputAction: TextInputAction.next,
                        decoration: _fieldDecoration(
                          label: 'Name',
                          icon: Icons.person_outline_rounded,
                        ),
                        validator: (value) {
                          if ((value ?? '').trim().isEmpty) {
                            return 'Name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: _fieldDecoration(
                          label: 'Email',
                          icon: Icons.email_outlined,
                        ),
                        validator: (value) {
                          final trimmed = (value ?? '').trim();
                          if (trimmed.isEmpty) {
                            return 'Email is required';
                          }
                          if (!_emailRegex.hasMatch(trimmed)) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        decoration: _fieldDecoration(
                          label: 'Phone',
                          icon: Icons.phone_outlined,
                          hint: '10-digit phone number',
                        ),
                        validator: (value) {
                          final trimmed = (value ?? '').trim();
                          if (trimmed.isEmpty) {
                            return 'Phone is required';
                          }
                          if (!_phoneRegex.hasMatch(trimmed)) {
                            return 'Phone must be exactly 10 digits';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _addressController,
                        keyboardType: TextInputType.streetAddress,
                        textInputAction: TextInputAction.done,
                        minLines: 1,
                        maxLines: 2,
                        decoration: _fieldDecoration(
                          label: 'Address',
                          icon: Icons.location_on_outlined,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.green.shade300,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
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
