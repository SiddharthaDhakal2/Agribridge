import 'package:hive/hive.dart';

part 'profile_model.g.dart';

@HiveType(typeId: 2)
class ProfileModel extends HiveObject {
  @HiveField(0)
  String? name;

  @HiveField(1)
  String? email;

  @HiveField(2)
  String? imagePath; // Store image file path

  ProfileModel({this.name, this.email, this.imagePath});
}
