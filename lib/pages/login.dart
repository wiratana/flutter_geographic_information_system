import 'dart:convert';

import 'package:geographic_information_system/components/custom_button.dart';
import 'package:geographic_information_system/components/custom_form_text.dart';
import 'package:geographic_information_system/components/custom_scaffold_auth_purpose.dart';
import 'package:geographic_information_system/controllers/auth.dart';
import 'package:geographic_information_system/providers/AuthProvider.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();

  final email_controller = TextEditingController();
  final password_controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CustomScaffoldAuthPurpose(
        child: Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Login",
              style: TextStyle(
                fontSize: 40,
              )),
          SizedBox(
            height: 20,
          ),
          CustomFormText(
            hintText: "Enter Your Email",
            controller: email_controller,
          ),
          SizedBox(
            height: 20,
          ),
          CustomFormText(
            hintText: "Enter Your Password",
            controller: password_controller,
          ),
          SizedBox(
            height: 20,
          ),
          CustomButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                Auth()
                    .login(email_controller.text, password_controller.text)
                    .then((val) {
                  context.goNamed("maps");
                });
              }
            },
            child: Text("Submit"),
          ),
        ],
      ),
    ));
  }
}
