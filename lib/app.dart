import 'package:again/view/home.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
