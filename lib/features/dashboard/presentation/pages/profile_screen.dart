import 'dart:io';
import '../state/profile_provider.dart';
import '../state/cart_provider.dart';
import 'package:agribridge/core/api/api_endpoint.dart';
import 'package:agribridge/core/services/storage/user_session_service.dart';
import 'package:agribridge/app/theme/theme_provider.dart';
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

  Widget _buildAvatarText(String userName, {required Color color}) {
    return Text(
      _initial(userName),
      style: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }

  Widget _buildProfileAvatar(
    String userName,
    String? remoteImageUrl, {
    required Color avatarBackgroundColor,
    required Color avatarInitialColor,
  }) {
    if (_profileImage != null) {
      return CircleAvatar(
        radius: 60,
        backgroundColor: avatarBackgroundColor,
        backgroundImage: FileImage(_profileImage!),
      );
    }

    if (remoteImageUrl != null && remoteImageUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 60,
        backgroundColor: avatarBackgroundColor,
        child: ClipOval(
          child: Image.network(
            remoteImageUrl,
            width: 120,
            height: 120,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Center(
                  child: _buildAvatarText(
                    userName,
                    color: avatarInitialColor,
                  ),
                ),
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: 60,
      backgroundColor: avatarBackgroundColor,
      child: _buildAvatarText(userName, color: avatarInitialColor),
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
    final themeMode = ref.watch(themeModeProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = themeMode == ThemeMode.dark;
    final headerGradientColors = isDarkMode
        ? const [Color(0xFF1F6B47), Color(0xFF0A261C)]
        : [Colors.green.shade400, Colors.green.shade800];
    final userNameColor = Colors.white;
    final userEmailColor = isDarkMode
        ? Colors.white70
        : Colors.white.withValues(alpha: 0.95);
    final profileAvatarBackgroundColor = isDarkMode
        ? const Color(0xFF223129)
        : Colors.white;
    final profileAvatarInitialColor = isDarkMode
        ? Colors.greenAccent.shade100
        : Colors.green;
    final avatarBorderColor = isDarkMode ? Colors.white70 : Colors.white;
    final avatarShadowColor = isDarkMode ? Colors.black54 : Colors.black26;
    final cameraBadgeBackground = isDarkMode ? colorScheme.surface : Colors.white;
    final cameraBadgeBorder = isDarkMode
        ? Colors.greenAccent.shade100
        : Colors.green;
    final cameraBadgeIconColor = isDarkMode
        ? Colors.greenAccent.shade100
        : Colors.green;
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
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: headerGradientColors,
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
                        border: Border.all(color: avatarBorderColor, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: avatarShadowColor,
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          _buildProfileAvatar(
                            userName,
                            profileImageUrl,
                            avatarBackgroundColor: profileAvatarBackgroundColor,
                            avatarInitialColor: profileAvatarInitialColor,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _showMediaPicker,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: cameraBadgeBackground,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: cameraBadgeBorder,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 20,
                                  color: cameraBadgeIconColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),
                    Text(
                      userName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: userNameColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      userEmail,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: userEmailColor,
                      ),
                    ),
                    const SizedBox(height: 16),
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
                      icon: isDarkMode
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      title: 'Dark & Light Mode',
                      showArrow: false,
                      trailing: Switch(
                        value: isDarkMode,
                        activeThumbColor: Colors.green,
                        activeTrackColor: Colors.green.withValues(alpha: 0.45),
                        inactiveThumbColor: isDarkMode
                            ? Colors.white70
                            : null,
                        inactiveTrackColor: isDarkMode
                            ? Colors.white24
                            : null,
                        onChanged: (value) {
                          ref
                              .read(themeModeProvider.notifier)
                              .setDarkMode(value);
                        },
                      ),
                      onTap: () {
                        ref.read(themeModeProvider.notifier).toggleThemeMode();
                      },
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
              ref.read(cartProvider.notifier).clearInMemory();
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
  final Widget? trailing;
  final bool showArrow;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.titleColor,
    this.trailing,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;
    final resolvedIconColor = iconColor ?? (isDarkMode ? Colors.white : Colors.black);
    final resolvedTitleColor = titleColor ??
        (isDarkMode ? Colors.white : Colors.lightGreen);
    final iconTileTint = iconColor ?? (isDarkMode ? Colors.greenAccent : Colors.lime);
    final trailingColor = isDarkMode ? Colors.white70 : Colors.lightGreen;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.03),
        ),
        boxShadow: [
          if (!isDarkMode)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
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
                    color: iconTileTint.withValues(alpha: isDarkMode ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: resolvedIconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: resolvedTitleColor,
                    ),
                  ),
                ),
                if (trailing != null)
                  trailing!
                else if (showArrow)
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: trailingColor,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
