import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme.dart';
import '../core/services/audio_service.dart';
import '../core/services/score_service.dart';
import '../models/learning_model.dart';
import '../widgets/mascot_widget.dart';
import '../widgets/mouth_guide_painter.dart';
import '../widgets/sound_wave_animation.dart';
import '../core/services/vibration_service.dart';
import 'reward_screen.dart';


class PracticeScreen extends StatefulWidget {
  final LearningItem item;

  const PracticeScreen({super.key, required this.item});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  final AudioService _audioService = AudioService();
  
  // UI states
  late String _tioText;
  late MascotExpression _tioExpression;
  bool _isRecording = false;
  late Stream<double> _amplitudeStream;

  @override
  void initState() {
    super.initState();
    // Gunakan instruksi visual dari model
    _tioText = widget.item.instructionText;
    _tioExpression = MascotExpression.talking;
    _amplitudeStream = const Stream<double>.empty();
  }

  @override
  void dispose() {
    // Make sure we stop any active recording/timer
    _audioService.stopRecording(onStateChanged: (_) {});
    super.dispose();
  }

  // Action: Start practice speech recording
  void _startSpeechRecord() {
    if (_isRecording) return;

    setState(() {
      _isRecording = true;
      _tioExpression = MascotExpression.encouraging;
      _tioText = 'Tio sedang memperhatikan! Yuk tirukan bentuk mulutnya dengan suara!';
      
      // Untuk STT Google, kita beri target berupa pengulangan jika itu 1 huruf vokal
      // agar lebih mudah dideteksi oleh mesin STT.
      String sttTarget = widget.item.category == LearningCategory.vokal 
          ? '${widget.item.text} ${widget.item.text} ${widget.item.text}' 
          : widget.item.text;

      // Trigger light haptic impact when starting recording
      HapticFeedback.lightImpact();

      _amplitudeStream = _audioService.startRecording(
        targetWord: sttTarget,
        onStateChanged: (state) {
          if (state == AudioState.idle) {
            setState(() {
              _isRecording = false;
            });
          }
        },
        onComplete: (isSuccess, recognizedWords) async {
          if (isSuccess) {
            // Trigger custom haptic vibration for success (rhythmic)
            VibrationService().vibrateCorrect();
            
            // Log success to SharedPreferences
            await ScoreService().recordPracticeSuccess(widget.item.id);

            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => RewardScreen(item: widget.item),
              ),
            );
          } else {
            // Trigger custom haptic vibration for failure (warning)
            VibrationService().vibrateIncorrect();

            // Tampilkan feedback visual
            setState(() {
              _isRecording = false; // Pastikan UI tombol dan animasi langsung mati
              _tioExpression = MascotExpression.greeting;

              
              bool isSingleLetter = widget.item.text.length == 1;

              if (recognizedWords.startsWith("[ERROR:")) {
                 if (recognizedWords.contains("error_no_match") || recognizedWords.contains("error_speech_timeout")) {
                    if (isSingleLetter) {
                      _tioText = 'Wah, Tio belum mendengar bunyi huruf "${widget.item.text}" nih. Yuk, coba bunyikan lebih keras!';
                    } else {
                      _tioText = 'Suaramu tidak terdengar dengan jelas. Yuk, coba lagi!';
                    }
                 } else {
                    _tioText = 'Ups, sepertinya ada gangguan mikrofon. Coba tekan tombol lagi ya!';
                 }
              } else {
                 String heard = recognizedWords.trim().isEmpty ? "Suara tidak terdengar" : '"$recognizedWords"';
                 if (isSingleLetter) {
                    _tioText = 'Terdengar: $heard. Pastikan bunyinya hanya huruf "${widget.item.text}" ya, yuk coba lagi!';
                 } else {
                    _tioText = 'Terdengar: $heard. Yuk, coba lagi dengan perhatikan gelombang suaranya!';
                 }
              }
            });
          }
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 12, top: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: KidTheme.textDark, width: 3),
          ),
          child: IconButton(
            icon: const Icon(Icons.close_rounded, color: KidTheme.textDark, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          'LATIHAN BICARA',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: KidTheme.textDark.withValues(alpha: 0.7),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double maxHeight = constraints.maxHeight;

            // Dynamically calculated sizes with clamping
            final double cardHeight = (maxHeight * 0.22).clamp(100.0, 180.0);
            final double mascotSize = (maxHeight * 0.16).clamp(80.0, 140.0);
            final double waveHeight = (maxHeight * 0.10).clamp(50.0, 100.0);
            final double spacingVal = (maxHeight * 0.02).clamp(4.0, 20.0);
            
            // Button styles
            final double buttonVerticalPadding = (maxHeight * 0.025).clamp(10.0, 24.0);
            final double buttonFontSize = (maxHeight * 0.028).clamp(16.0, 24.0);
            final double buttonIconSize = (maxHeight * 0.065).clamp(32.0, 56.0);
            final double syllableFontSize = widget.item.text.length > 3 ? (cardHeight * 0.3) : (cardHeight * 0.45);

            return SingleChildScrollView(
              padding: EdgeInsets.only(bottom: spacingVal),
              child: Column(
                children: [
                  // Target Word display and Mouth guide side by side
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: spacingVal * 0.8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Target Syllable Card
                        Expanded(
                          flex: 11,
                          child: Container(
                            height: cardHeight,
                            decoration: KidTheme.kidCardDecoration(
                              color: KidTheme.accentYellow,
                              borderColor: KidTheme.primaryOrange,
                            ),
                            child: Center(
                              child: Text(
                                widget.item.text,
                                style: KidTheme.themeData.textTheme.displayMedium?.copyWith(
                                  fontSize: syllableFontSize,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Mouth Articulation Guide Card
                        Expanded(
                          flex: 10,
                          child: MouthGuideWidget(
                            mouthType: widget.item.mouthGuideType,
                            size: cardHeight,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Phonetic instruction card (simple text guidance for parents/teachers helpers)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: spacingVal * 0.3),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: KidTheme.primaryBlue.withValues(alpha: 0.3), width: 2),
                      ),
                      child: Text(
                        'Petunjuk: ${widget.item.phoneticGuide}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: KidTheme.textDark,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: spacingVal * 0.5),

                  // Mascot Tio with speech bubble
                  MascotWidget(
                    expression: _tioExpression,
                    speechBubbleText: _tioText,
                    size: mascotSize,
                  ),
                  SizedBox(height: spacingVal),

                  // Realtime wave animation
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SoundWaveAnimation(
                      amplitudeStream: _amplitudeStream,
                      isRecording: _isRecording,
                      height: waveHeight,
                    ),
                  ),
                  SizedBox(height: spacingVal * 1.3),

                  // Control buttons (BICARA - Centered and Enlarged)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: (_isRecording)
                                ? Colors.red.withValues(alpha: 0.3)
                                : KidTheme.successGreen.withValues(alpha: 0.4),
                            offset: const Offset(0, 6),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isRecording 
                            ? () => _audioService.stopRecording(onStateChanged: (s) => setState(() => _isRecording = false)) 
                            : _startSpeechRecord,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isRecording ? Colors.redAccent : KidTheme.successGreen,
                          padding: EdgeInsets.symmetric(vertical: buttonVerticalPadding),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                            side: const BorderSide(color: Colors.white, width: 3),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                              size: buttonIconSize,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _isRecording ? 'SELESAI' : 'BICARA',
                              style: TextStyle(
                                fontSize: buttonFontSize,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
