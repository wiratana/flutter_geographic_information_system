import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  const CustomText({super.key, this.text = ""});
  
  final String text;
  
  @override
  Widget build(BuildContext context) {
    return Text(this.text, style: TextStyle(fontSize: 16, color: Colors.white),);
  }
}
