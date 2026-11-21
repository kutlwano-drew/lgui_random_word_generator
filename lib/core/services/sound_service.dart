// lib/core/services/sound_service.dart

import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final SoundService instance = SoundService._internal();
  SoundService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  
  bool soundsOn = true;
  double volume = 0.5;

  // Triggers playback if audio is active
  Future<void> _playTone() async {
    if (!soundsOn) return;
    
    try {
      // Force volume adjustment before playing the tone
      await _audioPlayer.setVolume(volume);
      // Stop any currently running instance of the sound to handle rapid clicks safely
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sample.mp3'));
    } catch (e) {
      // Safe guard against missing asset or uninitialized audio device states
      print("Audio playback error: $e");
    }
  }

  void playWordChange() => _playTone();
  void playButtonClick() => _playTone();
  void playCountdown() => _playTone();

  void setVolume(double value) {
    volume = value;
    _audioPlayer.setVolume(volume);
  }
}