import 'package:flutter/material.dart';
import 'dart:async';
import 'package:tryout_app/auth/login.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  _SplashscreenState createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    // Timer untuk navigasi ke halaman berikutnya setelah 3 detik
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ), // ganti dengan halaman tujuanmu
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book, size: 100, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              'Try Out App',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

// Contoh halaman berikutnya
class NextPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('This is the next page')));
  }
}
