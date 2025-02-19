import 'package:flutter/material.dart';
import 'package:rodamorzar/screens/HomeScreen.dart';
import 'package:rodamorzar/screens/LoginScreen.dart';
import 'package:rodamorzar/screens/ProfileScreen.dart';
import 'package:rodamorzar/screens/RoutesScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/login': (context) => LoginScreen(),
        '/profile': (context) => ProfileScreen(),
        '/routes': (context) => RoutesScreen(),
      },
    );
  }
}
