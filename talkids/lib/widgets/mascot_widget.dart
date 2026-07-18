import 'package:flutter/material.dart';
import '../core/theme.dart';

enum MascotExpression { greeting, talking, encouraging, jumping }

class MascotWidget extends StatefulWidget {
  final MascotExpression expression;
  final String? speechBubbleText;
  final double size;

  const MascotWidget({
    super.key,
    required this.expression,
    this.speechBubbleText,
    this.size = 200,
  });

  @override
  State<MascotWidget> createState() => _MascotWidgetState();
}

class _MascotWidgetState extends State<MascotWidget> with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    // Smooth idle breathing/floating animation
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Speech Bubble if text is provided
        if (widget.speechBubbleText != null && widget.speechBubbleText!.isNotEmpty)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(bottom: 16, left: 24, right: 24),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: KidTheme.speechBubbleDecoration(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.volume_up, color: KidTheme.primaryBlue, size: 28),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    widget.speechBubbleText!,
                    style: KidTheme.themeData.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        // Animated Dolphin Mascot
        AnimatedBuilder(
          animation: _floatAnimation,
          builder: (context, child) {
            double rotation = 0.0;
            double verticalOffset = _floatAnimation.value;

            // Customize movement based on expression
            if (widget.expression == MascotExpression.jumping) {
              rotation = -0.15; // Angled upward
              verticalOffset -= 20.0; // Higher up
            }

            return Transform.translate(
              offset: Offset(0, verticalOffset),
              child: Transform.rotate(
                angle: rotation,
                child: child,
              ),
            );
          },
          child: CustomPaint(
            size: Size(widget.size * 1.2, widget.size),
            painter: DolphinPainter(expression: widget.expression),
          ),
        ),
      ],
    );
  }
}

class DolphinPainter extends CustomPainter {
  final MascotExpression expression;

  DolphinPainter({required this.expression});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Paints
    final Paint bodyPaint = Paint()
      ..color = KidTheme.primaryBlue
      ..style = PaintingStyle.fill;

    final Paint bellyPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final Paint eyePaint = Paint()
      ..color = KidTheme.textDark
      ..style = PaintingStyle.fill;

    final Paint linePaint = Paint()
      ..color = KidTheme.textDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final Paint cheekPaint = Paint()
      ..color = const Color(0xFFFFB3B3) // Soft pink
      ..style = PaintingStyle.fill;

    // --- DRAW BODY ---
    final Path bodyPath = Path();
    bodyPath.moveTo(w * 0.1, h * 0.6); // Start at snout/mouth area
    
    // Top arch of body to tail
    bodyPath.cubicTo(
      w * 0.2, h * 0.1,  // control point 1
      w * 0.7, h * 0.15, // control point 2
      w * 0.9, h * 0.5,  // end point (near tail)
    );

    // Tail fin (Upper lobe)
    bodyPath.quadraticBezierTo(w * 0.98, h * 0.38, w * 0.98, h * 0.35);
    bodyPath.quadraticBezierTo(w * 0.95, h * 0.5, w * 0.9, h * 0.52);

    // Tail fin (Lower lobe)
    bodyPath.quadraticBezierTo(w * 0.98, h * 0.65, w * 0.98, h * 0.68);
    bodyPath.quadraticBezierTo(w * 0.92, h * 0.58, w * 0.88, h * 0.56);

    // Bottom body back to throat
    bodyPath.cubicTo(
      w * 0.7, h * 0.75,
      w * 0.3, h * 0.75,
      w * 0.15, h * 0.65,
    );
    
    // Snout
    bodyPath.quadraticBezierTo(w * 0.05, h * 0.65, w * 0.08, h * 0.58);
    bodyPath.quadraticBezierTo(w * 0.12, h * 0.56, w * 0.1, h * 0.6);
    bodyPath.close();

    canvas.drawPath(bodyPath, bodyPaint);
    canvas.drawPath(bodyPath, linePaint); // Bold outline

    // --- DRAW DORSAL FIN (Sirip Punggung) ---
    final Path dorsalPath = Path();
    dorsalPath.moveTo(w * 0.45, h * 0.23);
    dorsalPath.quadraticBezierTo(w * 0.5, h * 0.05, w * 0.6, h * 0.08);
    dorsalPath.quadraticBezierTo(w * 0.58, h * 0.2, w * 0.58, h * 0.27);
    canvas.drawPath(dorsalPath, bodyPaint);
    canvas.drawPath(dorsalPath, linePaint);

    // --- DRAW BELLY (Bagian Perut Putih) ---
    final Path bellyPath = Path();
    bellyPath.moveTo(w * 0.15, h * 0.64);
    bellyPath.cubicTo(
      w * 0.3, h * 0.72,
      w * 0.6, h * 0.7,
      w * 0.8, h * 0.55,
    );
    bellyPath.cubicTo(
      w * 0.7, h * 0.5,
      w * 0.3, h * 0.55,
      w * 0.15, h * 0.64,
    );
    bellyPath.close();
    canvas.drawPath(bellyPath, bellyPaint);

    // --- DRAW FLIPPER (Sirip Samping) ---
    final Path flipperPath = Path();
    if (expression == MascotExpression.greeting) {
      // Sirip melambai ke atas
      flipperPath.moveTo(w * 0.35, h * 0.55);
      flipperPath.quadraticBezierTo(w * 0.45, h * 0.4, w * 0.5, h * 0.35);
      flipperPath.quadraticBezierTo(w * 0.45, h * 0.55, w * 0.38, h * 0.62);
    } else {
      // Sirip biasa rileks
      flipperPath.moveTo(w * 0.35, h * 0.6);
      flipperPath.quadraticBezierTo(w * 0.42, h * 0.78, w * 0.5, h * 0.78);
      flipperPath.quadraticBezierTo(w * 0.45, h * 0.65, w * 0.38, h * 0.6);
    }
    flipperPath.close();
    canvas.drawPath(flipperPath, bodyPaint);
    canvas.drawPath(flipperPath, linePaint);

    // --- DRAW FACE FEATURES (Mata, Mulut, Pipi) ---
    // Rosy Cheeks
    canvas.drawCircle(Offset(w * 0.25, h * 0.55), 10, cheekPaint);

    // Eye Expressions
    final double eyeX = w * 0.2;
    final double eyeY = h * 0.45;

    if (expression == MascotExpression.encouraging || expression == MascotExpression.jumping) {
      // Happy curved closed eye (^.^)
      final Path eyeArc = Path();
      eyeArc.moveTo(eyeX - 8, eyeY + 2);
      eyeArc.quadraticBezierTo(eyeX, eyeY - 6, eyeX + 8, eyeY + 2);
      canvas.drawPath(eyeArc, linePaint);
    } else {
      // Standard cute open eye
      canvas.drawOval(
        Rect.fromCenter(center: Offset(eyeX, eyeY), width: 14, height: 18),
        eyePaint,
      );
      // Sparkle in eye
      canvas.drawCircle(Offset(eyeX - 3, eyeY - 4), 3, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(eyeX + 2, eyeY + 2), 1.5, Paint()..color = Colors.white);
    }

    // Mouth Expression
    final Path mouthPath = Path();
    if (expression == MascotExpression.talking) {
      // Open mouth for speaking
      mouthPath.moveTo(w * 0.08, h * 0.6);
      mouthPath.quadraticBezierTo(w * 0.13, h * 0.66, w * 0.16, h * 0.6);
      mouthPath.quadraticBezierTo(w * 0.12, h * 0.61, w * 0.08, h * 0.6);
      canvas.drawPath(mouthPath, Paint()..color = const Color(0xFFFF6B6B));
      canvas.drawPath(mouthPath, linePaint);
    } else if (expression == MascotExpression.encouraging || expression == MascotExpression.greeting || expression == MascotExpression.jumping) {
      // Big happy smile
      mouthPath.moveTo(w * 0.09, h * 0.59);
      mouthPath.quadraticBezierTo(w * 0.14, h * 0.65, w * 0.18, h * 0.58);
      canvas.drawPath(mouthPath, linePaint);
    } else {
      // Simple smile
      mouthPath.moveTo(w * 0.1, h * 0.6);
      mouthPath.quadraticBezierTo(w * 0.13, h * 0.63, w * 0.16, h * 0.59);
      canvas.drawPath(mouthPath, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Simple, always redraw for animations
  }
}
