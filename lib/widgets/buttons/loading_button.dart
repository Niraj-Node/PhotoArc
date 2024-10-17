import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class LoadingButton extends StatefulWidget {
  final Duration duration;
  final Widget child;
  final Function()? onTap;
  final double width;
  final double height;
  final Color color;
  final Color backgroundColor;
  final double borderRadius;
  final Color borderColor;
  final double borderWidth;

  const LoadingButton({
    super.key,
    required this.child,
    this.onTap,
    this.width = 150,
    this.height = 50,
    this.color = const Color(0xff4338CA),
    this.backgroundColor = Colors.blueAccent,
    this.borderColor = Colors.white12,
    this.borderRadius = 15.0,
    this.borderWidth = 2.0,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<LoadingButton> createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: widget.duration);
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap, // Only call onTap if provided
      borderRadius: BorderRadius.circular(
        widget.borderRadius,
      ),
      splashColor: widget.color,
      child: CustomPaint(
        painter: LoadingPainter(
          animation: _animationController,
          borderColor: widget.borderColor,
          borderRadius: widget.borderRadius,
          borderWidth: widget.borderWidth,
          color: widget.color,
          backgroundColor: widget.backgroundColor,
        ),
        child: Container(
          width: widget.width,
          height: widget.height,
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(5.5),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class LoadingPainter extends CustomPainter {
  final Animation animation;
  final Color color;
  final Color backgroundColor;
  final double borderRadius;
  final Color borderColor;
  final double borderWidth;

  LoadingPainter({
    required this.animation,
    this.color = Colors.orange,
    this.backgroundColor = Colors.transparent,
    this.borderColor = Colors.white,
    this.borderRadius = 15.0,
    this.borderWidth = 3.0,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Draw the background color
    final backgroundPaint = Paint()..color = backgroundColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(borderRadius)),
      backgroundPaint,
    );

    // Draw the loading effect
    final paint = Paint()
      ..shader = SweepGradient(
        colors: [
          color.withOpacity(.25),
          color,
        ],
        startAngle: 0.0,
        endAngle: vector.radians(180),
        stops: const [.75, 1.0],
        transform: GradientRotation(vector.radians(360.0 * animation.value)),
      ).createShader(rect);

    final path = Path.combine(
      PathOperation.xor,
      Path()
        ..addRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(borderRadius)),
        ),
      Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            rect.deflate(3.5),
            Radius.circular(borderRadius),
          ),
        ),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.deflate(1.5),
        Radius.circular(borderRadius),
      ),
      Paint()
        ..color = borderColor
        ..strokeWidth = borderWidth
        ..style = PaintingStyle.stroke,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
