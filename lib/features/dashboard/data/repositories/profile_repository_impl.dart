import '../datasources/profile_datasource.dart';
import '../datasources/remote/profile_remote_datasource.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileDataSource localDataSource;
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.localDataSource, required this.remoteDataSource});

  @override

  Future<void> saveProfileImage(String imagePath, String customerId) async {
    final uploadedImagePath =
        await remoteDataSource.uploadProfileImage(imagePath, customerId);
    await localDataSource.saveProfileImage(customerId, uploadedImagePath ?? imagePath);
  }

  @override
  Future<ProfileEntity?> getProfile(String customerId) async {
    final profile = await localDataSource.getProfile(customerId);
    if (profile == null) return null;
    return ProfileEntity(
      name: profile.name,
      email: profile.email,
      imagePath: profile.imagePath,
    );
  }
}
