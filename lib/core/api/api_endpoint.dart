// import 'dart:io';
// import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  // Base URL - change this for production
  static const String baseUrl = 'http://10.0.2.2:5000/api';
  //static const String baseUrl = 'http://localhost:3000/agribridge';
  //static const String baseUrl = 'http://192.168.1.xxx:3000/agribridge'; // Replace xxx with your IP
  // For Android Emulator use: 'http://10.0.2.2:3000/agribridge'
  // For iOS Simulator use: 'http://localhost:3000/agribridge'
  // For Physical Device use your computer's IP: 'http://192.168.x.x:3000/agribridge'
  // For Windows Desktop use: 'http://localhost:3000/agribridge'

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);


  // Customer Endpoints 
  static const String customers = '/customers';
  static const String customerLogin = '/auth/login';
  static const String customerRegister = '/auth/register';
  

  // profile image
  static const String image = '/profile';
  static String imageById(String id) => '/profile/$id';
  static String imageClaim(String id) => '/profile/$id/claim';
  static const String profileUploadPhoto = '/profile/upload';
  // static const String profileUploadVideo = '/profile/upload-video';

  // for images and videos :
  // static String itemPicture(String filename) =>
  //     '$mediaServerUrl/profile_photos/$filename';
  // static String itemVideo(String filename) =>
  //     '$mediaServerUrl/profile_videos/$filename';
}

