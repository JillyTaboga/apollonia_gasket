import 'dart:math';

import 'package:apollonia_gasket/domain/circles_entity.dart';
import 'package:equations/equations.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

final clickedPointsS = signal<Map<CircleEntity, Offset>>({});
final circlesS = computed<List<CircleEntity>>(() {
  return [
    firstCircleS.value,
    ...circlesClickedS.value,
  ];
});
final sizeS = signal<double>(0);
final firstCircleS = computed(
  () {
    final center = sizeS.value / 2;
    return CircleEntity(
      center: Complex(center, center),
      radius: center,
      color: Colors.transparent,
    );
  },
);
final circlesClickedS = computed<List<CircleEntity>>(() {
  List<CircleEntity> circles = [];
  final map = clickedPointsS.value;
  map.forEach((key, value) {
    final center = Complex(value.dx, value.dy);
    final radius = (key.radius -
            ((value - Offset(key.center.real, key.center.imaginary)).distance))
        .abs();
    circles.add(
      CircleEntity(
        center: center,
        radius: radius,
        color: Colors.transparent,
      ),
    );
    final otherRadius = ((key.radius * 2) - (radius * 2)) / 2;
    final angle = -atan2(
      center.imaginary - key.center.imaginary,
      center.real - key.center.real,
    );
    print(angle * 180 / pi);
    final cosC = -cos(angle);
    final sinC = sin(angle);
    final x = (cosC * (otherRadius + radius)) + center.toOffset.dx;
    final y = (sinC * (otherRadius + radius)) + center.toOffset.dy;
    final otherCenter = Offset(x, y);
    circles.add(
      CircleEntity(
        center: Complex(otherCenter.dx, otherCenter.dy),
        radius: otherRadius,
        color: Colors.transparent,
      ),
    );
  });
  return circles;
});

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.grey,
          body: LayoutBuilder(
            builder: (context, constraints) {
              final sizeCalc = min(
                constraints.maxWidth,
                constraints.maxHeight,
              );
              if (sizeS.value != sizeCalc) {
                Future(() => sizeS.set(sizeCalc));
              }
              final size = sizeS.watch(context);
              return Center(
                child: Container(
                  width: size,
                  height: size,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      for (final circle in circlesS.watch(context))
                        Positioned(
                          top: (circle.center.imaginary - circle.radius).abs(),
                          left: (circle.center.real - circle.radius).abs(),
                          child: Container(
                            clipBehavior: Clip.antiAlias,
                            width: circle.radius * 2,
                            height: circle.radius * 2,
                            decoration: BoxDecoration(
                              color: circle.color,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTapUp: (details) async {
                                  final clickedPoint = Offset(
                                      details.globalPosition.dx,
                                      details.localPosition.dy +
                                          (circle.center.imaginary -
                                              circle.radius));
                                  var points = clickedPointsS.value;
                                  points[circle] = clickedPoint;
                                  clickedPointsS.set(points);
                                  circlesClickedS.recompute();
                                  circlesS.recompute();
                                  setState(() {});
                                },
                                child: const SizedBox.expand(),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class CirclesPainter extends CustomPainter {
  CirclesPainter(this.circles);
  final List<CircleEntity> circles;

  @override
  void paint(Canvas canvas, Size size) {
    for (final circle in circles) {
      final paintStroke = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.black;
      final paintFill = Paint()
        ..style = PaintingStyle.fill
        ..color = circle.color;
      canvas.drawCircle(
        Offset(
          circle.center.real,
          circle.center.imaginary,
        ),
        circle.radius,
        paintFill,
      );
      canvas.drawCircle(
        Offset(
          circle.center.real,
          circle.center.imaginary,
        ),
        circle.radius,
        paintStroke,
      );
    }
  }

  @override
  bool shouldRepaint(CirclesPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(CirclesPainter oldDelegate) => false;
}
