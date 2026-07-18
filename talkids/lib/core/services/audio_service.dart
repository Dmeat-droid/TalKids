import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

enum AudioState { idle, playing, recording }

class AudioService {
  AudioState _state = AudioState.idle;
  
  final FlutterTts _flutterTts = FlutterTts();
  final SpeechToText _speechToText = SpeechToText();
  
  StreamController<double>? _amplitudeController;

  Timer? _unclearSoundTimer;
  bool _hasDetectedSound = false;

  AudioState get state => _state;

  AudioService() {
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("id-ID");
    await _flutterTts.setSpeechRate(0.5); // Sedikit dipercepat agar terdengar lebih natural (0.5 biasanya pas)
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0); // Pitch standar agar intonasi bahasa Indonesianya tidak aneh
    await _flutterTts.awaitSpeakCompletion(true);
  }

  // Memutar audio target menggunakan Text-to-Speech
  Future<void> playTargetAudio(String text, {required Function(AudioState) onStateChanged}) async {
    if (_state != AudioState.idle) return;

    _state = AudioState.playing;
    onStateChanged(_state);

    await _flutterTts.speak(text);

    _state = AudioState.idle;
    onStateChanged(_state);
  }

  // Merekam suara anak dan mencocokkan dengan target (Speech-to-Text)
  Stream<double> startRecording({
    required String targetWord,
    required Function(AudioState) onStateChanged,
    required Function(bool isSuccess, String recognizedWords) onComplete,
  }) {
    if (_state != AudioState.idle) {
      return const Stream<double>.empty();
    }

    _state = AudioState.recording;
    onStateChanged(_state);

    _amplitudeController = StreamController<double>();
    
    _hasDetectedSound = false;
    _unclearSoundTimer?.cancel();
    _unclearSoundTimer = null;

    bool isSuccess = false;
    String finalRecognized = "";

    _speechToText.initialize(
      onStatus: (status) {
        print("SpeechToText status: $status");
        if (status == 'done' || status == 'notListening') {
          // Hanya panggil onComplete jika state masih recording
          if (_state == AudioState.recording) {
             stopRecording(onStateChanged: onStateChanged);
             onComplete(isSuccess, finalRecognized);
          }
        }
      },
      onError: (errorNotification) {
        print("SpeechToText error: ${errorNotification.errorMsg}");
        if (_state == AudioState.recording) {
           stopRecording(onStateChanged: onStateChanged);
           onComplete(false, "[ERROR: ${errorNotification.errorMsg}]");
        }
      },
    ).then((available) {
      print("SpeechToText available: $available");
      if (available) {
        _speechToText.listen(
          localeId: 'id_ID',
          cancelOnError: true,
          partialResults: true,
          listenFor: const Duration(seconds: 15),
          pauseFor: const Duration(seconds: 2),
          onResult: (result) {
            print("SpeechToText result: ${result.recognizedWords}, finalResult: ${result.finalResult}");
            finalRecognized = result.recognizedWords;
            
            // Perpanjang timer jika ada kata yang terdeteksi agar tidak terpotong saat berbicara
            if (finalRecognized.trim().isNotEmpty && _state == AudioState.recording) {
              _unclearSoundTimer?.cancel();
              _unclearSoundTimer = Timer(const Duration(milliseconds: 2000), () {
                if (_state == AudioState.recording) {
                  print("Extended timeout triggered.");
                  stopRecording(onStateChanged: onStateChanged);
                  if (finalRecognized.trim().isEmpty) {
                    onComplete(false, "[ERROR: error_no_match]");
                  } else {
                    onComplete(false, finalRecognized);
                  }
                }
              });
            }

            // Hilangkan tanda baca
            String cleanTarget = targetWord.toLowerCase().replaceAll(RegExp(r'[^\w\s]+'), '');
            String cleanRecognized = finalRecognized.toLowerCase().replaceAll(RegExp(r'[^\w\s]+'), '');

            // Pecah hasil pengenalan suara menjadi kata-kata agar pencocokan lebih akurat
            List<String> recognizedWordsList = cleanRecognized.split(RegExp(r'\s+'));

            bool isMatch = false;

            if (cleanTarget.isNotEmpty) {
              if (cleanTarget.contains(' ')) {
                // Untuk target berupa frasa atau pengulangan seperti "a a a"
                if (cleanRecognized.contains(cleanTarget)) {
                  isMatch = true;
                } else {
                  // Fallback: Jika target "a a a" tapi STT menangkap "a a", kita bisa cek apakah
                  // setidaknya salah satu kata cocok dengan huruf pertama target (jika pengulangan)
                  List<String> targetWords = cleanTarget.split(' ');
                  if (targetWords.toSet().length == 1) { // Berarti ini pengulangan huruf, misal "a a a"
                     String singleChar = targetWords.first;
                     for (String word in recognizedWordsList) {
                        if (word.contains(singleChar) && word.length <= 4) {
                           isMatch = true;
                           break;
                        }
                     }
                  }
                }
              } else {
                // Untuk target 1 kata
                for (String word in recognizedWordsList) {
                  if (word == cleanTarget) {
                    isMatch = true;
                    break;
                  }
                  // Toleransi ekstra untuk pelafalan 1 huruf
                  if (cleanTarget.length == 1) {
                    if (word.contains(cleanTarget) && word.length <= 4) {
                      isMatch = true;
                      break;
                    }
                  }
                }
              }

              // Jika masih tidak cocok, tapi target 1 huruf,
              // izinkan jika awalan kata cocok dengan huruf tersebut.
              if (!isMatch && cleanTarget.length == 1) {
                 if (cleanRecognized.startsWith(cleanTarget)) {
                    isMatch = true;
                 }
              }
            }

            if (isMatch) {
              if (_state == AudioState.recording) {
                 stopRecording(onStateChanged: onStateChanged);
                 onComplete(true, finalRecognized);
              }
            } else if (result.finalResult) {
              // STT menyatakan ucapan telah selesai tapi tidak cocok (finalResult = true)
              // Segera hentikan animasi dan berikan feedback salah
              if (_state == AudioState.recording) {
                 stopRecording(onStateChanged: onStateChanged);
                 onComplete(false, finalRecognized);
              }
            }
          },
          onSoundLevelChange: (level) {
            // Level suara dari STT biasanya antara -50 hingga 50
            double normalized = ((level + 50) / 100).clamp(0.0, 1.0);
            _amplitudeController?.add(normalized);

            // Deteksi suara aktif pertama kali untuk memicu timer 3 detik
            if (normalized > 0.15 && !_hasDetectedSound) {
              _hasDetectedSound = true;
              _unclearSoundTimer?.cancel();
              _unclearSoundTimer = Timer(const Duration(milliseconds: 3000), () {
                if (_state == AudioState.recording) {
                  print("Unclear sound detected for > 3 seconds. Stopping recording.");
                  stopRecording(onStateChanged: onStateChanged);
                  if (finalRecognized.trim().isEmpty) {
                    onComplete(false, "[ERROR: error_no_match]");
                  } else {
                    onComplete(false, finalRecognized);
                  }
                }
              });
            }
          },
        );
      } else {
        stopRecording(onStateChanged: onStateChanged);
        onComplete(false, "Mikrofon tidak tersedia/izin ditolak");
      }
    });

    return _amplitudeController!.stream;
  }

  void stopRecording({required Function(AudioState) onStateChanged}) {
    if (_state != AudioState.recording) return;

    _state = AudioState.idle; // Set state to idle FIRST to prevent re-entrancy

    _unclearSoundTimer?.cancel();
    _unclearSoundTimer = null;

    if (_speechToText.isListening) {
      _speechToText.stop();
    }
    
    _amplitudeController?.close();
    _amplitudeController = null;

    onStateChanged(_state);
  }
}
