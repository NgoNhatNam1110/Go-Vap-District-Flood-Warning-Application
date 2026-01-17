import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:currency_converter/pages/authen.dart';
import 'package:currency_converter/core/service_locator.dart';
import 'firebase_options.dart';

void main() async {
  // Đảm bảo Flutter bindings được khởi tạo
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Setup Dependency Injection
  await setupServiceLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cảnh báo lũ lụt Gò Vấp',
      theme: ThemeData(
        fontFamily: 'Poppins',
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      home: const AuthenPage(),
    );
  }
}

