import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({super.key, this.onPressed, this.child});

  final onPressed;
  final child;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          backgroundColor: Color(0xFF56BBF1),
          elevation: 0,
        ),
        onPressed: this.onPressed,
        child: this.child);
  }
}
