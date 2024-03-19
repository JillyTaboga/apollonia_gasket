import 'dart:math';

import 'package:apollonia_gasket/domain/circles_entity.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

Color currentColorS = randomColor();
final sizeS = signal<double>(0);
final firstCircleS = computed(
  () {
    final center = sizeS.value / 2;
    n++;
    return CircleEntity(
      center: Complex(center, center),
      bend: 1 / center,
      color: randomColor(),
      id: n,
    );
  },
);

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
    return Watch.builder(
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
                      CircleWidget(
                        circle: firstCircleS.watch(context),
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

//Calcula círcula A e B tangentes entre si e o círculo externo baseado no Offset do click
({CircleEntity circle1, CircleEntity circle2}) calcCircles(
  double originRadius,
  Offset localPosition,
) {
  //Calculo o cículo com o centro no clique e raio até ficar tangente ao círculo externo
  final center = Complex(localPosition.dx, localPosition.dy);
  final radius = (originRadius -
      (localPosition - Offset(originRadius, originRadius)).distance);
  n++;
  final circle1 = CircleEntity(
    center: center,
    bend: 1 / radius,
    color: currentColorS,
    id: n,
  );

  //Calcula o segundo círculo para ser tangente ao primeiro e o externo ocupando o raio restante
  //O Raio é a diferença do diâmetro do círculo externo menos o diamêtro do primeiro círculo
  final otherRadius = ((originRadius * 2) - (radius * 2)) / 2;
  //Calcula o angulo entre o centro do primeiro círculo e do círculo externo
  final angle = -atan2(
    center.imaginary - (originRadius),
    center.real - (originRadius),
  );
  //Utiliza as Propriedades do círculo unitário para encontrar o centro do segundo círculo
  final cosC = -cos(angle);
  final sinC = sin(angle);
  final x = (cosC * (otherRadius + radius)) + center.toOffset.dx;
  final y = (sinC * (otherRadius + radius)) + center.toOffset.dy;
  final otherCenter = Offset(x, y);
  n++;
  final circle2 = CircleEntity(
    center: Complex(otherCenter.dx, otherCenter.dy),
    bend: 1 / otherRadius,
    color: currentColorS,
    id: n,
  );
  return (circle1: circle1, circle2: circle2);
}

class CircleWidget extends StatefulWidget {
  const CircleWidget({
    super.key,
    required this.circle,
  });

  final CircleEntity circle;

  @override
  State<CircleWidget> createState() => _CircleWidgetState();
}

class _CircleWidgetState extends State<CircleWidget> {
  @override
  void didUpdateWidget(covariant CircleWidget oldWidget) {
    if (oldWidget.circle != widget.circle) {
      clickPoint = null;
    }
    super.didUpdateWidget(oldWidget);
  }

  Offset? clickPoint;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: (widget.circle.center.imaginary - widget.circle.radius).abs(),
      left: (widget.circle.center.real - widget.circle.radius).abs(),
      child: Container(
        clipBehavior: Clip.antiAlias,
        width: widget.circle.radius * 2,
        height: widget.circle.radius * 2,
        decoration: BoxDecoration(
          color: widget.circle.color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTapUp: (details) async {
              currentColorS = (randomColor());
              setState(() {
                clickPoint = details.localPosition;
              });
            },
            child: clickPoint != null
                ? Builder(builder: (context) {
                    //Cria os dois círculo baseados no clique
                    final circles = calcCircles(
                      widget.circle.radius,
                      clickPoint!,
                    );
                    //Cria o círculo externo com curvatura invertida
                    final newExternalCircle = CircleEntity(
                      center:
                          Complex(widget.circle.radius, widget.circle.radius),
                      bend: -widget.circle.bend,
                      color: currentColorS,
                      id: n,
                    );
                    //Lista de círculos que serão subcírculos deste círculo
                    List<CircleEntity> subCircles = [];
                    //Fila de tripla de círculos para que seja autogerado os circulos tangencias
                    List<List<CircleEntity>> queue = [
                      [newExternalCircle, circles.circle1, circles.circle2],
                    ];
                    while (queue.isNotEmpty) {
                      final c1 = queue[0][0];
                      final c2 = queue[0][1];
                      final c3 = queue[0][2];
                      if (c1.isTangent(c2) &&
                          c1.isTangent(c3) &&
                          c2.isTangent(c3)) {
                        //Usa o teorema de descartes para achar a curvatura do quarto círculo adjacente aos 3
                        final newsRadius = descartes(
                          c1,
                          c2,
                          c3,
                        );
                        //Usa o teorema complexo de descartes para achar o centro do quarto círculo adjacente aos 3
                        final newCircles = complexDescartes(
                          c1,
                          c2,
                          c3,
                          newsRadius,
                        );
                        for (final newCircle in newCircles) {
                          //Valida o círculos, uma vez que podem ter raio infito ou "encapsular" outro círculo
                          if (!subCircles.contains(newCircle) &&
                              newCircle.radius != firstCircleS.value.radius &&
                              validQuadriplet(
                                c1,
                                c2,
                                c3,
                                newCircle,
                              )) {
                            subCircles.add(newCircle);
                            queue.add([c1, c2, newCircle]);
                            queue.add([c2, c3, newCircle]);
                            queue.add([c3, c1, newCircle]);
                          }
                        }
                        queue.removeAt(0);
                      } else {
                        queue.removeAt(0);
                      }
                    }
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        CircleWidget(
                          circle: circles.circle1,
                        ),
                        CircleWidget(
                          circle: circles.circle2,
                        ),
                        for (final subCircle in subCircles)
                          CircleWidget(
                            circle: subCircle,
                          ),
                      ],
                    );
                  })
                : const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}

bool validQuadriplet(
    CircleEntity c1, CircleEntity c2, CircleEntity c3, CircleEntity c4) {
  final a = c1.isTangent(c2);
  final b = c1.isTangent(c3);
  final c = c1.isTangent(c4);
  final d = c2.isTangent(c3);
  final e = c2.isTangent(c4);
  final f = c3.isTangent(c4);
  return a && b && c && d && e && f;
}

//Calcula a curvatura do 4 círculo tangencial
List<double> descartes(
  CircleEntity c1,
  CircleEntity c2,
  CircleEntity c3,
) {
  final square = sqrt(
        (c1.bend * c2.bend + c2.bend * c3.bend + c3.bend * c1.bend).abs(),
      ) *
      2;
  final r1 = c1.bend + c2.bend + c3.bend + square;
  final r2 = c1.bend + c2.bend + c3.bend - square;
  return [r1, r2];
}

//Calcula o centro do 4 círculo tangencia
List<CircleEntity> complexDescartes(
  CircleEntity c1,
  CircleEntity c2,
  CircleEntity c3,
  List<double> c4Bends,
) {
  List<CircleEntity> circles = [];
  for (final k4 in c4Bends) {
    final z1 = c1.center.scale(c1.bend);
    final z2 = c2.center.scale(c2.bend);
    final z3 = c3.center.scale(c3.bend);
    final sum = z1 + z2 + z3;
    final raiz = z1 * z2 + z2 * z3 + z3 * z1;
    final result = raiz.sqrt().scale(2);
    final center1 = (sum + result).scale(1 / k4);
    final center2 = (sum - result).scale(1 / k4);
    n++;
    final circle1 = CircleEntity(
      center: center1,
      bend: k4,
      color: currentColorS,
      id: n,
    );
    n++;
    final circle2 = CircleEntity(
      center: center2,
      bend: k4,
      color: currentColorS,
      id: n,
    );
    circles.addAll([
      if (circle1.radius > 2 &&
          (circle1.radius < c1.radius &&
              circle1.radius < c2.radius &&
              circle1.radius < c3.radius))
        circle1,
      if (circle2.radius > 2 &&
          (circle2.radius < c1.radius &&
              circle2.radius < c2.radius &&
              circle2.radius < c3.radius))
        circle2,
    ]);
  }
  return circles;
}
