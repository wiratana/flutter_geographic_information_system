import 'package:flutter/material.dart';

class CustomFormText extends StatelessWidget {
  const CustomFormText({super.key, this.controller, this.prefixIcon, this.hintText, this.labelText, this.focusNode = null, this.enabled = true});

  final controller;
  final prefixIcon;
  final hintText;
  final labelText;
  final focusNode;
  final enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        focusNode: this.focusNode,
        decoration: InputDecoration(
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide:BorderSide(width: 0, style: BorderStyle.none)),
          fillColor: Colors.white,
          filled: true,
          prefixIcon: this.prefixIcon,
          hintText: this.hintText,
          labelText: this.labelText,
        ),
        controller: this.controller,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "hey masukan input";
          }
          return null;
        },
        enabled: enabled,
      ),
    );
  }
}
