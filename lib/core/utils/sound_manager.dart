import 'package:audioplayers/audioplayers.dart';
import 'package:promoter_app/qara_ksa.dart';

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  late AudioPlayer _audioPlayer;
  bool _soundEnabled = true;

  // Initialize the audio player
  void initialize() {
    _audioPlayer = AudioPlayer();
    // Pre-load the sound for better performance
    _audioPlayer.setSource(AssetSource('audio/select.wav'));
  }

  // Play the click sound
  Future<void> playClickSound() async {
    if (_soundEnabled) {
      try {
        await _audioPlayer.stop(); // Stop any currently playing sound
        await _audioPlayer.play(AssetSource('audio/select.wav'));
      } catch (e) {
        print('Error playing sound: $e');
      }
    }
  }

  // Toggle sound on/off
  void toggleSound() {
    _soundEnabled = !_soundEnabled;
  }

  // Check if sound is enabled
  bool get isSoundEnabled => _soundEnabled;

  // Dispose of resources
  void dispose() {
    _audioPlayer.dispose();
  }
}

// Extension to add sound to any widget
extension SoundWidget on Widget {
  Widget withClickSound() {
    return GestureDetector(
      onTap: () {
        SoundManager().playClickSound();
      },
      child: this,
    );
  }
}
