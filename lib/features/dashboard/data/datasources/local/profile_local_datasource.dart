import 'package:hive/hive.dart';
import '../../models/profile_model.dart';

class ProfileLocalDataSource {
  static const String boxName = 'profileBox';
  static const String _profileKeyPrefix = 'profile_';

  String _profileKey(String customerId) => '$_profileKeyPrefix$customerId';

  Future<void> saveProfile(String customerId, ProfileModel profile) async {
    var box = await Hive.openBox<ProfileModel>(boxName);
    await box.put(_profileKey(customerId), profile);
  }

  Future<ProfileModel?> getProfile(String customerId) async {
    var box = await Hive.openBox<ProfileModel>(boxName);
    return box.get(_profileKey(customerId));
  }

  Future<void> clearProfile(String customerId) async {
    var box = await Hive.openBox<ProfileModel>(boxName);
    await box.delete(_profileKey(customerId));
  }
}
