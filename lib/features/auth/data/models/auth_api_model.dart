import 'package:agribridge/features/auth/domain/entities/auth_entity.dart';

class AuthApiModel{
  final String? id;
  final String fullName;
  final String email;
  //final String? phoneNumber;
  final String username;
  final String? password;
  final String? profilePicture; 

  AuthApiModel({
    this.id,
    required this.fullName,
    required this.email,
    //this.phoneNumber, 
    required this.username,
    this.password,
    this.profilePicture,
  });

  Map<String, dynamic> toJson(){
    return{
      "name": fullName,
      "email": email,
      "password": password,
      "confirmPassword": password,
    };
  }

  factory AuthApiModel.fromJson(Map<String,dynamic> json){
    final email = json['email'] as String;
    final name = json['name'] as String? ?? '';
    
    final finalName = name.isNotEmpty ? name : email.split('@').first;
    
    return AuthApiModel(
      id: json['_id'] as String?,
      fullName: finalName,
      email: email,
      username: email.split('@').first,
      profilePicture: json['profilePicture'] as String?,
    );
  }

  AuthEntity toEntity(){
    return AuthEntity(
      authId: id,
      fullName: fullName,
      email: email,
      //phoneNumber: phoneNumber,
      username: username,
      profilePicture: profilePicture);
  }

  factory AuthApiModel.fromEntity(AuthEntity entity){
    return AuthApiModel(
      fullName:entity.fullName,
      email: entity.email,
      //phoneNumber: entity.phoneNumber,
      username: entity.username,  
      password: entity.password,
      profilePicture: entity.profilePicture);
  }

  static List<AuthEntity> toEntityList(List<AuthApiModel> models){
    return models.map((model)=>model.toEntity()).toList();
  }

}