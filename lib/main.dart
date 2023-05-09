import 'package:flutter/material.dart';
import 'package:music_cataloger/main_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) => const Material(
        color: Colors.black,
        child: MainPage(),
      ),
    );
  }
}
