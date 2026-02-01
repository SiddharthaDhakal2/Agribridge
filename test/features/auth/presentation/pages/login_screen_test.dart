// import 'package:agribridge/features/auth/domain/entities/auth_entity.dart';
// import 'package:agribridge/features/auth/domain/repositories/auth_repository.dart';
// import 'package:agribridge/features/auth/domain/usecases/login_usecase.dart';
// import 'package:agribridge/features/auth/domain/usecases/register_usecase.dart';
// import 'package:agribridge/features/auth/presentation/pages/login_screen.dart';
// import 'package:agribridge/features/auth/presentation/state/auth_state.dart';
// import 'package:agribridge/features/auth/presentation/view_model/auth_view_model.dart';
// import 'package:agribridge/features/dashboard/data/models/profile_model.dart';
// import 'package:agribridge/features/dashboard/domain/entities/profile_entity.dart';
// import 'package:agribridge/features/dashboard/presentation/state/profile_state.dart';
// import 'package:dartz/dartz.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';

// import '../../../../test_utils.dart';
// import 'package:agribridge/core/error/failures.dart';

// class _FakeAuthRepository implements IAuthRepository {
//   @override
//   Future<Either<Failure, AuthEntity>> getCurrentUser() async {
//     return Right(
//       const AuthEntity(
//         fullName: 'Test User',
//         email: 'test@example.com',
//         username: 'tester',
//       ),
//     );
//   }

//   @override
//   Future<Either<Failure, AuthEntity>> login(String email, String password) async {
//     return Right(
//       AuthEntity(
//         fullName: 'Test User',
//         email: email,
//         username: 'tester',
//       ),
//     );
//   }

//   @override
//   Future<Either<Failure, bool>> logout() async {
//     return const Right(true);
//   }

//   @override
//   Future<Either<Failure, bool>> register(AuthEntity entity) async {
//     return const Right(true);
//   }
// }

// AuthViewModel _buildAuthViewModel({AuthState? initialState}) {
//   final repo = _FakeAuthRepository();
//   final loginUsecase = LoginUsecase(authRepository: repo);
//   final registerUsecase = RegisterUsecase(authRepository: repo);
//   final viewModel = AuthViewModel(
//     loginUsecase: loginUsecase,
//     registerUsecase: registerUsecase,
//   );
//   if (initialState != null) {
//     viewModel.state = initialState;
//   }
//   return viewModel;
// }

// void main() {
//   group('Unit tests', () {
//     test('AuthState defaults to initial status', () {
//       const state = AuthState();
//       expect(state.status, AuthStatus.initial);
//       expect(state.errorMessage, isNull);
//       expect(state.authEntity, isNull);
//     });

//     test('AuthState copyWith updates status only', () {
//       const state = AuthState();
//       final updated = state.copyWith(status: AuthStatus.loading);
//       expect(updated.status, AuthStatus.loading);
//       expect(updated.errorMessage, isNull);
//     });

//     test('ProfileState copyWith preserves profile when not provided', () {
//       final profile = ProfileEntity(name: 'Alex', email: 'a@b.com');
//       final state = ProfileState(profile: profile, isLoading: false);
//       final updated = state.copyWith(isLoading: true);
//       expect(updated.profile, profile);
//       expect(updated.isLoading, true);
//     });

//     test('ProfileEntity stores provided values', () {
//       final entity = ProfileEntity(
//         name: 'Jane',
//         email: 'jane@example.com',
//         imagePath: '/tmp/profile.png',
//       );
//       expect(entity.name, 'Jane');
//       expect(entity.email, 'jane@example.com');
//       expect(entity.imagePath, '/tmp/profile.png');
//     });

//     test('ProfileModel stores provided values', () {
//       final model = ProfileModel(
//         name: 'Sam',
//         email: 'sam@example.com',
//         imagePath: '/tmp/sam.png',
//       );
//       expect(model.name, 'Sam');
//       expect(model.email, 'sam@example.com');
//       expect(model.imagePath, '/tmp/sam.png');
//     });
//   });

//   group('LoginScreen widget tests', () {
//     testWidgets('shows validation errors when form is empty', (tester) async {
//       final authViewModel = _buildAuthViewModel();

//       await tester.pumpWidget(
//         wrapWithApp(
//           const LoginScreen(),
//           overrides: [
//             authViewModelProvider.overrideWith((ref) => authViewModel),
//           ],
//         ),
//       );

//       await tester.ensureVisible(find.byType(ElevatedButton));
//       await tester.tap(find.byType(ElevatedButton));
//       await tester.pump();

//       expect(find.text('Please enter your email'), findsOneWidget);
//       expect(find.text('Please enter your password'), findsOneWidget);
//     });

//     testWidgets('toggles password visibility icon', (tester) async {
//       final authViewModel = _buildAuthViewModel();

//       await tester.pumpWidget(
//         wrapWithApp(
//           const LoginScreen(),
//           overrides: [
//             authViewModelProvider.overrideWith((ref) => authViewModel),
//           ],
//         ),
//       );

//       expect(find.byIcon(Icons.visibility), findsOneWidget);
//       await tester.tap(find.byIcon(Icons.visibility));
//       await tester.pump();
//       expect(find.byIcon(Icons.visibility_off), findsOneWidget);
//     });
//   });
// }
