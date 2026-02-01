// import 'package:agribridge/core/services/storage/user_session_service.dart';
// import 'package:agribridge/features/dashboard/domain/entities/profile_entity.dart';
// import 'package:agribridge/features/dashboard/domain/repositories/profile_repository.dart';
// import 'package:agribridge/features/dashboard/domain/usecases/get_profile_usecase.dart';
// import 'package:agribridge/features/dashboard/domain/usecases/save_profile_image_usecase.dart';
// import 'package:agribridge/features/dashboard/presentation/pages/profile_screen.dart';
// import 'package:agribridge/features/dashboard/presentation/state/profile_provider.dart';
// import 'package:agribridge/features/dashboard/presentation/view_model/profile_view_model.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import '../../../../test_utils.dart';

// class _FakeProfileRepository implements ProfileRepository {
//   ProfileEntity? _profile;

//   _FakeProfileRepository({ProfileEntity? profile}) : _profile = profile;

//   @override
//   Future<ProfileEntity?> getProfile() async {
//     return _profile;
//   }

//   @override
//   Future<void> saveProfileImage(String imagePath, String customerId) async {
//     _profile = ProfileEntity(
//       name: _profile?.name ?? 'User',
//       email: _profile?.email ?? '',
//       imagePath: imagePath,
//     );
//   }
// }

// class _TestProfileViewModel extends ProfileViewModel {
//   _TestProfileViewModel({
//     required GetProfileUseCase getProfileUseCase,
//     required SaveProfileImageUseCase saveProfileImageUseCase,
//   }) : super(
//           getProfileUseCase: getProfileUseCase,
//           saveProfileImageUseCase: saveProfileImageUseCase,
//         );

//   @override
//   Future<void> loadProfile() async {
//     // No-op to avoid provider updates during widget build in tests.
//   }
// }

// ProfileViewModel _buildProfileViewModel({ProfileEntity? profile}) {
//   final repo = _FakeProfileRepository(profile: profile);
//   return _TestProfileViewModel(
//     getProfileUseCase: GetProfileUseCase(repo),
//     saveProfileImageUseCase: SaveProfileImageUseCase(repo),
//   );
// }

// void main() {
//   testWidgets('opens media picker bottom sheet', (tester) async {
//     SharedPreferences.setMockInitialValues({
//       'user_id': '123',
//       'user_full_name': 'Jane Doe',
//       'user_email': 'jane@example.com',
//     });
//     final prefs = await SharedPreferences.getInstance();
//     final profileViewModel = _buildProfileViewModel(
//       profile: ProfileEntity(name: 'Jane Doe', email: 'jane@example.com'),
//     );

//     await tester.pumpWidget(
//       wrapWithApp(
//         const ProfileScreen(),
//         overrides: [
//           sharedPreferencesProvider.overrideWithValue(prefs),
//           profileViewModelProvider.overrideWith((ref) => profileViewModel),
//         ],
//       ),
//     );
//     await tester.pumpAndSettle();

//     await tester.tap(find.byIcon(Icons.camera_alt));
//     await tester.pumpAndSettle();

//     expect(find.text('Camera'), findsOneWidget);
//     expect(find.text('Gallery'), findsOneWidget);
//   });
// }
