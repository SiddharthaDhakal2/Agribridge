import 'package:flutter/material.dart';

showMySnackBar({
  required BuildContext context,
  required String message,
  Color? color       

}){
  ScaffoldMessenger.of(context,
              ).showSnackBar(
                SnackBar(
                  content: Text(message),
                  duration: Duration(seconds: 3),
                  backgroundColor: color ?? Colors.white,
                  behavior: SnackBarBehavior.floating,
  ),
  );
}