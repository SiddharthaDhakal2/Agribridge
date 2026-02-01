
import 'local/profile_local_datasource.dart';
import '../models/profile_model.dart';

class ProfileDataSource {
	final ProfileLocalDataSource localDataSource = ProfileLocalDataSource();

	Future<void> saveProfileImage(String imagePath, {String? name, String? email}) async {
		final profile = ProfileModel(name: name, email: email, imagePath: imagePath);
		await localDataSource.saveProfile(profile);
	}

	Future<ProfileModel?> getProfile() async {
		return await localDataSource.getProfile();
	}
}