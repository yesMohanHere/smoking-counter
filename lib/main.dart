import 'package:flutter/material.dart';
import 'package:smoking_tracker_app/lib/smoking_tracker.dart'; // Ensure this path matches your project structure

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smoking Tracker App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SmokingTracker(),
    );
  }
}
