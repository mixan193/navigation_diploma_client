import 'package:flutter/material.dart';

class UserMarker extends StatelessWidget {
  const UserMarker({super.key});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.person_pin_circle, size: 40, color: Colors.blue);
  }
}