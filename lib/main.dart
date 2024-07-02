import 'package:flutter/material.dart';
import 'package:geographic_information_system/pages/front_page.dart';
import 'package:geographic_information_system/pages/login.dart';
import 'package:geographic_information_system/pages/maps.dart';
import 'package:geographic_information_system/pages/register.dart';
import 'package:geographic_information_system/pages/test.dart';
import 'package:geographic_information_system/providers/AuthProvider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_strategy/url_strategy.dart';

final GoRouter _router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        name: "home",
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return FrontPage();
        },
        routes: <RouteBase>[
          GoRoute(
              name: "register",
              path: 'register',
              builder: (BuildContext context, GoRouterState state){
                return Register();
              }
          ),
          GoRoute(
              name: "login",
              path: 'login',
              builder: (BuildContext context, GoRouterState state){
                return Login();
              }
          ),
          GoRoute(
            name: "maps",
            path: "maps",
            builder: (BuildContext context, GoRouterState state){
              return Maps();
            }
          )
        ]
      ),
    ]
);

void main() {
  setPathUrlStrategy();
  runApp(
      MultiProvider(
          providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
          child: const MyApp()
      )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      theme: ThemeData(
        textTheme: GoogleFonts.montserratTextTheme(
          Theme.of(context).textTheme.apply(
            displayColor: Color(0xFFFFFFFF),
            fontSizeFactor: 0.7
          )
        )
      ),
    );
  }
}