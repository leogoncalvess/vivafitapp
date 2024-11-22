import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class HeartActivityChart extends StatefulWidget {
  final double caloriesProgress; // Entre 0 e 1
  final double stepsProgress; // Entre 0 e 1
  final double activeTimeProgress; // Entre 0 e 1

  HeartActivityChart({
    required this.caloriesProgress,
    required this.stepsProgress,
    required this.activeTimeProgress,
  });

  @override
  _HeartActivityChartState createState() => _HeartActivityChartState();
}

class _HeartActivityChartState extends State<HeartActivityChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomPaint(
        size: Size(150, 150), // Tamanho do gráfico
        painter: HeartLayeredPainter(
          caloriesProgress: widget.caloriesProgress * _animation.value,
          stepsProgress: widget.stepsProgress * _animation.value,
          activeTimeProgress: widget.activeTimeProgress * _animation.value,
        ),
      ),
    );
  }
}

enum HeartType {
  classic,
  rounded,
  sharp,
}

class HeartLayeredPainter extends CustomPainter {
  final double caloriesProgress;
  final double stepsProgress;
  final double activeTimeProgress;

  HeartLayeredPainter({
    required this.caloriesProgress,
    required this.stepsProgress,
    required this.activeTimeProgress,
  });

Path createHeartPath(double scale, Size size, HeartType heartType) {
  
  final double width = size.width * scale;
  final double height = size.height * scale;
  Path path = Path();
  switch (heartType) {
    case HeartType.classic:
      // Lógica para coração clássico
      path.moveTo(size.width / 2, size.height / 4);
      path.cubicTo(size.width * 3 / 4, 0, size.width, size.height / 2, size.width / 2, size.height);
      path.cubicTo(0, size.height / 2, size.width / 4, 0, size.width / 2, size.height / 4);
      break;
    case HeartType.rounded:
      // Lógica para coração arredondado
      path.moveTo(size.width / 2, size.height / 3);
      path.cubicTo(size.width * 5 / 6, 0, size.width, size.height * 2 / 3, size.width / 2, size.height);
      path.cubicTo(0, size.height * 2 / 3, size.width / 6, 0, size.width / 2, size.height / 3);
      break;
    case HeartType.sharp:
      // Lógica para coração com pontas mais agudas
      path.moveTo(size.width / 2, size.height / 5);
      path.cubicTo(size.width * 4 / 5, 0, size.width, size.height / 2, size.width / 2, size.height);
      path.cubicTo(0, size.height / 2, size.width / 5, 0, size.width / 2, size.height / 5);
      break;
  }
  path.close();
  return path;
}

  @override
  void paint(Canvas canvas, Size size) {
    final Paint basePaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)  // Cor do contorno (base)
      ..style = PaintingStyle.stroke         // Estilo de contorno
      ..strokeWidth = 8.0                    // Largura do contorno
      ..strokeCap = StrokeCap.round;         // Pontas arredondadas

    // Tamanhos escalados para cada coração
    const double scaleCalories = 1.0;    // Coração base (maior)
    const double scaleSteps = 0.8;       // Coração intermediário
    const double scaleActiveTime = 0.6;  // Coração menor

    // Cores de cada camada
    final Color colorCalories = Colors.redAccent;
    final Color colorSteps = Colors.blueAccent;
    final Color colorActiveTime = Colors.greenAccent;

    // Definindo os deslocamentos (Offsets) para cada coração
    final Offset offsetCalories = Offset(0, 0);    // Coração maior no centro
    final Offset offsetSteps = Offset(15, 20);     // Coração intermediário no centro
    final Offset offsetActiveTime = Offset(30, 40); // Coração menor no centro

    // Função para desenhar o progresso no contorno do coração
    void drawProgress(Path path, double progress, Color color, Offset offset) {
      final Paint progressPaint = Paint()
        ..color = color.withOpacity(0.9) // Cor de preenchimento (mais intensa)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0  // Largura do preenchimento
        ..strokeCap = StrokeCap.round;  // Pontas arredondadas

      // Obtendo a métrica do caminho para cortar a parte do progresso
      PathMetric pathMetric = path.computeMetrics().first;
      final Path extractPath = pathMetric.extractPath(
        0.0,
        pathMetric.length * progress,
      );
      canvas.drawPath(extractPath.shift(offset), progressPaint);
    }

    // Desenhando os corações com progresso
    final Path heartPathCalories = createHeartPath(scaleCalories, size, HeartType.rounded);    
    final Path heartPathSteps = createHeartPath(scaleSteps, size, HeartType.classic);
    final Path heartPathActiveTime = createHeartPath(scaleActiveTime, size, HeartType.sharp);

    // Desenhando os contornos dos corações
    canvas.drawPath(heartPathCalories.shift(offsetCalories), basePaint);
    canvas.drawPath(heartPathSteps.shift(offsetSteps), basePaint);
    canvas.drawPath(heartPathActiveTime.shift(offsetActiveTime), basePaint);

    // Desenhando o progresso nos corações
    drawProgress(heartPathCalories, caloriesProgress, colorCalories, offsetCalories);
    drawProgress(heartPathSteps, stepsProgress, colorSteps, offsetSteps);
    drawProgress(heartPathActiveTime, activeTimeProgress, colorActiveTime, offsetActiveTime);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}