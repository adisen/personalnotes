import 'package:flutter/material.dart';
import 'package:personalnotes/views/login_view.dart';
import 'package:personalnotes/views/register_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Notes',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const RegisterView(),
    );
  }
}
