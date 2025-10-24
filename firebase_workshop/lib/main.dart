import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: "AIzaSyDQ9pTzxv7ztEI2lSZbbhTCviRiACZ4nOE",
        authDomain: "fir-workshop-b6997.firebaseapp.com",
        projectId: "fir-workshop-b6997",
        storageBucket: "fir-workshop-b6997.firebasestorage.app",
        messagingSenderId: "638779278399",
        appId: "1:638779278399:web:d2d77815f9b067c485a48a",
        measurementId: "G-2RVX119GH5"),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const LoginPage(),
    );
  }
}
