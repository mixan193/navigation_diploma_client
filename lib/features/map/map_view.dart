import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:navigation_diploma_client/features/map/map_controller.dart';
import 'package:navigation_diploma_client/features/map/user_marker.dart';
import 'package:navigation_diploma_client/features/map/map_model.dart';

/// map_view.dart
///
/// Основной виджет для отображения карты. Может использовать CustomPaint,
/// Image, Canvas или любой другой подход для рисования плана здания.
class MapView extends StatelessWidget {
  const MapView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MapController>();
    final floor = controller.currentFloor;

    if (floor == null) {
      return const Center(child: Text('No floor data'));
    }

    return GestureDetector(
      // Обработка жестов для масштабирования/перемещения
      onScaleUpdate: (details) {
        // Для упрощения меняем масштаб и смещение.
        // В реальном коде нужно аккуратно обрабатывать новые значения (min/max).
        final newScale = controller.currentScale * details.scale;
        controller.setScale(newScale.clamp(0.5, 5.0));

        // Сдвиг offset
        final dx = controller.offsetX + details.focalPointDelta.dx;
        final dy = controller.offsetY + details.focalPointDelta.dy;
        controller.setOffset(dx, dy);
      },
      child: Stack(
        children: [
          // Собственно "карта"
          CustomPaint(
            size: Size.infinite,
            painter: _MapPainter(
              floor: floor,
              scale: controller.currentScale,
              offsetX: controller.offsetX,
              offsetY: controller.offsetY,
            ),
          ),

          // Маркер пользователя
          // (его позицию можно брать из PositionEstimator или SensorManager,
          //  но здесь просто заглушка — (x=200, y=150))
          Positioned(
            left: (200 * controller.currentScale + controller.offsetX) - 16,
            top: (150 * controller.currentScale + controller.offsetY) - 16,
            child: const UserMarker(),
          ),
        ],
      ),
    );
  }
}

/// Небольшой CustomPainter для рисования комнат этажа.
class _MapPainter extends CustomPainter {
  final FloorModel floor;
  final double scale;
  final double offsetX;
  final double offsetY;

  _MapPainter({
    required this.floor,
    required this.scale,
    required this.offsetX,
    required this.offsetY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF888888)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Рисуем комнаты
    for (final room in floor.rooms) {
      // Допустим, каждая "комната" — это прямоугольник 50x50, центр в (room.x, room.y)
      final rect = Rect.fromLTWH(
        (room.x * scale + offsetX) - 25,
        (room.y * scale + offsetY) - 25,
        50 * scale,
        50 * scale,
      );
      canvas.drawRect(rect, paint);

      // Подпись комнаты
      final textSpan = TextSpan(
        text: room.name,
        style: const TextStyle(color: Colors.black, fontSize: 12),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      final offset = Offset(
        rect.center.dx - (textPainter.width / 2),
        rect.center.dy - (textPainter.height / 2),
      );
      textPainter.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) {
    return oldDelegate.scale != scale ||
        oldDelegate.offsetX != offsetX ||
        oldDelegate.offsetY != offsetY ||
        oldDelegate.floor != floor;
  }
}
