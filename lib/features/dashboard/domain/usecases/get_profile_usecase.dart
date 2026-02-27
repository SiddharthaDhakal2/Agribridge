import '../repositories/profile_repository.dart';
import '../entities/profile_entity.dart';

class GetProfileUseCase {
  final ProfileRepository repository;
  GetProfileUseCase(this.repository);

  Future<ProfileEntity?> call(String customerId) async {
    return await repository.getProfile(customerId);
  }
}
