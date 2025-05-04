import 'package:flutter/material.dart';

/// user_marker.dart
///
/// Небольшой виджет для отображения местоположения пользователя на карте.
/// Можно использовать иконку, кастомный рисунок, анимацию и т.д.
class UserMarker extends StatelessWidget {
  const UserMarker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Иконку/фигуру — на ваше усмотрение, это пример.
    return SizedBox(
      width: 32,
      height: 32,
      child: Image.asset('assets/images/user_marker.png'),
    );
  }
}
