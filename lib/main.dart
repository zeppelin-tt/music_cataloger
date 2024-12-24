import 'package:flutter/material.dart';
import 'package:metadata_god/metadata_god.dart';
import 'main_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MetadataGod.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        return const Material(color: Colors.black, child: MainPage());
      },
    );
  }
}
