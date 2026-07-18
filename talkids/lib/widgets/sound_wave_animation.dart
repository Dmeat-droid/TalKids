import 'dart:math';
import 'package:flutter/material.dart';
import '../core/theme.dart';

class SoundWaveAnimation extends StatelessWidget {
  final Stream<double> amplitudeStream;
  final bool isRecording;
  final double height;

  const SoundWaveAnimation({
    super.key,
    required this.amplitudeStream,
    required this.isRecording,
    this.height = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: KidTheme.textDark.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: KidTheme.textDark.withValues(alpha: 0.1),
          width: 2,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: isRecording
          ? StreamBuilder<double>(
              stream: amplitudeStream,
              initialData: 0.05,
              builder: (context, snapshot) {
                final double amp = snapshot.data ?? 0.05;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(15, (index) {
                    // Center bars are taller, edge bars are shorter
                    final double centerFactor = 1.0 - (index - 7).abs() / 7.5;
                    // Add slight random fluctuation per bar for natural look
                    final double fluctuation = 0.8 + Random().nextDouble() * 0.4;
                    // Dynamic height scaling
                    final double barHeight = max(10.0, (height - 20) * amp * centerFactor * fluctuation);

                    // Alternate colors for a playful, high-contrast look
                    Color color = index % 2 == 0 ? KidTheme.primaryOrange : KidTheme.primaryBlue;

                    // Indikator visual real-time saat suara mencapai target keberhasilan
                    if (amp > 0.6) {
                      color = KidTheme.successGreen;
                    }

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 80),
                      width: 8,
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                );
              },
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(15, (index) {
                // Inactive flat/idle state
                final double centerFactor = 1.0 - (index - 7).abs() / 7.5;
                final double idleHeight = 10.0 + (height * 0.1) * centerFactor;
                return Container(
                  width: 8,
                  height: idleHeight,
                  decoration: BoxDecoration(
                    color: KidTheme.textDark.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
    );
  }
}
