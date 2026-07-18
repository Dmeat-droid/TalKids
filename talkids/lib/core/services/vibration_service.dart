import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class VibrationService {
  static final VibrationService _instance = VibrationService._internal();

  factory VibrationService() {
    return _instance;
  }

  VibrationService._internal();

  /// Getaran ritme sukses (benar): Tada!
  /// Pola: Getaran singkat 100ms, jeda 50ms, getaran singkat 100ms, jeda 50ms, getaran mantap 300ms.
  Future<void> vibrateCorrect() async {
    try {
      if (await Vibration.hasVibrator() ?? false) {
        await Vibration.vibrate(
          pattern: [0, 100, 50, 100, 50, 300],
          intensities: [0, 128, 0, 128, 0, 255],
        );
      } else {
        // Fallback ke HapticFeedback jika kelas Vibration gagal/tidak tersedia
        await HapticFeedback.vibrate();
      }
    } catch (e) {
      // Fallback aman jika terjadi error platform
      try {
        await HapticFeedback.vibrate();
      } catch (_) {}
    }
  }

  /// Getaran ritme gagal (salah/terhenti): Peringatan ganda
  /// Pola: Getaran tegas 200ms, jeda 100ms, getaran tegas 200ms.
  Future<void> vibrateIncorrect() async {
    try {
      if (await Vibration.hasVibrator() ?? false) {
        await Vibration.vibrate(
          pattern: [0, 200, 100, 200],
          intensities: [0, 255, 0, 255],
        );
      } else {
        // Fallback ke HapticFeedback
        await HapticFeedback.heavyImpact();
      }
    } catch (e) {
      // Fallback aman jika terjadi error platform
      try {
        await HapticFeedback.heavyImpact();
      } catch (_) {}
    }
  }

}
