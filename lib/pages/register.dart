import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geographic_information_system/components/base_wrapper.dart';
import 'package:geographic_information_system/components/custom_button.dart';
import 'package:geographic_information_system/components/custom_form_text.dart';
import 'package:geographic_information_system/components/custom_scaffold_auth_purpose.dart';
import 'package:geographic_information_system/controllers/auth.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();

  final username_controller = TextEditingController();
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
            Text("Register", style: TextStyle(
              fontSize: 40,
            )),
            SizedBox(height: 20,),
            CustomFormText(
              hintText: "Enter Your Username",
              controller: username_controller,
            ),
            SizedBox(height: 20,),
            CustomFormText(
              hintText: "Enter Your Email",
              controller: email_controller,
            ),
            SizedBox(height: 20,),
            CustomFormText(
              hintText: "Enter Your Password",
              controller: password_controller,
            ),
            SizedBox(height: 20,),
            CustomButton(
              onPressed: () async{
                if(_formKey.currentState!.validate()) {
                  Auth().register(
                      username_controller.text,
                      email_controller.text,
                      password_controller.text);
                  context.goNamed("login");
                }
              },
              child: Text("Submit"),
            )
          ],
        ),
      ),
    );
  }
}
