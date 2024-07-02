import 'package:flutter/material.dart';

class CustomScaffoldAuthPurpose extends StatelessWidget {
  const CustomScaffoldAuthPurpose({super.key, this.child});

  final child;

  @override
  Widget build(BuildContext context) {
    var device_width = MediaQuery.of(context).size.width;
    var target_width = (device_width > 600) ? device_width / 2 : device_width;
    var target_padding = device_width * 0.1;

    return Scaffold(
        body: Stack(children: [
      Image.asset("assets/images/bg.jpeg",
          fit: BoxFit.cover, width: double.infinity, height: double.infinity),
      Container(
          width: target_width,
          color: Color(0xFF4D77FF),
          child: SafeArea(
            child: Center(
                child: Padding(
                    padding: EdgeInsets.all(target_padding), child: this.child)),
          ))
    ]));
  }
}
