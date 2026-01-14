import 'package:hive/hive.dart';
import 'package:agribridge/core/constants/hive_table_constants.dart';
import 'package:agribridge/features/auth/domain/entities/auth_entity.dart';
import 'package:uuid/uuid.dart';

part 'auth_hive_model.g.dart';

@HiveType(typeId:HiveTableConstant.authTypeId)
class AuthHiveModel extends HiveObject{

  @HiveField(0)
  final String? authId;
  @HiveField(1)
  final String fullName;
  @HiveField(2)
  final String email;
  @HiveField(3)
  final String username;
  @HiveField(4)
  final String? password;
  @HiveField(5)
  final String? profilePicture;

  AuthHiveModel({
    String? authId,
    required this.fullName,
    required this.email,
    required this.username,
    this.password,
    this.profilePicture,
  }) : authId = authId ?? Uuid().v4();

  //From Entity
   factory AuthHiveModel.fromEntiity(AuthEntity entity){
    return AuthHiveModel(
      authId: entity.authId,
      fullName: entity.fullName,
      email: entity.email,
      username: entity.username,
      password: entity.password,
      profilePicture: entity.profilePicture,
    );
   }

  //To Entity
  AuthEntity toEntity(){
    return AuthEntity(
      authId: authId,
      fullName: fullName,
      email: email,
      username: username,
      password: password,
      profilePicture: profilePicture,
    );
  }
}