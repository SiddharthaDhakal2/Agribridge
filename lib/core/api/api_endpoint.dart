// import 'dart:io';
// import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  // Base URL - change this for production
  static const String baseUrl = 'http://10.0.2.2:5000/api';
  //static const String baseUrl = 'http://localhost:3000/agribridge';
  //static const String baseUrl = 'http://192.168.96.1:3000/agribridge'; // Replace xxx with your IP
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
  

  // Profile
  static String profileById(String id) => '/auth/profile/$id';

  // for images and videos :
  // static String itemPicture(String filename) =>
  //     '$mediaServerUrl/profile_photos/$filename';
  // static String itemVideo(String filename) =>
  //     '$mediaServerUrl/profile_videos/$filename';

  static String resolveMediaUrl(String path) {
    var trimmed = path.trim();
    if (trimmed.isEmpty) return trimmed;
    trimmed = trimmed.replaceAll('\\', '/');
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }

    final uploadsIndex = trimmed.indexOf('/uploads/');
    if (uploadsIndex != -1) {
      trimmed = trimmed.substring(uploadsIndex);
    } else if (trimmed.startsWith('uploads/')) {
      trimmed = '/$trimmed';
    }

    final uri = Uri.parse(baseUrl);
    final port = uri.hasPort ? ':${uri.port}' : '';
    final serverUrl = '${uri.scheme}://${uri.host}$port';

    if (trimmed.startsWith('/')) {
      return '$serverUrl$trimmed';
    }
    return '$serverUrl/$trimmed';
  }
}

