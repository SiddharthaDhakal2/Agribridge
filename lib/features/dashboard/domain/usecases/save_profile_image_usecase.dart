import '../repositories/profile_repository.dart';

class SaveProfileImageUseCase {
  final ProfileRepository repository;
  SaveProfileImageUseCase(this.repository);

  Future<void> call(String imagePath, String customerId) async {
    await repository.saveProfileImage(imagePath, customerId);
  }
}
