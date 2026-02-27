
import 'local/profile_local_datasource.dart';
import '../models/profile_model.dart';

class ProfileDataSource {
	final ProfileLocalDataSource localDataSource = ProfileLocalDataSource();

	Future<void> saveProfileImage(
		String customerId,
		String imagePath, {
		String? name,
		String? email,
	}) async {
		final existingProfile = await localDataSource.getProfile(customerId);
		final profile = ProfileModel(
			name: name ?? existingProfile?.name,
			email: email ?? existingProfile?.email,
			imagePath: imagePath,
		);
		await localDataSource.saveProfile(customerId, profile);
	}

	Future<ProfileModel?> getProfile(String customerId) async {
		return await localDataSource.getProfile(customerId);
	}

	Future<void> clearProfile(String customerId) async {
		await localDataSource.clearProfile(customerId);
	}
}
