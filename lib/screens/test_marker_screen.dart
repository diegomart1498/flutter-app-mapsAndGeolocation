import 'package:flutter/material.dart';

import 'package:maps_app/markers/markers.dart';

class TestMarkerScreen extends StatelessWidget {
  const TestMarkerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.red,
          width: 350,
          height: 150,
          child: CustomPaint(
            // painter: StartMarkerPainter(minutes: 20, destination: 'Mi casa'),
            painter: EndMarkerPainter(kilometers: 7, destination: 'Un texto'),
          ),
        ),
      ),
    );
  }
}
