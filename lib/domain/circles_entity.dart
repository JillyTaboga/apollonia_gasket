import 'dart:math' as math;

import 'package:flutter/material.dart';

int n = 0;

Color randomColor() =>
    Colors.primaries[math.Random().nextInt(Colors.primaries.length)];

class CircleEntity {
  final Complex center;
  final double bend;
  final Color color;
  final int id;
  const CircleEntity({
    required this.center,
    required this.bend,
    required this.color,
    required this.id,
  });

  double get radius => (1 / bend).abs();

  double dist(CircleEntity other) {
    return (other.center.toOffset - center.toOffset).distance;
  }

  bool isTangent(CircleEntity other) {
    final a = (dist(other) - (radius + other.radius)).abs() < 0.1;
    final b = (dist(other) - (other.radius - radius).abs()).abs() < 0.1;
    return a || b;
  }

  CircleEntity copyWith({
    Complex? center,
    double? bend,
    Color? color,
  }) {
    return CircleEntity(
      center: center ?? this.center,
      bend: bend ?? this.bend,
      color: color ?? this.color,
      id: id,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CircleEntity &&
        other.center == center &&
        other.bend == bend &&
        other.color == color;
  }

  @override
  int get hashCode => center.hashCode ^ bend.hashCode ^ color.hashCode;
}

extension ComplexT on Complex {
  Offset get toOffset => Offset(real, imaginary);
}

class Complex {
  // Defines a complex number and its operations
  // Constructor to create a complex number with real (a) and imaginary (b) parts
  Complex(
    this.real,
    this.imaginary,
  );

  final double real;
  final double imaginary;

  // All function return the result as a new Complex number

  // Adds this complex number with another
  Complex add(Complex other) {
    return Complex(
      real + other.real,
      imaginary + other.imaginary,
    );
  }

  // Subtracts another complex number from this one
  Complex sub(Complex other) {
    return Complex(
      real - other.real,
      imaginary - other.imaginary,
    );
  }

  // Scales this complex number by a real number value
  Complex scale(double value) {
    return Complex(real * value, imaginary * value);
  }

  // Multiplies this complex number with another, using the formula (ac-bd) + (ad+bc)i
  Complex mult(Complex other) {
    final a = real * other.real - imaginary * other.imaginary;
    final b = real * other.imaginary + other.real * imaginary;
    return Complex(
      a,
      b,
    );
  }

  // Calculates the square root of this complex number
  Complex sqrt() {
    // Convert to polar form
    final m = math.sqrt(real * real + imaginary * imaginary);
    final angle = math.atan2(imaginary, real);
    // Calculate square root of magnitude and use half the angle for square root
    final m2 = math.sqrt(m);
    final angle2 = angle / 2;
    // Back to rectangular form
    return Complex(
      m2 * math.cos(angle2),
      m2 * math.sin(angle2),
    );
  }

  Complex operator +(Complex other) => add(other);
  Complex operator -(Complex other) => sub(other);
  Complex operator *(Complex other) => mult(other);
}
