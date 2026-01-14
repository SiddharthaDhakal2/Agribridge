import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  const MyButton({super.key,
  required this.onPressed,
  required this.text,
  this.color
  });

  //on pressed callback
  final VoidCallback onPressed;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color?? Colors.amber,
        padding: const EdgeInsets.symmetric(
          horizontal:20,
          vertical:10,
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20
        ),
      ),
    );
  }
}