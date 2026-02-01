import 'package:hive/hive.dart';
import '../../models/profile_model.dart';

class ProfileLocalDataSource {
  static const String boxName = 'profileBox';

  Future<void> saveProfile(ProfileModel profile) async {
    var box = await Hive.openBox<ProfileModel>(boxName);
    await box.put('profile', profile);
  }

  Future<ProfileModel?> getProfile() async {
    var box = await Hive.openBox<ProfileModel>(boxName);
    return box.get('profile');
  }
}
