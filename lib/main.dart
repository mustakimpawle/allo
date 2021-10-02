import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'splashscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.contacts.request();
  await Permission.locationWhenInUse.request();
  await Permission.storage.request();
  await Permission.manageExternalStorage.request();
  await Permission.camera.request();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Allo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Splashscreen(),
    );
  }
}
