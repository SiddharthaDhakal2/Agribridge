import 'dart:io';
import '../state/profile_provider.dart';
import '../state/cart_provider.dart';
import 'package:agribridge/core/api/api_endpoint.dart';
import 'package:agribridge/core/services/storage/user_session_service.dart';
import 'package:agribridge/features/auth/presentation/pages/login_screen.dart';
import 'package:agribridge/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:agribridge/features/dashboard/presentation/pages/edit_profile_screen.dart';
import 'package:agribridge/features/dashboard/presentation/pages/security_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  File? _profileImage;
  String? _remoteProfileImageUrl;

  bool _isRemoteImagePath(String? path) {
    if (path == null) return false;
    final trimmed = path.trim().replaceAll('\\', '/');
    if (trimmed.isEmpty) return false;
    return trimmed.startsWith('http://') ||
        trimmed.startsWith('https://') ||
        trimmed.startsWith('/uploads/') ||
        trimmed.startsWith('uploads/') ||
        trimmed.contains('/uploads/');
  }

  String _initial(String userName) {
    if (userName.isEmpty) return 'U';
    return userName[0].toUpperCase();
  }

  Widget _buildAvatarText(String userName) {
    return Text(
      _initial(userName),
      style: const TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: Colors.green,
      ),
    );
  }

  Widget _buildProfileAvatar(String userName, String? remoteImageUrl) {
    if (_profileImage != null) {
      return CircleAvatar(
        radius: 60,
        backgroundColor: Colors.white,
        backgroundImage: FileImage(_profileImage!),
      );
    }

    if (remoteImageUrl != null && remoteImageUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 60,
        backgroundColor: Colors.white,
        child: ClipOval(
          child: Image.network(
            remoteImageUrl,
            width: 120,
            height: 120,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Center(child: _buildAvatarText(userName)),
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: 60,
      backgroundColor: Colors.white,
      child: _buildAvatarText(userName),
    );
  }

  // permission
  Future<bool> _requestPermission(Permission permission) async {
    final status = await permission.request();

    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog();
    }
    return false;
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Permission Required"),
        content: const Text(
          "This feature requires permission to access your camera or gallery. "
          "Please enable it in your device settings.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  Future<void> _savePickedImage(XFile image) async {
    setState(() {
      _profileImage = File(image.path);
    });

    final userSessionService = ref.read(userSessionServiceProvider);
    final customerId = userSessionService.getCurrentUserId();
    if (customerId == null) return;

    await ref
        .read(profileViewModelProvider.notifier)
        .saveProfileImage(image.path, customerId);

    final uploadedPath = ref.read(profileViewModelProvider).profile?.imagePath;
    if (uploadedPath == null || uploadedPath.trim().isEmpty) return;

    await userSessionService.setCurrentUserProfilePicture(uploadedPath);

    if (!mounted) return;
    setState(() {
      _remoteProfileImageUrl = ApiEndpoints.resolveMediaUrl(uploadedPath);
      _profileImage = null;
    });
  }

  // image picker
  Future<void> _pickFromCamera() async {
    if (!await _requestPermission(Permission.camera)) return;

    final XFile? photo = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (photo != null) {
      await _savePickedImage(photo);
    }
  }

  Future<void> _pickFromGallery() async {
    if (!await _requestPermission(Permission.photos)) return;

    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      await _savePickedImage(image);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final userSessionService = ref.read(userSessionServiceProvider);
    final sessionImagePath = userSessionService.getCurrentUserProfilePicture();
    final String? customerId = userSessionService.getCurrentUserId();

    String? imagePath = sessionImagePath;

    if (customerId != null) {
      await ref.read(profileViewModelProvider.notifier).loadProfile();
      final profile = ref.read(profileViewModelProvider).profile;
      final profileImagePath = profile?.imagePath;
      if (_isRemoteImagePath(profileImagePath)) {
        imagePath = profileImagePath;
      }
    }

    if (!_isRemoteImagePath(imagePath)) return;
    final resolvedImagePath = imagePath!;

    if (!mounted) return;

    await userSessionService.setCurrentUserProfilePicture(resolvedImagePath);

    if (!mounted) return;
    setState(() {
      _remoteProfileImageUrl = ApiEndpoints.resolveMediaUrl(resolvedImagePath);
      _profileImage = null;
    });
  }

  // Future<void> _pickVideo() async {
  //   if (!await _requestPermission(Permission.camera)) return;

  //   final XFile? video = await _imagePicker.pickVideo(
  //     source: ImageSource.camera,
  //     maxDuration: const Duration(minutes: 1),
  //   );

  //   if (video != null) {
  //     setState(() {
  //       _profileImage = File(video.path);
  //     });
  //   }
  // }

  // bottom sheet
  void _showMediaPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
              onTap: () {
                Navigator.pop(context);
                _pickFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text("Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
            ),
            // ListTile(
            //   leading: const Icon(Icons.videocam),
            //   title: const Text("Video"),
            //   onTap: () {
            //     Navigator.pop(context);
            //     _pickVideo();
            //   },
            // ),
          ],
        ),
      ),
    );
  }

  Future<void> _openEditProfilePage() async {
    final isUpdated = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const EditProfileScreen()));

    if (!mounted) return;
    if (isUpdated == true) {
      await _loadProfileImage();
      setState(() {});
    }
  }

  Future<void> _openSecurityPage() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SecurityScreen()));
  }

  // UI
  @override
  Widget build(BuildContext context) {
    final userSessionService = ref.watch(userSessionServiceProvider);
    final authState = ref.watch(authViewModelProvider);
    final userName = userSessionService.getCurrentUserFullName() ?? 'User';
    final userEmail = userSessionService.getCurrentUserEmail() ?? '';
    final sessionImagePath = userSessionService.getCurrentUserProfilePicture();
    final authImagePath = authState.authEntity?.profilePicture;
    final profileImageUrl =
        (_remoteProfileImageUrl != null && _remoteProfileImageUrl!.isNotEmpty)
        ? _remoteProfileImageUrl
        : (_isRemoteImagePath(authImagePath)
              ? ApiEndpoints.resolveMediaUrl(authImagePath!)
              : (_isRemoteImagePath(sessionImagePath)
                    ? ApiEndpoints.resolveMediaUrl(sessionImagePath!)
                    : null));

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.green.shade800],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    const Text(
                      'My Profile',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // profile image
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          _buildProfileAvatar(userName, profileImageUrl),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _showMediaPicker,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.green,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 20,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      userEmail,
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Menu
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _MenuItem(
                      icon: Icons.person_outline_rounded,
                      title: 'Edit Profile',
                      onTap: _openEditProfilePage,
                    ),
                    const SizedBox(height: 12),
                    _MenuItem(
                      icon: Icons.security_rounded,
                      title: 'Privacy & Security',
                      onTap: _openSecurityPage,
                    ),
                    const SizedBox(height: 12),
                    _MenuItem(
                      icon: Icons.help_outline_rounded,
                      title: 'Help & Support',
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    _MenuItem(
                      icon: Icons.info_outline_rounded,
                      title: 'About',
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    _MenuItem(
                      icon: Icons.logout_rounded,
                      title: 'Logout',
                      iconColor: Colors.red,
                      titleColor: Colors.red,
                      onTap: () => _showLogoutDialog(context),
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

  // Logout
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await ref.read(userSessionServiceProvider).clearSession();
              ref.read(cartProvider.notifier).clear();
              ref.read(authViewModelProvider.notifier).logout();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// Menu Item
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? titleColor;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: (iconColor ?? Colors.lime).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor ?? Colors.black, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? Colors.lightGreen,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.lightGreen,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
