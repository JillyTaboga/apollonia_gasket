import 'package:equations/equations.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

class CircleEntity {
  final Complex center;
  final double radius;
  final Color color;
  const CircleEntity({
    required this.center,
    required this.radius,
    required this.color,
  });

  CircleEntity copyWith({
    Complex? center,
    double? radius,
    Color? color,
  }) {
    return CircleEntity(
      center: center ?? this.center,
      radius: radius ?? this.radius,
      color: color ?? this.color,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CircleEntity &&
        other.center == center &&
        other.radius == radius &&
        other.color == color;
  }

  @override
  int get hashCode => center.hashCode ^ radius.hashCode ^ color.hashCode;
}

extension ComplexT on Complex {
  Vector2 get toVector => Vector2(real, imaginary);
  Offset get toOffset => Offset(real, imaginary);
}
