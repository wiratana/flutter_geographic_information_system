import "package:flutter/material.dart";
import "package:geographic_information_system/components/custom_button.dart";
import "package:geographic_information_system/components/custom_text.dart";
import "package:geographic_information_system/components/base_wrapper.dart";
import "package:go_router/go_router.dart";

class FrontPage extends StatelessWidget {
  const FrontPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseWrapper(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset("assets/images/logo-gis.png", height: 100,width: 100,),
              SizedBox(height: 25,),
              CustomButton(
                onPressed: (){
                  context.goNamed("register");
                },
                child: CustomText(text: "Register"),
              ),
              SizedBox(height: 25,),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Doesn't Have Account ? "),
                  GestureDetector(
                    onTap: (){
                      context.goNamed("login");
                    },
                    child: Text("Login"),
                  )
                ],
              )
            ],
          )
        )
    );
  }
}

