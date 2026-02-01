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
    await localDataSource.saveProfileImage(imagePath);
    await remoteDataSource.uploadProfileImage(imagePath, customerId);
  }

  @override
  Future<ProfileEntity?> getProfile() async {
    final profile = await localDataSource.getProfile();
    String? imageUrl;
    try {
      imageUrl = await remoteDataSource.fetchProfileImageUrl();
    } catch (_) {
      imageUrl = profile?.imagePath;
    }
    if (profile == null) return null;
    return ProfileEntity(name: profile.name, email: profile.email, imagePath: imageUrl ?? profile.imagePath);
  }
}
