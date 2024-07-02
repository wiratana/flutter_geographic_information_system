import 'package:flutter/material.dart';

class BaseWrapper extends StatelessWidget {
  const BaseWrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: child,
      ),
    );
  }
}
