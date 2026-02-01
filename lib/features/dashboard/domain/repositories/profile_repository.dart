import '../entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<void> saveProfileImage(String imagePath, String customerId);
  Future<ProfileEntity?> getProfile();
}
