// import 'package:agribridge/features/auth/domain/entities/auth_entity.dart';
// import 'package:agribridge/features/auth/domain/repositories/auth_repository.dart';
// import 'package:agribridge/features/auth/domain/usecases/login_usecase.dart';
// import 'package:agribridge/features/auth/domain/usecases/register_usecase.dart';
// import 'package:agribridge/features/auth/presentation/pages/register_screen.dart';
// import 'package:agribridge/features/auth/presentation/state/auth_state.dart';
// import 'package:agribridge/features/auth/presentation/view_model/auth_view_model.dart';
// import 'package:agribridge/core/error/failures.dart';
// import 'package:dartz/dartz.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';

// import '../../../../test_utils.dart';

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
//   group('RegisterScreen widget tests', () {
//     testWidgets('shows validation errors when form is empty', (tester) async {
//       final authViewModel = _buildAuthViewModel();

//       await tester.pumpWidget(
//         wrapWithApp(
//           const RegisterScreen(),
//           overrides: [
//             authViewModelProvider.overrideWith((ref) => authViewModel),
//           ],
//         ),
//       );

//       await tester.ensureVisible(find.byType(ElevatedButton));
//       await tester.tap(find.byType(ElevatedButton));
//       await tester.pump();

//       expect(find.text('Please enter your name'), findsOneWidget);
//       expect(find.text('Please enter your email'), findsOneWidget);
//       expect(find.text('Please enter your password'), findsOneWidget);
//       expect(find.text('Please confirm your password'), findsOneWidget);
//     });

//     testWidgets('disables sign up button while loading', (tester) async {
//       final authViewModel = _buildAuthViewModel(
//         initialState: const AuthState(status: AuthStatus.loading),
//       );

//       await tester.pumpWidget(
//         wrapWithApp(
//           const RegisterScreen(),
//           overrides: [
//             authViewModelProvider.overrideWith((ref) => authViewModel),
//           ],
//         ),
//       );

//       final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
//       expect(button.onPressed, isNull);
//       expect(find.byType(CircularProgressIndicator), findsOneWidget);
//     });
//   });
// }
