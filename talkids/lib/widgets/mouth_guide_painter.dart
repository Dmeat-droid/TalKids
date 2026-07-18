import 'package:flutter/material.dart';
import '../core/theme.dart';

class MouthGuideWidget extends StatelessWidget {
  final String mouthType; // 'A', 'I', 'U', 'E', 'O'
  final double size;

  const MouthGuideWidget({
    super.key,
    required this.mouthType,
    this.size = 180,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(12),
      decoration: KidTheme.kidCardDecoration(
        color: Colors.white,
        borderColor: KidTheme.primaryBlue,
      ),
      child: Column(
        children: [
          Text(
            'BENTUK MULUT "$mouthType"',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: KidTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: CustomPaint(
              size: Size(size - 24, size - 48),
              painter: MouthGuidePainter(mouthType: mouthType),
            ),
          ),
        ],
      ),
    );
  }
}

class MouthGuidePainter extends CustomPainter {
  final String mouthType;

  MouthGuidePainter({required this.mouthType});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Offset center = Offset(w / 2, h / 2);

    final Paint lipPaint = Paint()
      ..color = const Color(0xFFFF6B6B) // Bright oral red-pink for lips
      ..style = PaintingStyle.fill;

    final Paint cavityPaint = Paint()
      ..color = const Color(0xFF4A1521) // Dark maroon for inner mouth
      ..style = PaintingStyle.fill;

    final Paint tonguePaint = Paint()
      ..color = const Color(0xFFFF8B94) // Pink for tongue
      ..style = PaintingStyle.fill;

    final Paint teethPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final Paint outlinePaint = Paint()
      ..color = KidTheme.textDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final Paint thinLinePaint = Paint()
      ..color = KidTheme.textDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    switch (mouthType.toUpperCase()) {
      case 'A':
        // --- VOWEL A: Wide open mouth ---
        // 1. Draw outer lip shape (large circle/oval)
        canvas.drawOval(
          Rect.fromCenter(center: center, width: w * 0.85, height: h * 0.8),
          lipPaint,
        );
        canvas.drawOval(
          Rect.fromCenter(center: center, width: w * 0.85, height: h * 0.8),
          outlinePaint,
        );

        // 2. Draw inner cavity opening (large vertical oval)
        final Rect cavityA = Rect.fromCenter(center: center, width: w * 0.65, height: h * 0.55);
        canvas.drawOval(cavityA, cavityPaint);
        canvas.drawOval(cavityA, outlinePaint);

        // 3. Teeth (upper & lower borders)
        final Path upperTeeth = Path();
        upperTeeth.moveTo(center.dx - w * 0.25, center.dy - h * 0.18);
        upperTeeth.lineTo(center.dx + w * 0.25, center.dy - h * 0.18);
        upperTeeth.quadraticBezierTo(center.dx + w * 0.2, center.dy - h * 0.1, center.dx, center.dy - h * 0.1);
        upperTeeth.quadraticBezierTo(center.dx - w * 0.2, center.dy - h * 0.1, center.dx - w * 0.25, center.dy - h * 0.18);
        canvas.drawPath(upperTeeth, teethPaint);
        canvas.drawPath(upperTeeth, thinLinePaint);

        // 4. Tongue at bottom
        final Path tongueA = Path();
        tongueA.moveTo(center.dx - w * 0.25, center.dy + h * 0.18);
        tongueA.quadraticBezierTo(center.dx, center.dy + h * 0.05, center.dx + w * 0.25, center.dy + h * 0.18);
        canvas.drawPath(tongueA, tonguePaint);
        canvas.drawPath(tongueA, thinLinePaint);
        break;

      case 'I':
        // --- VOWEL I: Stretched flat smile ---
        // 1. Lips (wide rounded rectangle)
        final Rect lipI = Rect.fromCenter(center: center, width: w * 0.95, height: h * 0.4);
        canvas.drawRRect(
          RRect.fromRectAndRadius(lipI, const Radius.circular(20)),
          lipPaint,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(lipI, const Radius.circular(20)),
          outlinePaint,
        );

        // 2. Inner cavity (narrow horizontal opening)
        final Rect cavityI = Rect.fromCenter(center: center, width: w * 0.8, height: h * 0.2);
        canvas.drawRRect(
          RRect.fromRectAndRadius(cavityI, const Radius.circular(10)),
          cavityPaint,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(cavityI, const Radius.circular(10)),
          outlinePaint,
        );

        // 3. Closed teeth (represented as white blocks meeting in center)
        final Rect upperTeethI = Rect.fromLTRB(center.dx - w * 0.35, center.dy - h * 0.08, center.dx + w * 0.35, center.dy);
        final Rect lowerTeethI = Rect.fromLTRB(center.dx - w * 0.3, center.dy, center.dx + w * 0.3, center.dy + h * 0.08);
        canvas.drawRect(upperTeethI, teethPaint);
        canvas.drawRect(lowerTeethI, teethPaint);
        canvas.drawLine(Offset(center.dx - w * 0.35, center.dy), Offset(center.dx + w * 0.35, center.dy), thinLinePaint);
        break;

      case 'U':
        // --- VOWEL U: Rounded puckered circle ---
        // 1. Lips (medium circular shape)
        canvas.drawCircle(center, h * 0.45, lipPaint);
        canvas.drawCircle(center, h * 0.45, outlinePaint);

        // 2. Small puckered opening (small circle)
        canvas.drawCircle(center, h * 0.18, cavityPaint);
        canvas.drawCircle(center, h * 0.18, outlinePaint);
        break;

      case 'E':
        // --- VOWEL E: Mid open wide mouth ---
        // 1. Lips (medium height, wide oval)
        canvas.drawOval(
          Rect.fromCenter(center: center, width: w * 0.9, height: h * 0.6),
          lipPaint,
        );
        canvas.drawOval(
          Rect.fromCenter(center: center, width: w * 0.9, height: h * 0.6),
          outlinePaint,
        );

        // 2. Inner cavity (medium height opening)
        final Rect cavityE = Rect.fromCenter(center: center, width: w * 0.75, height: h * 0.35);
        canvas.drawOval(cavityE, cavityPaint);
        canvas.drawOval(cavityE, outlinePaint);

        // 3. Upper teeth slightly visible
        final Path upperTeethE = Path();
        upperTeethE.moveTo(center.dx - w * 0.3, center.dy - h * 0.12);
        upperTeethE.lineTo(center.dx + w * 0.3, center.dy - h * 0.12);
        upperTeethE.quadraticBezierTo(center.dx + w * 0.25, center.dy - h * 0.05, center.dx, center.dy - h * 0.05);
        upperTeethE.quadraticBezierTo(center.dx - w * 0.25, center.dy - h * 0.05, center.dx - w * 0.3, center.dy - h * 0.12);
        canvas.drawPath(upperTeethE, teethPaint);
        canvas.drawPath(upperTeethE, thinLinePaint);

        // 4. Flat tongue slightly visible at bottom
        final Path tongueE = Path();
        tongueE.moveTo(center.dx - w * 0.25, center.dy + h * 0.12);
        tongueE.quadraticBezierTo(center.dx, center.dy + h * 0.06, center.dx + w * 0.25, center.dy + h * 0.12);
        canvas.drawPath(tongueE, tonguePaint);
        canvas.drawPath(tongueE, thinLinePaint);
        break;

      case 'O':
        // --- VOWEL O: Oval rounded circle ---
        // 1. Lips (tall vertical oval)
        canvas.drawOval(
          Rect.fromCenter(center: center, width: w * 0.75, height: h * 0.85),
          lipPaint,
        );
        canvas.drawOval(
          Rect.fromCenter(center: center, width: w * 0.75, height: h * 0.85),
          outlinePaint,
        );

        // 2. Inner cavity (tall opening)
        final Rect cavityO = Rect.fromCenter(center: center, width: w * 0.45, height: h * 0.55);
        canvas.drawOval(cavityO, cavityPaint);
        canvas.drawOval(cavityO, outlinePaint);
        break;

      default:
        // Default smiling lips
        final Path smilePath = Path();
        smilePath.moveTo(w * 0.1, h * 0.45);
        smilePath.cubicTo(
          w * 0.3, h * 0.65,
          w * 0.7, h * 0.65,
          w * 0.9, h * 0.45,
        );
        smilePath.cubicTo(
          w * 0.7, h * 0.8,
          w * 0.3, h * 0.8,
          w * 0.1, h * 0.45,
        );
        canvas.drawPath(smilePath, lipPaint);
        canvas.drawPath(smilePath, outlinePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false; // Static drawing
  }
}
