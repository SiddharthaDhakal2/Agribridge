import 'package:dartz/dartz.dart';
import 'package:agribridge/core/error/failures.dart';
import 'package:agribridge/features/auth/domain/entities/auth_entity.dart';

abstract interface class IAuthRepository {
  Future<Either<Failure, bool>> register(AuthEntity entity);
  Future<Either<Failure, AuthEntity>> login(String email, String password);
  Future<Either<Failure, AuthEntity>> getCurrentUser();
  Future<Either<Failure, bool>> logout();
  Future<Either<Failure, bool>> changePassword(
    String userId,
    String currentPassword,
    String newPassword,
  );
  Future<Either<Failure, bool>> deleteAccount(
    String userId,
    String currentPassword,
  );
  Future<Either<Failure, bool>> sendForgotPasswordOtp(String email);
  Future<Either<Failure, bool>> verifyForgotPasswordOtp(
    String email,
    String otp,
  );
  Future<Either<Failure, bool>> resetForgotPassword(
    String email,
    String otp,
    String newPassword,
    String confirmPassword,
  );
}
