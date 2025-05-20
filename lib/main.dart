import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart'; // import ini
import 'splashscreen.dart'; // pastikan path sesuai

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GlobalLoaderOverlay(
      // <<=== wrap with this
      child: MaterialApp(
        theme: ThemeData(primarySwatch: Colors.blue),
        debugShowCheckedModeBanner: false,
        home: const Splashscreen(),
      ),
    );
  }
}
