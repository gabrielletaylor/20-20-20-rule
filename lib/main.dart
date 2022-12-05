import 'package:twenty_20_20_rule/home_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '20-20-20 Rule',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          color: const Color(0xff3c3f41)
        ),
        fontFamily: "JetBrains Mono"
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}
